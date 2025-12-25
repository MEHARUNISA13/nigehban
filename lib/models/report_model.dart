import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportSeverity { low, medium, high, critical }
enum ReportStatus { pending, verified, rejected, resolved }
enum ReportCategory { harassment, theft, assault, suspicious, lighting, accident, other }

class ReportModel {
  final String id;
  final String userId;
  final String? userName; // Denormalized for simpler display
  final double latitude;
  final double longitude;
  final String description;
  final ReportCategory category;
  final ReportSeverity severity;
  final ReportStatus status;
  final String? imageUrl;
  final DateTime timestamp;
  final int upvotes;

  ReportModel({
    required this.id,
    required this.userId,
    this.userName,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.category,
    required this.severity,
    this.status = ReportStatus.pending,
    this.imageUrl,
    required this.timestamp,
    this.upvotes = 0,
  });

  factory ReportModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ReportModel(
      id: documentId,
      userId: data['userId'] ?? '',
      userName: data['userName'],
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      description: data['description'] ?? '',
      category: ReportCategory.values.firstWhere(
        (e) => e.toString() == 'ReportCategory.${data['category']}',
        orElse: () => ReportCategory.other,
      ),
      severity: ReportSeverity.values.firstWhere(
        (e) => e.toString() == 'ReportSeverity.${data['severity']}',
        orElse: () => ReportSeverity.medium,
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString() == 'ReportStatus.${data['status']}',
        orElse: () => ReportStatus.pending,
      ),
      imageUrl: data['imageUrl'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      upvotes: data['upvotes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'category': category.toString().split('.').last,
      'severity': severity.toString().split('.').last,
      'status': status.toString().split('.').last,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'upvotes': upvotes,
    };
  }
}
