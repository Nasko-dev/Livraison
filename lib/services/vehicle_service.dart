import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;
import '../models/vehicle.dart';

class VehicleService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  VehicleService() {
    _dio.options.baseUrl = 'http://192.168.1.102:1337';

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Récupérer le token JWT
        final token = await _storage.read(key: 'jwt');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';

          // Extraire l'ID utilisateur du token JWT
          try {
            final parts = token.split('.');
            if (parts.length == 3) {
              final payload = parts[1];
              final normalized = base64Url.normalize(payload);
              final decodedPayload = utf8.decode(base64Url.decode(normalized));
              final payloadMap = json.decode(decodedPayload);
              final userId = payloadMap['id'];
              developer.log('🔑 Token JWT - ID Utilisateur: $userId',
                  name: 'VehicleService');
            }
          } catch (e) {
            developer.log('⚠️ Erreur d\'extraction du token: $e',
                name: 'VehicleService');
          }
        }
        developer.log('📡 Requête envoyée: ${options.uri}',
            name: 'VehicleService');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        developer.log('✅ Réponse reçue: ${response.statusCode}',
            name: 'VehicleService');
        return handler.next(response);
      },
      onError: (error, handler) {
        developer.log('❌ Erreur: ${error.message}', name: 'VehicleService');
        return handler.next(error);
      },
    ));
  }

  // Récupérer l'ID utilisateur à partir du token JWT
  Future<int?> _getUserIdFromToken() async {
    try {
      final token = await _storage.read(key: 'jwt');
      if (token == null) return null;

      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decodedPayload = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decodedPayload);

      return payloadMap['id'] as int?;
    } catch (e) {
      developer.log('❌ Erreur lors de l\'extraction de l\'ID: $e',
          name: 'VehicleService');
      return null;
    }
  }

  // Récupérer le véhicule d'un chauffeur
  Future<Vehicle?> getVehicleForChauffeur(int chauffeurId) async {
    try {
      final response = await _dio.get(
        '/api/vehicles/chauffeur/$chauffeurId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data != null ? Vehicle.fromJson(data) : null;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Pas de véhicule trouvé, ce n'est pas une erreur
        return null;
      }
      developer.log(
          '❌ Erreur lors de la récupération du véhicule: ${e.message}',
          name: 'VehicleService');
      throw Exception('Erreur lors de la récupération du véhicule');
    }
  }

  // Récupérer le véhicule d'un utilisateur
  Future<Vehicle?> getVehicleForUser(int userId) async {
    try {
      developer.log('🔍 Récupération du véhicule pour utilisateur ID: $userId',
          name: 'VehicleService');

      // Vérifier si l'ID utilisateur correspond à l'ID du token
      final tokenUserId = await _getUserIdFromToken();
      if (tokenUserId != null && tokenUserId != userId) {
        developer.log(
            '⚠️ L\'ID utilisateur ($userId) ne correspond pas à l\'ID du token ($tokenUserId)',
            name: 'VehicleService');
        developer.log('🔄 Utilisation de l\'ID du token: $tokenUserId',
            name: 'VehicleService');
        userId = tokenUserId;
      }

      final response = await _dio.get(
        '/api/vehicles/user/$userId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          developer.log('✅ Véhicule trouvé pour utilisateur ID: $userId',
              name: 'VehicleService');
        } else {
          developer.log('ℹ️ Aucun véhicule trouvé pour utilisateur ID: $userId',
              name: 'VehicleService');
        }
        return data != null ? Vehicle.fromJson(data) : null;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Pas de véhicule trouvé, ce n'est pas une erreur
        developer.log(
            'ℹ️ Aucun véhicule trouvé pour utilisateur ID: $userId (404)',
            name: 'VehicleService');
        return null;
      }
      developer.log(
          '❌ Erreur lors de la récupération du véhicule: ${e.message}',
          name: 'VehicleService');
      throw Exception('Erreur lors de la récupération du véhicule');
    }
  }

  // Créer un véhicule pour un chauffeur
  Future<Vehicle> createVehicleForChauffeur(
      int chauffeurId, Vehicle vehicle) async {
    try {
      final response = await _dio.post(
        '/api/vehicles/chauffeur/$chauffeurId',
        data: {'data': vehicle.toJson()},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        return Vehicle.fromJson(data);
      }
      throw Exception('Erreur lors de la création du véhicule');
    } on DioException catch (e) {
      developer.log('❌ Erreur lors de la création du véhicule: ${e.message}',
          name: 'VehicleService');
      throw Exception('Erreur lors de la création du véhicule: ${e.message}');
    }
  }

  // Créer ou mettre à jour un véhicule pour un utilisateur
  Future<Vehicle> createOrUpdateVehicleForUser(
      int userId, Vehicle vehicle) async {
    try {
      developer.log(
          '🚗 Création/mise à jour du véhicule pour utilisateur ID: $userId',
          name: 'VehicleService');
      developer.log('📊 Données véhicule: ${jsonEncode(vehicle.toJson())}',
          name: 'VehicleService');

      // Vérifier si l'ID utilisateur correspond à l'ID du token
      final tokenUserId = await _getUserIdFromToken();
      if (tokenUserId != null && tokenUserId != userId) {
        developer.log(
            '⚠️ L\'ID utilisateur ($userId) ne correspond pas à l\'ID du token ($tokenUserId)',
            name: 'VehicleService');
        developer.log('🔄 Utilisation de l\'ID du token: $tokenUserId',
            name: 'VehicleService');
        userId = tokenUserId;
      }

      final response = await _dio.post(
        '/api/vehicles/user/$userId',
        data: {'data': vehicle.toJson()},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log(
            '✅ Véhicule créé/mis à jour avec succès pour utilisateur ID: $userId',
            name: 'VehicleService');
        final data = response.data['data'];
        return Vehicle.fromJson(data);
      }
      throw Exception('Erreur lors de la création/mise à jour du véhicule');
    } on DioException catch (e) {
      developer.log(
          '❌ Erreur lors de la création/mise à jour du véhicule: ${e.message}',
          name: 'VehicleService');
      developer.log('📄 Détails: ${e.response?.data}', name: 'VehicleService');
      throw Exception(
          'Erreur lors de la création/mise à jour du véhicule: ${e.message}');
    }
  }

  // Mettre à jour un véhicule
  Future<Vehicle> updateVehicleForChauffeur(
      int chauffeurId, Vehicle vehicle) async {
    try {
      final response = await _dio.put(
        '/api/vehicles/chauffeur/$chauffeurId',
        data: {'data': vehicle.toJson()},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return Vehicle.fromJson(data);
      }
      throw Exception('Erreur lors de la mise à jour du véhicule');
    } on DioException catch (e) {
      developer.log('❌ Erreur lors de la mise à jour du véhicule: ${e.message}',
          name: 'VehicleService');
      throw Exception(
          'Erreur lors de la mise à jour du véhicule: ${e.message}');
    }
  }
}
