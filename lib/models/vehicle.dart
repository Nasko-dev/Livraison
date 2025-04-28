import 'dart:convert';

class Vehicle {
  final int? id;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final String color;
  final String vehicleType;
  final Map<String, dynamic>? insuranceInfo;
  final DateTime? technicalInspection;
  final double? maxWeight;
  final double? maxVolume;
  final int? chauffeurId;

  Vehicle({
    this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.color,
    required this.vehicleType,
    this.insuranceInfo,
    this.technicalInspection,
    this.maxWeight,
    this.maxVolume,
    this.chauffeurId,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      make: json['attributes']['make'] ?? '',
      model: json['attributes']['model'] ?? '',
      year: json['attributes']['year'] ?? 0,
      licensePlate: json['attributes']['licensePlate'] ?? '',
      color: json['attributes']['color'] ?? '',
      vehicleType: json['attributes']['vehicleType'] ?? 'voiture',
      insuranceInfo: json['attributes']['insuranceInfo'],
      technicalInspection: json['attributes']['technicalInspection'] != null
          ? DateTime.parse(json['attributes']['technicalInspection'])
          : null,
      maxWeight: json['attributes']['maxWeight'] != null
          ? double.tryParse(json['attributes']['maxWeight'].toString())
          : null,
      maxVolume: json['attributes']['maxVolume'] != null
          ? double.tryParse(json['attributes']['maxVolume'].toString())
          : null,
      chauffeurId: json['attributes']['chauffeur'] != null
          ? json['attributes']['chauffeur']['data']['id']
          : null,
    );
  }

  factory Vehicle.fromRawJson(String str) => Vehicle.fromJson(json.decode(str));

  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'licensePlate': licensePlate,
      'color': color,
      'vehicleType': vehicleType,
      'insuranceInfo': insuranceInfo,
      'technicalInspection': technicalInspection?.toIso8601String(),
      'maxWeight': maxWeight,
      'maxVolume': maxVolume,
      'chauffeur': chauffeurId != null ? {'id': chauffeurId} : null,
    };
  }

  String toRawJson() => json.encode(toJson());

  Vehicle copyWith({
    int? id,
    String? make,
    String? model,
    int? year,
    String? licensePlate,
    String? color,
    String? vehicleType,
    Map<String, dynamic>? insuranceInfo,
    DateTime? technicalInspection,
    double? maxWeight,
    double? maxVolume,
    int? chauffeurId,
  }) {
    return Vehicle(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      color: color ?? this.color,
      vehicleType: vehicleType ?? this.vehicleType,
      insuranceInfo: insuranceInfo ?? this.insuranceInfo,
      technicalInspection: technicalInspection ?? this.technicalInspection,
      maxWeight: maxWeight ?? this.maxWeight,
      maxVolume: maxVolume ?? this.maxVolume,
      chauffeurId: chauffeurId ?? this.chauffeurId,
    );
  }
}
