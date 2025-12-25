import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import '../models/emergency_contact.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== USER OPERATIONS =====
  
  // Create user profile
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  // ===== REPORT OPERATIONS =====

  // Create report
  Future<String?> createReport(ReportModel report) async {
    try {
      final docRef = await _firestore.collection('reports').add(report.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating report: $e');
      return null;
    }
  }

  // Get all reports
  Stream<List<ReportModel>> getReports() {
    return _firestore
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get reports by user
  Stream<List<ReportModel>> getUserReports(String userId) {
    return _firestore
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get reports by category
  Stream<List<ReportModel>> getReportsByCategory(ReportCategory category) {
    return _firestore
        .collection('reports')
        .where('category', isEqualTo: category.toString().split('.').last)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get nearby reports
  Future<List<ReportModel>> getNearbyReports({
    required double latitude,
    required double longitude,
    double radiusInKm = 5.0,
  }) async {
    try {
      // Simple bounding box query (for production, use GeoFlutterFire)
      final latDelta = radiusInKm / 111.0; // Rough conversion
      final lngDelta = radiusInKm / (111.0 * 0.9); // Adjusted for latitude

      final snapshot = await _firestore
          .collection('reports')
          .where('latitude', isGreaterThan: latitude - latDelta)
          .where('latitude', isLessThan: latitude + latDelta)
          .get();

      return snapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
          .where((report) {
            final lngDiff = (report.longitude - longitude).abs();
            return lngDiff < lngDelta;
          })
          .toList();
    } catch (e) {
      debugPrint('Error getting nearby reports: $e');
      return [];
    }
  }

  // Upvote report
  Future<void> upvoteReport(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'upvotes': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error upvoting report: $e');
    }
  }

  // Update report status
  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      debugPrint('Error updating report status: $e');
    }
  }

  // ===== EMERGENCY CONTACTS =====

  // Save emergency contacts
  Future<void> saveEmergencyContacts(
    String userId,
    List<EmergencyContact> contacts,
  ) async {
    try {
      final contactsData = contacts.map((c) => c.toMap()).toList();
      await _firestore.collection('users').doc(userId).update({
        'emergencyContacts': contactsData,
      });
    } catch (e) {
      debugPrint('Error saving emergency contacts: $e');
      rethrow;
    }
  }

  // Get emergency contacts
  Future<List<EmergencyContact>> getEmergencyContacts(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['emergencyContacts'] != null) {
          final contactsList = data['emergencyContacts'] as List;
          return contactsList
              .map((c) => EmergencyContact.fromMap(c))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting emergency contacts: $e');
      return [];
    }
  }

  // ===== SAFETY ZONES =====

  // Create safety zone
  Future<void> createSafetyZone({
    required double latitude,
    required double longitude,
    required double radius,
    required bool isSafe,
    String? description,
  }) async {
    try {
      await _firestore.collection('safety_zones').add({
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'isSafe': isSafe,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating safety zone: $e');
    }
  }

  // Get all safety zones
  Stream<List<Map<String, dynamic>>> getSafetyZones() {
    return _firestore.collection('safety_zones').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
