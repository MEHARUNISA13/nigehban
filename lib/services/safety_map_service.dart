import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import '../models/incident_model.dart';
import '../models/safe_zone_model.dart';

class SafetyMapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _incidentsCollection = 'incidents';
  static const String _safeZonesCollection = 'safeZones';

  // Fetch incidents within a geographic area
  Future<List<IncidentModel>> getIncidentsInArea({
    required double centerLat,
    required double centerLng,
    double radiusInKm = 5.0,
  }) async {
    try {
      // Calculate approximate bounds (simple box approximation)
      final latDelta = radiusInKm / 111.0; // 1 degree lat ≈ 111 km
      final lngDelta = radiusInKm / (111.0 * cos(centerLat * pi / 180));

      final QuerySnapshot snapshot = await _firestore
          .collection(_incidentsCollection)
          .where('location',
              isGreaterThan: GeoPoint(centerLat - latDelta, centerLng - lngDelta))
          .where('location',
              isLessThan: GeoPoint(centerLat + latDelta, centerLng + lngDelta))
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => IncidentModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error fetching incidents: $e');
      // Fallback: get all recent incidents
      return await getAllRecentIncidents();
    }
  }

  // Get all recent incidents (fallback method)
  Future<List<IncidentModel>> getAllRecentIncidents({int limit = 100}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_incidentsCollection)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => IncidentModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all incidents: $e');
      return [];
    }
  }

  // Submit a new incident report
  Future<bool> reportIncident(IncidentModel incident) async {
    try {
      await _firestore.collection(_incidentsCollection).add(incident.toMap());
      return true;
    } catch (e) {
      debugPrint('Error reporting incident: $e');
      return false;
    }
  }

  // Get all safe zones
  Future<List<SafeZoneModel>> getAllSafeZones() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection(_safeZonesCollection).get();

      return snapshot.docs
          .map((doc) => SafeZoneModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error fetching safe zones: $e');
      return [];
    }
  }

  // Get safe zones within area
  Future<List<SafeZoneModel>> getSafeZonesInArea({
    required double centerLat,
    required double centerLng,
    double radiusInKm = 10.0,
  }) async {
    try {
      final allZones = await getAllSafeZones();
      
      // Filter by distance
      return allZones.where((zone) {
        final distance = _calculateDistance(
          centerLat,
          centerLng,
          zone.latitude,
          zone.longitude,
        );
        return distance <= radiusInKm * 1000; // Convert km to meters
      }).toList();
    } catch (e) {
      debugPrint('Error fetching safe zones in area: $e');
      return [];
    }
  }

  // Search for a location by address
  Future<Map<String, double>?> searchLocation(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return {
          'latitude': locations.first.latitude,
          'longitude': locations.first.longitude,
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error searching location: $e');
      return null;
    }
  }

  // Get address from coordinates
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}';
      }
      return 'Unknown location';
    } catch (e) {
      debugPrint('Error getting address: $e');
      return 'Location: $lat, $lng';
    }
  }

  // Calculate safety score for a route or area with improved algorithm
  Future<double> calculateSafetyScore({
    required double lat,
    required double lng,
    double radiusInKm = 1.0,
  }) async {
    try {
      final incidents = await getIncidentsInArea(
        centerLat: lat,
        centerLng: lng,
        radiusInKm: radiusInKm,
      );

      final safeZones = await getSafeZonesInArea(
        centerLat: lat,
        centerLng: lng,
        radiusInKm: radiusInKm,
      );

      // If no data available, return neutral score with message
      if (incidents.isEmpty && safeZones.isEmpty) {
        debugPrint('No safety data available for this area');
        return 50.0; // Neutral score when no data
      }

      // Start with baseline score of 75 (moderately safe)
      double score = 75.0;

      // Deduct points for incidents with time decay and distance weighting
      final now = DateTime.now();
      for (var incident in incidents) {
        // Calculate distance from center point
        final distance = _calculateDistance(
          lat,
          lng,
          incident.latitude,
          incident.longitude,
        );

        // Distance weight: closer incidents have more impact (0.5 to 1.0)
        final distanceWeight = 1.0 - (distance / (radiusInKm * 1000)).clamp(0.0, 0.5);

        // Time decay: incidents lose impact over time
        final daysSinceIncident = now.difference(incident.timestamp).inDays;
        double timeDecay = 1.0;
        if (daysSinceIncident > 30) {
          timeDecay = 0.3; // 30+ days old: 30% impact
        } else if (daysSinceIncident > 14) {
          timeDecay = 0.5; // 14-30 days old: 50% impact
        } else if (daysSinceIncident > 7) {
          timeDecay = 0.7; // 7-14 days old: 70% impact
        } else {
          timeDecay = 1.0; // 0-7 days old: full impact
        }

        // Base severity points
        double severityPoints = 0;
        switch (incident.severity) {
          case IncidentSeverity.critical:
            severityPoints = 20;
            break;
          case IncidentSeverity.high:
            severityPoints = 15;
            break;
          case IncidentSeverity.medium:
            severityPoints = 8;
            break;
          case IncidentSeverity.low:
            severityPoints = 3;
            break;
        }

        // Apply weights
        final impactPoints = severityPoints * distanceWeight * timeDecay;
        score -= impactPoints;

        debugPrint(
          'Incident impact: ${incident.type.name} - '
          'Base: $severityPoints, Distance: ${distanceWeight.toStringAsFixed(2)}, '
          'Time: ${timeDecay.toStringAsFixed(2)}, Final: ${impactPoints.toStringAsFixed(2)}'
        );
      }

      // Add points for safe zones with distance weighting
      for (var zone in safeZones) {
        final distance = _calculateDistance(
          lat,
          lng,
          zone.latitude,
          zone.longitude,
        );

        // Closer safe zones add more points
        final distanceWeight = 1.0 - (distance / (radiusInKm * 1000)).clamp(0.0, 0.5);
        
        // Different zone types have different safety values
        double zoneValue = 5.0;
        switch (zone.type) {
          case SafeZoneType.policeStation:
            zoneValue = 8.0;
            break;
          case SafeZoneType.hospital:
            zoneValue = 6.0;
            break;
          case SafeZoneType.safeHouse:
            zoneValue = 7.0;
            break;
          case SafeZoneType.publicArea:
            zoneValue = 4.0;
            break;
          case SafeZoneType.other:
            zoneValue = 3.0;
            break;
        }

        score += zoneValue * distanceWeight;
      }

      // Ensure score is between 0 and 100
      final finalScore = score.clamp(0.0, 100.0);
      
      debugPrint(
        'Safety Score Calculation: '
        'Incidents: ${incidents.length}, Safe Zones: ${safeZones.length}, '
        'Final Score: ${finalScore.toStringAsFixed(1)}'
      );

      return finalScore;
    } catch (e) {
      debugPrint('Error calculating safety score: $e');
      return 50.0; // Default neutral score on error
    }
  }

  // Helper: Calculate distance between two points
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371000; // meters
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;
}
