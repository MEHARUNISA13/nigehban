import 'package:cloud_firestore/cloud_firestore.dart';

enum IncidentType {
  harassment,
  theft,
  assault,
  suspiciousActivity,
  other,
}

enum IncidentSeverity {
  low,
  medium,
  high,
  critical,
}

class IncidentModel {
  final String id;
  final IncidentType type;
  final double latitude;
  final double longitude;
  final String? address;
  final IncidentSeverity severity;
  final String description;
  final DateTime timestamp;
  final String reportedBy;
  final bool verified;
  final int verificationCount;
  final String? imageUrl;

  IncidentModel({
    required this.id,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.severity,
    required this.description,
    required this.timestamp,
    required this.reportedBy,
    this.verified = false,
    this.verificationCount = 0,
    this.imageUrl,
  });

  factory IncidentModel.fromMap(Map<String, dynamic> data, String documentId) {
    final GeoPoint? location = data['location'] as GeoPoint?;
    
    return IncidentModel(
      id: documentId,
      type: _parseIncidentType(data['type']),
      latitude: location?.latitude ?? 0.0,
      longitude: location?.longitude ?? 0.0,
      address: data['address'],
      severity: _parseSeverity(data['severity']),
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reportedBy: data['reportedBy'] ?? '',
      verified: data['verified'] ?? false,
      verificationCount: data['verificationCount'] ?? 0,
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'location': GeoPoint(latitude, longitude),
      'address': address,
      'severity': severity.name,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'reportedBy': reportedBy,
      'verified': verified,
      'verificationCount': verificationCount,
      'imageUrl': imageUrl,
    };
  }

  static IncidentType _parseIncidentType(dynamic value) {
    if (value == null) return IncidentType.other;
    try {
      return IncidentType.values.firstWhere(
        (e) => e.name == value.toString(),
        orElse: () => IncidentType.other,
      );
    } catch (e) {
      return IncidentType.other;
    }
  }

  static IncidentSeverity _parseSeverity(dynamic value) {
    if (value == null) return IncidentSeverity.low;
    try {
      return IncidentSeverity.values.firstWhere(
        (e) => e.name == value.toString(),
        orElse: () => IncidentSeverity.low,
      );
    } catch (e) {
      return IncidentSeverity.low;
    }
  }

  String get typeDisplayName {
    switch (type) {
      case IncidentType.harassment:
        return 'Harassment';
      case IncidentType.theft:
        return 'Theft';
      case IncidentType.assault:
        return 'Assault';
      case IncidentType.suspiciousActivity:
        return 'Suspicious Activity';
      case IncidentType.other:
        return 'Other';
    }
  }

  String get severityDisplayName {
    switch (severity) {
      case IncidentSeverity.low:
        return 'Low';
      case IncidentSeverity.medium:
        return 'Medium';
      case IncidentSeverity.high:
        return 'High';
      case IncidentSeverity.critical:
        return 'Critical';
    }
  }
}
