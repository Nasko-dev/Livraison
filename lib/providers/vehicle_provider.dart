import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class VehicleProvider extends ChangeNotifier {
  final VehicleService _vehicleService = VehicleService();
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Vehicle? _vehicle;
  bool _isLoading = false;
  String? _error;

  Vehicle? get vehicle => _vehicle;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasVehicle => _vehicle != null;

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

  // Récupérer le véhicule d'un chauffeur
  Future<void> loadVehicleForChauffeur(int chauffeurId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vehicle = await _vehicleService.getVehicleForChauffeur(chauffeurId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Récupérer le véhicule d'un utilisateur
  Future<void> loadVehicleForUser(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      developer.log('🔄 Chargement du véhicule pour l\'utilisateur $userId',
          name: 'VehicleProvider');

      final jwt = await _storage.read(key: 'jwt');
      if (jwt == null) {
        _setError('Non authentifié');
        return;
      }

      final response = await _dio.get(
        '/api/vehicles/find-by-user/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer $jwt'},
        ),
      );

      developer.log('📊 Réponse API: ${response.statusCode}',
          name: 'VehicleProvider');
      developer.log('📦 Données reçues: ${response.data}',
          name: 'VehicleProvider');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          _vehicle = Vehicle.fromJson(data);
          developer.log('✅ Véhicule chargé: ${_vehicle?.toJson()}',
              name: 'VehicleProvider');
        } else {
          developer.log('ℹ️ Aucun véhicule trouvé pour cet utilisateur',
              name: 'VehicleProvider');
          _vehicle = null;
        }
      } else {
        developer.log('❌ Erreur de chargement: ${response.statusCode}',
            name: 'VehicleProvider');
        _setError('Erreur lors du chargement du véhicule');
      }
    } catch (e) {
      developer.log('❌ Exception lors du chargement: $e',
          name: 'VehicleProvider');
      _setError(e.toString());
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Créer un véhicule pour un chauffeur
  Future<bool> createVehicle(int chauffeurId, Vehicle vehicle) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vehicle =
          await _vehicleService.createVehicleForChauffeur(chauffeurId, vehicle);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Créer ou mettre à jour un véhicule pour un utilisateur
  Future<bool> createOrUpdateVehicleForUser(
      String userId, Map<String, dynamic> vehicleData) async {
    try {
      _setLoading(true);
      _clearError();
      developer.log(
          '🔄 Création/mise à jour du véhicule pour l\'utilisateur $userId',
          name: 'VehicleProvider');
      developer.log('📦 Données à envoyer: $vehicleData',
          name: 'VehicleProvider');

      final jwt = await _storage.read(key: 'jwt');
      if (jwt == null) {
        _setError('Non authentifié');
        return false;
      }

      final response = await _dio.post(
        '/api/vehicles/create-or-update-by-user/$userId',
        data: {'data': vehicleData},
        options: Options(
          headers: {'Authorization': 'Bearer $jwt'},
        ),
      );

      developer.log('📊 Réponse API: ${response.statusCode}',
          name: 'VehicleProvider');
      developer.log('📦 Données reçues: ${response.data}',
          name: 'VehicleProvider');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          _vehicle = Vehicle.fromJson(data);
          developer.log('✅ Véhicule mis à jour: ${_vehicle?.toJson()}',
              name: 'VehicleProvider');
          notifyListeners();
          return true;
        }
      }

      developer.log('❌ Erreur lors de la mise à jour: ${response.statusCode}',
          name: 'VehicleProvider');
      _setError('Erreur lors de la mise à jour du véhicule');
      return false;
    } catch (e) {
      developer.log('❌ Exception lors de la mise à jour: $e',
          name: 'VehicleProvider');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mettre à jour un véhicule
  Future<bool> updateVehicle(int chauffeurId, Vehicle vehicle) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vehicle =
          await _vehicleService.updateVehicleForChauffeur(chauffeurId, vehicle);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Réinitialiser les erreurs
  void resetError() {
    _error = null;
    notifyListeners();
  }
}
