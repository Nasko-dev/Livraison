import 'dart:convert';
import 'package:livraison/models/driver.dart';

enum DeliveryStatus { en_attente, en_cours, livree, annulee }

extension DeliveryStatusExtension on DeliveryStatus {
  String get value {
    switch (this) {
      case DeliveryStatus.en_attente:
        return 'en_attente';
      case DeliveryStatus.en_cours:
        return 'en_cours';
      case DeliveryStatus.livree:
        return 'livree';
      case DeliveryStatus.annulee:
        return 'annulee';
    }
  }

  static DeliveryStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'en_attente':
        return DeliveryStatus.en_attente;
      case 'en_cours':
        return DeliveryStatus.en_cours;
      case 'livree':
        return DeliveryStatus.livree;
      case 'annulee':
        return DeliveryStatus.annulee;
      default:
        return DeliveryStatus.en_attente;
    }
  }
}

class Delivery {
  final int id;
  final String reference;
  final String title;
  final String? description;
  final String status;
  final String pickupAddress;
  final String deliveryAddress;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final double? weight;
  final double? volume;
  final double price;
  final String clientName;
  final String clientPhone;
  final String? clientEmail;
  final Driver? chauffeur;
  final String? imageUrl;
  final List<String>? documents;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;
  final String? publishedAt;

  Delivery({
    required this.id,
    required this.reference,
    required this.title,
    this.description,
    required this.status,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.scheduledDate,
    this.completedDate,
    this.weight,
    this.volume,
    required this.price,
    required this.clientName,
    required this.clientPhone,
    this.clientEmail,
    this.chauffeur,
    this.imageUrl,
    this.documents,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    var data = json['attributes'] ?? json;

    return Delivery(
      id: json['id'] ?? 0,
      reference: data['reference'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      status: data['status'] ?? 'en_attente',
      pickupAddress: data['pickupAddress'] ?? '',
      deliveryAddress: data['deliveryAddress'] ?? '',
      scheduledDate: data['scheduledDate'] != null
          ? DateTime.parse(data['scheduledDate'])
          : DateTime.now(),
      completedDate: data['completedDate'] != null
          ? DateTime.parse(data['completedDate'])
          : null,
      weight: data['weight'] != null
          ? double.parse(data['weight'].toString())
          : null,
      volume: data['volume'] != null
          ? double.parse(data['volume'].toString())
          : null,
      price:
          data['price'] != null ? double.parse(data['price'].toString()) : 0.0,
      clientName: data['clientName'] ?? '',
      clientPhone: data['clientPhone'] ?? '',
      clientEmail: data['clientEmail'],
      chauffeur: data['chauffeur'] != null && data['chauffeur']['data'] != null
          ? Driver.fromJson(data['chauffeur']['data'])
          : null,
      imageUrl: data['image'] != null && data['image']['data'] != null
          ? data['image']['data']['attributes']['url']
          : null,
      documents: data['documents'] != null && data['documents']['data'] != null
          ? List<String>.from(
              data['documents']['data'].map((doc) => doc['attributes']['url']))
          : null,
      notes: data['notes'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      publishedAt: data['publishedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'reference': reference,
      'title': title,
      'status': status,
      'pickupAddress': pickupAddress,
      'deliveryAddress': deliveryAddress,
      'scheduledDate': scheduledDate.toIso8601String(),
      'price': price,
      'clientName': clientName,
      'clientPhone': clientPhone,
    };

    if (id != 0) data['id'] = id;
    if (description != null) data['description'] = description;
    if (completedDate != null)
      data['completedDate'] = completedDate!.toIso8601String();
    if (weight != null) data['weight'] = weight;
    if (volume != null) data['volume'] = volume;
    if (clientEmail != null) data['clientEmail'] = clientEmail;
    if (notes != null) data['notes'] = notes;

    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  Delivery copyWith({
    int? id,
    String? reference,
    String? title,
    String? description,
    String? status,
    String? pickupAddress,
    String? deliveryAddress,
    DateTime? scheduledDate,
    DateTime? completedDate,
    double? weight,
    double? volume,
    double? price,
    String? clientName,
    String? clientPhone,
    String? clientEmail,
    Driver? chauffeur,
    String? imageUrl,
    List<String>? documents,
    String? notes,
    String? createdAt,
    String? updatedAt,
    String? publishedAt,
  }) {
    return Delivery(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      weight: weight ?? this.weight,
      volume: volume ?? this.volume,
      price: price ?? this.price,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      clientEmail: clientEmail ?? this.clientEmail,
      chauffeur: chauffeur ?? this.chauffeur,
      imageUrl: imageUrl ?? this.imageUrl,
      documents: documents ?? this.documents,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  @override
  String toString() {
    return 'Delivery{id: $id, reference: $reference, title: $title, status: $status}';
  }
}
