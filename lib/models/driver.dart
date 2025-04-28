import 'dart:convert';
import 'package:livraison/models/vehicle.dart';

enum DriverStatus { active, inactive, pending, blocked }

extension DriverStatusExtension on DriverStatus {
  String get value {
    switch (this) {
      case DriverStatus.active:
        return 'active';
      case DriverStatus.inactive:
        return 'inactive';
      case DriverStatus.pending:
        return 'pending';
      case DriverStatus.blocked:
        return 'blocked';
    }
  }

  static DriverStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return DriverStatus.active;
      case 'inactive':
        return DriverStatus.inactive;
      case 'pending':
        return DriverStatus.pending;
      case 'blocked':
        return DriverStatus.blocked;
      default:
        return DriverStatus.pending;
    }
  }
}

class Driver {
  final int id;
  final int userId;
  final String name;
  final String surname;
  final String phone;
  final String email;
  final String address;
  final String status;
  final String vehicleType;
  final Vehicle? vehicle;
  final Map<String, bool> documents;
  final Map<String, dynamic> preferences;
  final String? code;
  final String? createdAt;
  final String? updatedAt;

  Driver({
    required this.id,
    required this.userId,
    required this.name,
    required this.surname,
    required this.phone,
    required this.email,
    required this.address,
    required this.status,
    required this.vehicleType,
    this.vehicle,
    required this.documents,
    required this.preferences,
    this.code,
    this.createdAt,
    this.updatedAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? 'pending',
      vehicleType: json['vehicleType']?.toString() ?? 'voiture',
      vehicle:
          json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      code: json['code'],
      documents: (json['documents'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as bool),
          ) ??
          {
            'identity': false,
            'license': false,
            'insurance': false,
            'siren': false
          },
      preferences: json['preferences'] as Map<String, dynamic>? ??
          {'notifications': true, 'darkMode': false, 'language': 'fr'},
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'userId': userId,
      'name': name,
      'surname': surname,
      'phone': phone,
      'email': email,
      'address': address,
      'status': status,
      'vehicleType': vehicleType,
      'documents': documents,
      'preferences': preferences,
    };

    if (code != null) data['code'] = code;
    if (vehicle != null) data['vehicle'] = vehicle!.toJson();
    if (createdAt != null) data['createdAt'] = createdAt;
    if (updatedAt != null) data['updatedAt'] = updatedAt;

    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  Driver copyWith({
    int? id,
    int? userId,
    String? name,
    String? surname,
    String? phone,
    String? email,
    String? address,
    String? status,
    String? vehicleType,
    Vehicle? vehicle,
    Map<String, bool>? documents,
    Map<String, dynamic>? preferences,
    String? code,
    String? createdAt,
    String? updatedAt,
  }) {
    return Driver(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      status: status ?? this.status,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicle: vehicle ?? this.vehicle,
      documents: documents ?? this.documents,
      preferences: preferences ?? this.preferences,
      code: code ?? this.code,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Driver{id: $id, userId: $userId, name: $name, surname: $surname, phone: $phone, status: $status}';
  }
}
