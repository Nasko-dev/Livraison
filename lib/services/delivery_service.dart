import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeliveryService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DeliveryService() {
    _dio.options.baseUrl = 'http://192.168.1.102:1337';
    _dio.options.headers['Authorization'] = 'Bearer 3';

    // Ajout des intercepteurs pour les logs
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('📡 Requête envoyée:');
        print('URL: ${options.uri}');
        print('Méthode: ${options.method}');
        print('Headers: ${options.headers}');
        print('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ Réponse reçue:');
        print('Status: ${response.statusCode}');
        print('Data: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('❌ Erreur:');
        print('Type: ${e.type}');
        print('Message: ${e.message}');
        print('Response: ${e.response?.data}');
        return handler.next(e);
      },
    ));
  }

  Future<void> _setAuthHeader() async {
    final jwt = await _storage.read(key: 'jwt');
    if (jwt != null) {
      print('🔐 Utilisation du JWT stocké');
      _dio.options.headers['Authorization'] = 'Bearer $jwt';
    } else {
      print('🔑 Utilisation du token API par défaut');
      _dio.options.headers['Authorization'] = 'Bearer 3';
    }
  }

  Future<List<Map<String, dynamic>>> getDeliveries() async {
    print('📦 Récupération des livraisons...');
    try {
      await _setAuthHeader();
      final response = await _dio.get('/api/deliveries');
      print('✅ ${response.data['data'].length} livraisons récupérées');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      print('❌ Erreur de récupération des livraisons: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getDeliveryById(String id) async {
    print('🔍 Récupération de la livraison $id...');
    try {
      await _setAuthHeader();
      final response = await _dio.get('/api/deliveries/$id');
      print('✅ Livraison récupérée: ${response.data['data']['id']}');
      return response.data['data'];
    } catch (e) {
      print('❌ Erreur de récupération de la livraison: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createDelivery(
      Map<String, dynamic> data) async {
    print('➕ Création d\'une nouvelle livraison:');
    print('Data: $data');
    try {
      await _setAuthHeader();
      final response = await _dio.post('/api/deliveries', data: {
        'data': data,
      });
      print('✅ Livraison créée: ${response.data['data']['id']}');
      return response.data['data'];
    } catch (e) {
      print('❌ Erreur de création de la livraison: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateDelivery(
      String id, Map<String, dynamic> data) async {
    print('🔄 Mise à jour de la livraison $id:');
    print('Nouvelles données: $data');
    try {
      await _setAuthHeader();
      final response = await _dio.put('/api/deliveries/$id', data: {
        'data': data,
      });
      print('✅ Livraison mise à jour: ${response.data['data']['id']}');
      return response.data['data'];
    } catch (e) {
      print('❌ Erreur de mise à jour de la livraison: $e');
      return null;
    }
  }

  Future<bool> deleteDelivery(String id) async {
    print('🗑️ Suppression de la livraison $id...');
    try {
      await _setAuthHeader();
      await _dio.delete('/api/deliveries/$id');
      print('✅ Livraison supprimée');
      return true;
    } catch (e) {
      print('❌ Erreur de suppression de la livraison: $e');
      return false;
    }
  }
}
