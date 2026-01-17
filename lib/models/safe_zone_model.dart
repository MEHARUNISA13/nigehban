import 'package:cloud_firestore/cloud_firestore.dart';

enum SafeZoneType {
  policeStation,
  hospital,
  safeHouse,
  publicArea,
  other,
}

class SafeZoneModel {
  final String id;
  final String name;
  final SafeZoneType type;
  final double latitude;
  final double longitude;
  final String? address;
  final String? contactNumber;
  final String? operatingHours;
  final List<String> services;
  final bool isVerified;

  SafeZoneModel({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.address,
    this.contactNumber,
    this.operatingHours,
    this.services = const [],
    this.isVerified = false,
  });

  factory SafeZoneModel.fromMap(Map<String, dynamic> data, String documentId) {
    final GeoPoint? location = data['location'] as GeoPoint?;
    
    return SafeZoneModel(
      id: documentId,
      name: data['name'] ?? '',
      type: _parseSafeZoneType(data['type']),
      latitude: location?.latitude ?? 0.0,
      longitude: location?.longitude ?? 0.0,
      address: data['address'],
      contactNumber: data['contactNumber'],
      operatingHours: data['operatingHours'],
      services: List<String>.from(data['services'] ?? []),
      isVerified: data['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.name,
      'location': GeoPoint(latitude, longitude),
      'address': address,
      'contactNumber': contactNumber,
      'operatingHours': operatingHours,
      'services': services,
      'isVerified': isVerified,
    };
  }

  static SafeZoneType _parseSafeZoneType(dynamic value) {
    if (value == null) return SafeZoneType.other;
    try {
      return SafeZoneType.values.firstWhere(
        (e) => e.name == value.toString(),
        orElse: () => SafeZoneType.other,
      );
    } catch (e) {
      return SafeZoneType.other;
    }
  }

  String get typeDisplayName {
    switch (type) {
      case SafeZoneType.policeStation:
        return 'Police Station';
      case SafeZoneType.hospital:
        return 'Hospital';
      case SafeZoneType.safeHouse:
        return 'Safe House';
      case SafeZoneType.publicArea:
        return 'Public Area';
      case SafeZoneType.other:
        return 'Other';
    }
  }
}
