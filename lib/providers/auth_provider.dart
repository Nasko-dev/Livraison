import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.102:1337',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    validateStatus: (status) => true, // Accepter tous les codes de statut
  ));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  User? _user;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _rawUserData; // Pour stocker les données brutes

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  Map<String, dynamic>? get rawUserData => _rawUserData;

  AuthProvider() {
    // Ne pas appeler checkAuthStatus dans le constructeur
    // car cela peut provoquer des notifications pendant le build initial
    // checkAuthStatus();
  }

  // Cette méthode sera appelée explicitement par AuthWrapper
  Future<bool> checkAuthStatus() async {
    try {
      _setLoading(true);
      final isAuth = await _authService.isAuthenticated();

      if (isAuth) {
        final userData = await _authService.getCurrentUser(populate: 'avatar');
        if (userData != null) {
          developer.log(
              '📦 Données utilisateur reçues: ${jsonEncode(userData)}',
              name: 'AuthProvider');
          _rawUserData = userData;

          try {
            _user = User.fromJson(userData);
            developer.log(
                '👤 Utilisateur créé: ${_user?.name} ${_user?.surname}, tel: ${_user?.phone}',
                name: 'AuthProvider');
            developer.log('🖼️ Avatar URL: ${_user?.avatarUrl}',
                name: 'AuthProvider');
          } catch (e) {
            developer.log('⚠️ Erreur lors de la création de l\'objet User: $e',
                name: 'AuthProvider');
            _user = null;
            _setError('Erreur de format des données utilisateur');
          }

          // Vérifier si des données chauffeur sont disponibles
          if (userData.containsKey('chauffeur')) {
            developer.log(
                '🚗 Données chauffeur disponibles: ${jsonEncode(userData['chauffeur'])}',
                name: 'AuthProvider');
          }
        }
      } else {
        _user = null;
        _rawUserData = null;
      }

      return isAuth;
    } catch (e) {
      developer.log('❌ Erreur lors de la vérification d\'auth: $e',
          name: 'AuthProvider');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String phone, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final userData = await _authService.loginWithPhone(phone, password,
          populate: 'avatar');

      if (userData != null) {
        _rawUserData = userData;
        _user = User.fromJson(userData);
        developer.log('✅ Connexion réussie: ${_user?.name} ${_user?.surname}',
            name: 'AuthProvider');
        developer.log('🖼️ Avatar URL: ${_user?.avatarUrl}',
            name: 'AuthProvider');
        notifyListeners();
        return true;
      } else {
        _setError('Identifiants incorrects');
        return false;
      }
    } catch (e) {
      developer.log('❌ Erreur de connexion: $e', name: 'AuthProvider');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String surname,
    required String phone,
    required String address,
    required String vehicleType,
    required String email,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final userData = await _authService.registerUser(
        name: name,
        surname: surname,
        phone: phone,
        address: address,
        vehicleType: vehicleType,
        email: email,
      );

      if (userData != null) {
        _rawUserData = userData; // Stocker les données brutes
        _user = User.fromJson(userData);
        developer.log('✅ Inscription réussie: ${_user?.name} ${_user?.surname}',
            name: 'AuthProvider');
        notifyListeners();
        return true;
      } else {
        _setError('Erreur lors de l\'inscription');
        return false;
      }
    } catch (e) {
      developer.log('❌ Erreur d\'inscription: $e', name: 'AuthProvider');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authService.logout();
      _user = null;
      _rawUserData = null; // Effacer les données brutes
      developer.log('👋 Déconnexion réussie', name: 'AuthProvider');
      notifyListeners();
    } catch (e) {
      developer.log('❌ Erreur de déconnexion: $e', name: 'AuthProvider');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginWithCode(String phone, String code) async {
    try {
      _setLoading(true);
      _clearError();

      final userData =
          await _authService.loginWithCode(phone, code, populate: 'avatar');

      if (userData != null) {
        _rawUserData = userData;
        _user = User.fromJson(userData);
        developer.log(
            '✅ Connexion avec code réussie: ${_user?.name} ${_user?.surname}',
            name: 'AuthProvider');
        developer.log('🖼️ Avatar URL: ${_user?.avatarUrl}',
            name: 'AuthProvider');
        notifyListeners();
        return true;
      } else {
        _setError('Code ou numéro de téléphone incorrect');
        return false;
      }
    } catch (e) {
      developer.log('❌ Erreur de connexion avec code: $e',
          name: 'AuthProvider');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Méthode pour rafraîchir manuellement les données utilisateur
  Future<bool> refreshUserData() async {
    try {
      _setLoading(true);
      final userData = await _authService.getCurrentUser(populate: 'avatar');

      if (userData != null) {
        _rawUserData = userData;
        _user = User.fromJson(userData);
        developer.log(
            '🔄 Données utilisateur rafraîchies: ${_user?.name} ${_user?.surname}',
            name: 'AuthProvider');
        developer.log('🖼️ Avatar URL: ${_user?.avatarUrl}',
            name: 'AuthProvider');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      developer.log('❌ Erreur de rafraîchissement: $e', name: 'AuthProvider');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Méthode pour mettre à jour le profil utilisateur
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _authService.updateUserProfile(userData);

      if (success) {
        // Rafraîchir les données utilisateur
        await refreshUserData();
        return true;
      } else {
        _setError('Échec de la mise à jour du profil');
        return false;
      }
    } catch (e) {
      developer.log('❌ Erreur de mise à jour du profil: $e',
          name: 'AuthProvider');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadAvatar(File imageFile) async {
    try {
      _setLoading(true);
      print('🔄 [AuthProvider] Début de l\'upload de l\'avatar');

      final jwt = await _storage.read(key: 'jwt');
      if (jwt == null) {
        print('❌ [AuthProvider] Pas de token JWT trouvé');
        _setError('Non authentifié');
        return false;
      }

      print('📁 [AuthProvider] Fichier à uploader: ${imageFile.path}');

      // Code d'upload minimal
      final formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'avatar.jpg',
        ),
      });

      print('📦 [AuthProvider] FormData créé - code minimal');

      final response = await _dio.post(
        '/api/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwt',
          },
          validateStatus: (_) => true,
        ),
      );

      print('📊 [AuthProvider] Réponse API: ${response.statusCode}');
      print('📦 [AuthProvider] Données reçues: ${response.data}');

      if (response.statusCode == 200) {
        // Si l'upload a fonctionné, on associe l'image à l'utilisateur
        try {
          final fileData = (response.data as List).first;
          final fileId = fileData['id'];

          print('✅ [AuthProvider] Fichier uploadé, fileId = $fileId');

          final updateResp = await _dio.put(
            '/api/users/${_user!.id}',
            data: {
              'data': {
                'avatar': fileId,
              }
            },
            options: Options(
              headers: {
                'Authorization': 'Bearer $jwt',
              },
              validateStatus: (_) => true,
            ),
          );

          if (updateResp.statusCode == 200) {
            print('✅ [AuthProvider] Avatar lié à l\'utilisateur');
            await refreshUserData();
            return true;
          } else {
            print(
                '❌ [AuthProvider] Échec liaison avatar: ${updateResp.statusCode}');
            return false;
          }
        } catch (e) {
          print('❌ [AuthProvider] Erreur lors de la liaison: $e');
          return false;
        }
      } else {
        print('❌ [AuthProvider] Upload échoué: ${response.statusCode}');
        _setError('Échec de l\'upload: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ [AuthProvider] Exception lors de l\'upload: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
