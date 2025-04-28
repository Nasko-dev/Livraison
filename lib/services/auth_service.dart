import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/driver.dart';
import '../models/vehicle.dart';
import '../models/user.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService() {
    _dio.options.baseUrl = 'http://192.168.1.102:1337';

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print(
            '📡 Requête envoyée:\nURL: ${options.uri}\nMéthode: ${options.method}\nHeaders: ${options.headers}\nData: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print(
            '✅ Réponse reçue:\nStatus: ${response.statusCode}\nData: ${response.data}');
        return handler.next(response);
      },
      onError: (e, handler) {
        print(
            '❌ Erreur:\nType: ${e.type}\nMessage: ${e.message}\nResponse: ${e.response?.data}');
        return handler.next(e);
      },
    ));
  }

  bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPhone(String phone) {
    return RegExp(r'^\d{10}$').hasMatch(phone);
  }

  Future<bool> checkUserExists(String email, String phone) async {
    try {
      // Vérifier si l'email ou le téléphone est déjà utilisé
      final response = await _dio.get('/api/users/check-existing',
          queryParameters: {'email': email, 'phone': phone});

      // Si la réponse est 200, l'API a trouvé une correspondance
      return response.statusCode == 200 && response.data['exists'] == true;
    } catch (e) {
      // En cas d'erreur, on suppose que l'utilisateur n'existe pas
      // et on laisse l'inscription se faire (le serveur validera de toute façon)
      print('⚠️ Erreur lors de la vérification d\'existence: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> registerUser({
    required String name,
    required String surname,
    required String phone,
    required String address,
    required String vehicleType,
    required String email,
  }) async {
    try {
      print('🔄 Début inscription avec: $email / $phone');

      // Vérifier que les champs obligatoires sont remplis
      if (name.isEmpty || surname.isEmpty || address.isEmpty) {
        print('❌ Certains champs obligatoires sont vides');
        throw 'Tous les champs marqués avec * sont obligatoires';
      }

      // Vérifier si le téléphone est au bon format
      if (!isValidPhone(phone)) {
        print('❌ Format de téléphone invalide');
        throw 'Le numéro de téléphone doit contenir 10 chiffres';
      }

      // Vérifier si l'email est au bon format
      if (!isValidEmail(email)) {
        print('❌ Format d\'email invalide');
        throw 'L\'adresse email n\'est pas valide';
      }

      // Étape 1 : Enregistrement standard (username, email, password uniquement)
      print('📨 Envoi de la requête d\'inscription standard');

      final authResponse = await _dio.post('/api/auth/local/register', data: {
        'username': phone,
        'email': email,
        'password': phone,
      });

      if (authResponse.statusCode != 200) {
        final errorData = authResponse.data?['error'];
        String errorMessage = 'Erreur d\'inscription';

        if (errorData != null) {
          errorMessage = errorData['message'] ?? errorMessage;
          print(
              '🚫 Détails de l\'erreur: ${errorData['message']} (${errorData['status']})');
        }

        throw errorMessage;
      }

      final jwt = authResponse.data['jwt'];
      final userId = authResponse.data['user']['id'];

      // Sauvegarde locale du token
      await _storage.write(key: 'jwt', value: jwt);

      try {
        // Étape 2 : Mettre à jour le profil chauffeur avec les informations supplémentaires
        print(
            '📨 Mise à jour du profil chauffeur avec les informations complètes');

        final updateResponse = await _dio.put('/api/users/update-profile',
            data: {
              'name': name,
              'surname': surname,
              'phone': phone,
              'email': email,
              'address': address,
              'vehicleType': vehicleType.toLowerCase(),
              'status': 'pending',
              'documents': {
                'identity': false,
                'license': false,
                'insurance': false,
                'siren': false
              },
              'preferences': {
                'notifications': true,
                'darkMode': false,
                'language': 'fr'
              }
            },
            options: Options(headers: {'Authorization': 'Bearer $jwt'}));

        if (updateResponse.statusCode != 200) {
          print(
              '⚠️ Erreur lors de la mise à jour du profil: ${updateResponse.statusCode}');
          throw 'Erreur lors de la mise à jour du profil';
        }

        print('✅ Profil mis à jour avec succès');

        // Récupérer le profil complet
        final userProfile = await getCurrentUser();
        if (userProfile != null) {
          return userProfile;
        }

        // Fallback si getCurrentUser échoue
        return authResponse.data['user'];
      } catch (updateError) {
        print('❌ Erreur lors de la mise à jour du profil: $updateError');

        // En cas d'erreur, retourner quand même l'utilisateur de base
        await _storage.write(
            key: 'user', value: jsonEncode(authResponse.data['user']));
        return authResponse.data['user'];
      }
    } catch (e) {
      print('❌ Erreur dans registerUser: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loginWithPhone(String phone, String password,
      {String? populate}) async {
    try {
      final response = await _dio.post('/api/auth/local',
          data: {
            'identifier': phone,
            'password': password,
          },
          queryParameters: populate != null ? {'populate': populate} : null);

      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.write(key: 'jwt', value: data['jwt']);

        // Récupérer le profil complet de l'utilisateur
        final userProfile = await getCurrentUser(populate: populate);
        if (userProfile != null) {
          return userProfile;
        }

        // Fallback au cas où getCurrentUser échoue
        await _storage.write(key: 'user', value: jsonEncode(data['user']));
        return data['user'];
      }
      return null;
    } catch (e) {
      print('❌ Erreur de login: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser({String? populate}) async {
    final jwt = await _storage.read(key: 'jwt');
    if (jwt == null) return null;

    try {
      // Récupérer les données utilisateur
      final userResponse = await _dio.get('/api/users/me',
          options: Options(
            headers: {'Authorization': 'Bearer $jwt'},
          ),
          queryParameters: populate != null ? {'populate': populate} : null);

      final userData = userResponse.data['data'] ?? userResponse.data;

      print('✅ Données utilisateur récupérées: ${userData}');

      // Essayer de récupérer les données du chauffeur associé, mais ne pas échouer si erreur
      try {
        final chauffeurResponse = await _dio.get('/api/chauffeurs/me',
            options: Options(
              headers: {'Authorization': 'Bearer $jwt'},
              validateStatus: (status) =>
                  true, // Accepter tous les codes de statut
            ),
            queryParameters: populate != null ? {'populate': populate} : null);

        // Vérifier si la requête a réussi
        if (chauffeurResponse.statusCode == 200) {
          // Vérifier si les données sont encapsulées dans data
          final chauffeurData =
              chauffeurResponse.data['data'] ?? chauffeurResponse.data;

          print('✅ Données chauffeur récupérées: ${chauffeurData}');

          // Combiner les données
          Map<String, dynamic> combinedData = {
            ...userData,
            'chauffeur': chauffeurData
          };

          // Stocker les informations mises à jour
          await _storage.write(key: 'user', value: jsonEncode(combinedData));

          return combinedData;
        } else {
          print(
              'ℹ️ Pas de profil chauffeur disponible: ${chauffeurResponse.statusCode}');
          print('ℹ️ Détails: ${chauffeurResponse.data}');

          // Continuer avec seulement les données utilisateur
          await _storage.write(key: 'user', value: jsonEncode(userData));
          return userData;
        }
      } catch (chauffeurError) {
        // Si erreur lors de la récupération du chauffeur, retourner juste les données utilisateur
        print(
            '⚠️ Erreur contrôlée lors de la récupération du profil chauffeur: $chauffeurError');
        await _storage.write(key: 'user', value: jsonEncode(userData));
        return userData;
      }
    } catch (e) {
      print('❌ Erreur getCurrentUser: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'user');
  }

  Future<bool> isAuthenticated() async {
    final jwt = await _storage.read(key: 'jwt');
    return jwt != null;
  }

  Future<bool> verifyToken() async {
    final jwt = await _storage.read(key: 'jwt');
    if (jwt == null) return false;

    try {
      final response = await _dio.get('/api/users/me',
          options: Options(
            headers: {'Authorization': 'Bearer $jwt'},
          ));
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Token invalide: $e');
      await logout();
      return false;
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> userData) async {
    final jwt = await _storage.read(key: 'jwt');
    if (jwt == null) return false;

    try {
      print('🔄 Mise à jour du profil utilisateur...');

      final response = await _dio.put(
        '/api/users/update-profile',
        data: userData,
        options: Options(
          headers: {'Authorization': 'Bearer $jwt'},
          validateStatus: (status) => true,
        ),
      );

      if (response.statusCode != 200) {
        print('❌ Erreur de mise à jour du profil: ${response.statusCode}');
        print('📄 Détails: ${response.data}');
        throw 'Erreur lors de la mise à jour du profil (${response.statusCode})';
      }

      print('✅ Profil utilisateur mis à jour avec succès');

      // Actualiser le profil complet
      await getCurrentUser();

      return true;
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du profil: $e');
      return false;
    }
  }

  Future<bool> uploadDocument(String documentType, String filePath) async {
    final jwt = await _storage.read(key: 'jwt');
    if (jwt == null) return false;

    try {
      FormData formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(filePath),
        'documentType': documentType,
      });

      final response = await _dio.post(
        '/api/users/upload-document',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $jwt'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Erreur lors de l\'upload du document: $e');
      return false;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _dio.post('/api/auth/forgot-password', data: {
        'email': email,
      });

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Erreur lors de la demande de réinitialisation: $e');
      return false;
    }
  }

  Future<bool> resetPassword(String code, String newPassword) async {
    try {
      final response = await _dio.post('/api/auth/reset-password', data: {
        'code': code,
        'password': newPassword,
        'passwordConfirmation': newPassword,
      });

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Erreur lors de la réinitialisation du mot de passe: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> verifyDriverCode(
      String phone, String code) async {
    try {
      final response =
          await _dio.get('/api/chauffeurs/verify-code', queryParameters: {
        'phone': phone,
        'code': code,
      });

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['valid'] == true) {
          print('✅ Code vérifié avec succès');
          return data['chauffeur'];
        }
      }

      print('❌ Code invalide');
      return null;
    } catch (e) {
      print('❌ Erreur lors de la vérification du code: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> loginWithCode(String phone, String code,
      {String? populate}) async {
    try {
      print('🔄 Tentative de connexion avec code: $phone / $code');

      // Vérifier le format du téléphone
      if (!isValidPhone(phone)) {
        print('❌ Format de téléphone invalide');
        throw 'Format de téléphone invalide';
      }

      // Vérifier le format du code (4 chiffres)
      if (code.length != 4 || !RegExp(r'^\d{4}$').hasMatch(code)) {
        print('❌ Format de code invalide');
        throw 'Le code doit contenir exactement 4 chiffres';
      }

      // ÉTAPE 1: Vérifier d'abord si le code est valide pour ce téléphone
      try {
        print('🔄 Vérification du code auprès de l\'API...');
        final verifyResponse = await _dio.post(
          '/api/chauffeurs/verify-code-without-auth',
          data: {
            'phone': phone,
            'code': code,
          },
          options: Options(
            validateStatus: (status) => true,
          ),
          queryParameters: populate != null ? {'populate': populate} : null,
        );

        print('📊 Réponse vérification: ${verifyResponse.statusCode}');
        print('📄 Données: ${verifyResponse.data}');

        // Si la vérification échoue
        if (verifyResponse.statusCode != 200 ||
            verifyResponse.data['valid'] != true) {
          String errorMessage = "Code invalide";

          if (verifyResponse.data is Map &&
              verifyResponse.data['message'] != null) {
            errorMessage = verifyResponse.data['message'];
          }

          print('❌ Vérification échouée: $errorMessage');
          throw errorMessage;
        }

        // Récupérer les données du chauffeur
        final chauffeurData = verifyResponse.data['chauffeur'];
        print('✅ Code vérifié avec succès pour: ${chauffeurData['name']}');

        // ÉTAPE 2: Authentifier avec le numéro de téléphone pour obtenir un JWT
        print('🔄 Authentification avec l\'API JWT...');
        final loginResponse = await _dio.post(
          '/api/auth/local',
          data: {
            'identifier': phone,
            'password': phone, // Utilisation du téléphone comme mot de passe
          },
          options: Options(
            validateStatus: (status) => true,
          ),
          queryParameters: populate != null ? {'populate': populate} : null,
        );

        print('📊 Réponse auth: ${loginResponse.statusCode}');

        if (loginResponse.statusCode != 200) {
          print('❌ Authentification échouée: ${loginResponse.statusCode}');

          // Si l'authentification échoue mais que le code est bon, on crée une session sans JWT
          print('⚠️ Création d\'une session sans JWT (fallback)');
          await _storage.write(
              key: 'user',
              value: jsonEncode({
                'id': chauffeurData['id'],
                'username': phone,
                'email': chauffeurData['email'] ?? '',
                'chauffeur': chauffeurData
              }));

          return {
            'id': chauffeurData['id'],
            'username': phone,
            'email': chauffeurData['email'] ?? '',
            'chauffeur': chauffeurData
          };
        }

        // Authentification réussie avec JWT
        final jwt = loginResponse.data['jwt'];
        final userData = loginResponse.data['user'];

        // Sauvegarder le JWT
        await _storage.write(key: 'jwt', value: jwt);

        // Combiner les données utilisateur et chauffeur
        Map<String, dynamic> combinedData = {
          ...userData,
          'chauffeur': chauffeurData
        };

        // Sauvegarder les données
        await _storage.write(key: 'user', value: jsonEncode(combinedData));

        print('✅ Authentification complète réussie avec code et JWT');
        return combinedData;
      } catch (e) {
        print('❌ Erreur lors de la vérification ou connexion: $e');
        rethrow;
      }
    } catch (e) {
      print('❌ Erreur générale: $e');
      rethrow;
    }
  }

  // Méthode pour mettre à jour les informations du véhicule
  Future<bool> updateVehicleProfile(Map<String, dynamic> vehicleData) async {
    final jwt = await _storage.read(key: 'jwt');
    if (jwt == null) return false;

    try {
      print('🔄 Mise à jour du véhicule...');

      // Utiliser l'API générique avec l'ID utilisateur actuel
      final response = await _dio.put(
        '/api/users/update-vehicle',
        data: {
          'vehicle': vehicleData,
          'vehicleType': vehicleData['vehicleType'],
        },
        options: Options(
          headers: {'Authorization': 'Bearer $jwt'},
          validateStatus: (status) => true,
        ),
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 400) {
        print('❌ Erreur de mise à jour du véhicule: $statusCode');
        print('📄 Détails: ${response.data}');
        throw 'Erreur lors de la mise à jour du véhicule ($statusCode)';
      }

      print('✅ Véhicule mis à jour avec succès');

      // Actualiser le profil complet
      await getCurrentUser();

      return true;
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du véhicule: $e');
      return false;
    }
  }

  // Récupérer le profil utilisateur complet
  Future<User?> getUserProfile() async {
    try {
      final userData = await getCurrentUser();
      if (userData != null) {
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('❌ Erreur lors de la récupération du profil utilisateur: $e');
      return null;
    }
  }
}
