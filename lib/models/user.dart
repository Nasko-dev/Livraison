import 'driver.dart';

class User {
  final int id;
  final String name;
  final String surname;
  final String phone;
  final String email;
  final String address;
  final String vehicleType;
  final String status;
  final String? code;
  final Map<String, bool> documents;
  final Map<String, dynamic> preferences;
  final String createdAt;
  final String updatedAt;
  final Driver? chauffeur;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.surname,
    required this.phone,
    required this.email,
    required this.address,
    required this.vehicleType,
    required this.status,
    this.code,
    required this.documents,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
    this.chauffeur,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Extraire les données de l'objet data si présent
    final data = json['data'] ?? json;

    try {
      // Récupérer le code depuis chauffeur si disponible
      String? code;
      if (data['chauffeur'] != null && data['chauffeur']['code'] != null) {
        code = data['chauffeur']['code'];
      } else if (data['code'] != null) {
        code = data['code'];
      }

      // Convertir correctement l'id en int
      int id;
      if (data['id'] is String) {
        id = int.tryParse(data['id']) ?? 0;
      } else {
        id = data['id'] ?? 0;
      }

      // Sécuriser l'accès aux documents et préférences
      Map<String, bool> docs = {};
      if (data['documents'] is Map) {
        try {
          docs = (data['documents'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, value as bool),
          );
        } catch (e) {
          print('⚠️ Erreur lors de la conversion des documents: $e');
          docs = {
            'identity': false,
            'license': false,
            'insurance': false,
            'siren': false
          };
        }
      } else {
        docs = {
          'identity': false,
          'license': false,
          'insurance': false,
          'siren': false
        };
      }

      // Sécuriser l'accès aux préférences
      Map<String, dynamic> prefs = {};
      if (data['preferences'] is Map) {
        prefs = Map<String, dynamic>.from(data['preferences']);
      } else {
        prefs = {'notifications': true, 'darkMode': false, 'language': 'fr'};
      }

      // Convertir vehicleType
      String vehicleType = 'car';
      if (data['vehicleType'] != null) {
        vehicleType = data['vehicleType'].toString().toLowerCase();
        // Conversion des types en français vers l'anglais
        if (vehicleType == 'voiture')
          vehicleType = 'car';
        else if (vehicleType == 'velo')
          vehicleType = 'bike';
        else if (vehicleType == 'scooter')
          vehicleType = 'scooter';
        else if (vehicleType == 'camion') vehicleType = 'truck';
      }

      // Récupérer les données du chauffeur si disponibles
      Driver? chauffeur;
      if (data['chauffeur'] != null) {
        chauffeur = Driver.fromJson(data['chauffeur']);
      }

      return User(
        id: id,
        name: data['name']?.toString() ?? '',
        surname: data['surname']?.toString() ?? '',
        phone: data['phone']?.toString() ?? '',
        email: data['email']?.toString() ?? '',
        address: data['address']?.toString() ?? '',
        vehicleType: vehicleType,
        status: data['status']?.toString() ?? 'pending',
        code: code,
        documents: docs,
        preferences: prefs,
        createdAt: data['createdAt']?.toString() ?? '',
        updatedAt: data['updatedAt']?.toString() ?? '',
        chauffeur: chauffeur,
        avatarUrl:
            data['avatar'] != null ? data['avatar']['url'] as String : null,
      );
    } catch (e) {
      print('❌ Erreur lors de la conversion User.fromJson: $e');
      print('🔍 Données brutes: $json');

      // Créer un utilisateur avec des valeurs par défaut minimales
      return User(
        id: 0,
        name: json['name']?.toString() ?? '',
        surname: json['surname']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        address: '',
        vehicleType: 'car',
        status: 'pending',
        documents: {
          'identity': false,
          'license': false,
          'insurance': false,
          'siren': false
        },
        preferences: {
          'notifications': true,
          'darkMode': false,
          'language': 'fr'
        },
        createdAt: '',
        updatedAt: '',
        chauffeur: null,
        avatarUrl: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    final data = {
      'id': id,
      'name': name,
      'surname': surname,
      'phone': phone,
      'email': email,
      'address': address,
      'vehicleType': vehicleType,
      'status': status,
      'code': code,
      'documents': documents,
      'preferences': preferences,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };

    if (chauffeur != null) {
      data['chauffeur'] = chauffeur!.toJson();
    }

    if (avatarUrl != null) {
      data['avatarUrl'] = avatarUrl;
    }

    return data;
  }

  User copyWith({
    int? id,
    String? name,
    String? surname,
    String? phone,
    String? email,
    String? address,
    String? vehicleType,
    String? status,
    String? code,
    Map<String, bool>? documents,
    Map<String, dynamic>? preferences,
    String? createdAt,
    String? updatedAt,
    Driver? chauffeur,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      vehicleType: vehicleType ?? this.vehicleType,
      status: status ?? this.status,
      code: code ?? this.code,
      documents: documents ?? this.documents,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      chauffeur: chauffeur ?? this.chauffeur,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
