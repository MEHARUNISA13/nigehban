import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/incident_model.dart';
import '../models/safe_zone_model.dart';

class DataSeedingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Seed sample data for testing and demo
  Future<Map<String, int>> seedSampleData() async {
    int incidentsSeeded = 0;
    int safeZonesSeeded = 0;

    try {
      debugPrint('Starting data seeding...');

      // Seed incidents for major cities
      incidentsSeeded += await _seedIslamabadIncidents();
      incidentsSeeded += await _seedKarachiIncidents();
      incidentsSeeded += await _seedLahoreIncidents();

      // Seed safe zones
      safeZonesSeeded += await _seedIslamabadSafeZones();
      safeZonesSeeded += await _seedKarachiSafeZones();
      safeZonesSeeded += await _seedLahoreSafeZones();

      debugPrint('Data seeding completed: $incidentsSeeded incidents, $safeZonesSeeded safe zones');

      return {
        'incidents': incidentsSeeded,
        'safeZones': safeZonesSeeded,
      };
    } catch (e) {
      debugPrint('Error seeding data: $e');
      return {
        'incidents': incidentsSeeded,
        'safeZones': safeZonesSeeded,
      };
    }
  }

  // Islamabad Incidents
  Future<int> _seedIslamabadIncidents() async {
    final incidents = [
      // Blue Area - Commercial district
      _createIncident(
        lat: 33.7181,
        lng: 73.0776,
        type: IncidentType.theft,
        severity: IncidentSeverity.medium,
        description: 'Mobile phone snatching reported near Jinnah Super',
        daysAgo: 5,
      ),
      _createIncident(
        lat: 33.7195,
        lng: 73.0765,
        type: IncidentType.theft,
        severity: IncidentSeverity.high,
        description: 'Vehicle theft in Blue Area parking',
        daysAgo: 12,
      ),
      
      // F-7 Markaz
      _createIncident(
        lat: 33.7294,
        lng: 73.0479,
        type: IncidentType.harassment,
        severity: IncidentSeverity.high,
        description: 'Harassment incident reported in F-7 Markaz',
        daysAgo: 8,
      ),
      
      // I-8 Markaz
      _createIncident(
        lat: 33.6663,
        lng: 73.0758,
        type: IncidentType.theft,
        severity: IncidentSeverity.high,
        description: 'Car break-in at I-8 Markaz',
        daysAgo: 15,
      ),
      _createIncident(
        lat: 33.6670,
        lng: 73.0770,
        type: IncidentType.suspiciousActivity,
        severity: IncidentSeverity.medium,
        description: 'Suspicious individuals loitering',
        daysAgo: 3,
      ),
      
      // Aabpara Market
      _createIncident(
        lat: 33.7255,
        lng: 73.0638,
        type: IncidentType.theft,
        severity: IncidentSeverity.low,
        description: 'Pickpocketing in crowded area',
        daysAgo: 7,
      ),
      _createIncident(
        lat: 33.7260,
        lng: 73.0642,
        type: IncidentType.theft,
        severity: IncidentSeverity.low,
        description: 'Wallet stolen in market',
        daysAgo: 10,
      ),
    ];

    return await _saveIncidents(incidents);
  }

  // Karachi Incidents
  Future<int> _seedKarachiIncidents() async {
    final incidents = [
      // Saddar
      _createIncident(
        lat: 24.8546,
        lng: 67.0271,
        type: IncidentType.theft,
        severity: IncidentSeverity.high,
        description: 'Armed robbery near Saddar market',
        daysAgo: 4,
      ),
      _createIncident(
        lat: 24.8555,
        lng: 67.0280,
        type: IncidentType.suspiciousActivity,
        severity: IncidentSeverity.medium,
        description: 'Suspicious activity reported',
        daysAgo: 9,
      ),
      
      // Clifton
      _createIncident(
        lat: 24.8138,
        lng: 67.0299,
        type: IncidentType.theft,
        severity: IncidentSeverity.medium,
        description: 'Vehicle theft in Clifton area',
        daysAgo: 18,
      ),
      
      // Gulshan-e-Iqbal
      _createIncident(
        lat: 24.9207,
        lng: 67.0827,
        type: IncidentType.assault,
        severity: IncidentSeverity.critical,
        description: 'Assault incident reported',
        daysAgo: 6,
      ),
    ];

    return await _saveIncidents(incidents);
  }

  // Lahore Incidents
  Future<int> _seedLahoreIncidents() async {
    final incidents = [
      // Liberty Market
      _createIncident(
        lat: 31.5098,
        lng: 74.3460,
        type: IncidentType.theft,
        severity: IncidentSeverity.medium,
        description: 'Bag snatching at Liberty Market',
        daysAgo: 11,
      ),
      
      // Mall Road
      _createIncident(
        lat: 31.5656,
        lng: 74.3242,
        type: IncidentType.harassment,
        severity: IncidentSeverity.medium,
        description: 'Harassment reported on Mall Road',
        daysAgo: 14,
      ),
      
      // Johar Town
      _createIncident(
        lat: 31.4697,
        lng: 74.2728,
        type: IncidentType.theft,
        severity: IncidentSeverity.high,
        description: 'House burglary in Johar Town',
        daysAgo: 20,
      ),
    ];

    return await _saveIncidents(incidents);
  }

  // Islamabad Safe Zones
  Future<int> _seedIslamabadSafeZones() async {
    final safeZones = [
      _createSafeZone(
        name: 'Secretariat Police Station',
        lat: 33.7181,
        lng: 73.0776,
        type: SafeZoneType.policeStation,
        address: 'Blue Area, Islamabad',
        contactNumber: '051-9206420',
      ),
      _createSafeZone(
        name: 'PIMS Hospital',
        lat: 33.7008,
        lng: 73.0651,
        type: SafeZoneType.hospital,
        address: 'G-8/3, Islamabad',
        contactNumber: '051-9261170',
      ),
      _createSafeZone(
        name: 'Rescue 1122 Station F-6',
        lat: 33.7294,
        lng: 73.0479,
        type: SafeZoneType.hospital,
        address: 'F-6 Markaz, Islamabad',
        contactNumber: '1122',
      ),
      _createSafeZone(
        name: 'Women Police Station',
        lat: 33.7250,
        lng: 73.0500,
        type: SafeZoneType.policeStation,
        address: 'F-6, Islamabad',
        contactNumber: '051-9258888',
      ),
    ];

    return await _saveSafeZones(safeZones);
  }

  // Karachi Safe Zones
  Future<int> _seedKarachiSafeZones() async {
    final safeZones = [
      _createSafeZone(
        name: 'Saddar Police Station',
        lat: 24.8546,
        lng: 67.0271,
        type: SafeZoneType.policeStation,
        address: 'Saddar, Karachi',
        contactNumber: '021-99203032',
      ),
      _createSafeZone(
        name: 'Jinnah Hospital',
        lat: 24.8740,
        lng: 67.0551,
        type: SafeZoneType.hospital,
        address: 'Rafiqui Shaheed Road, Karachi',
        contactNumber: '021-99201300',
      ),
      _createSafeZone(
        name: 'Clifton Police Station',
        lat: 24.8138,
        lng: 67.0299,
        type: SafeZoneType.policeStation,
        address: 'Clifton, Karachi',
        contactNumber: '021-35830093',
      ),
    ];

    return await _saveSafeZones(safeZones);
  }

  // Lahore Safe Zones
  Future<int> _seedLahoreSafeZones() async {
    final safeZones = [
      _createSafeZone(
        name: 'Liberty Police Station',
        lat: 31.5098,
        lng: 74.3460,
        type: SafeZoneType.policeStation,
        address: 'Liberty Market, Lahore',
        contactNumber: '042-37591234',
      ),
      _createSafeZone(
        name: 'Services Hospital',
        lat: 31.5497,
        lng: 74.3436,
        type: SafeZoneType.hospital,
        address: 'Jail Road, Lahore',
        contactNumber: '042-99211525',
      ),
      _createSafeZone(
        name: 'Mall Road Police Station',
        lat: 31.5656,
        lng: 74.3242,
        type: SafeZoneType.policeStation,
        address: 'Mall Road, Lahore',
        contactNumber: '042-99212345',
      ),
    ];

    return await _saveSafeZones(safeZones);
  }

  // Helper: Create incident
  IncidentModel _createIncident({
    required double lat,
    required double lng,
    required IncidentType type,
    required IncidentSeverity severity,
    required String description,
    required int daysAgo,
  }) {
    return IncidentModel(
      id: '',
      type: type,
      latitude: lat,
      longitude: lng,
      severity: severity,
      description: description,
      timestamp: DateTime.now().subtract(Duration(days: daysAgo)),
      reportedBy: 'system_seed',
      verified: true,
      verificationCount: 1,
    );
  }

  // Helper: Create safe zone
  SafeZoneModel _createSafeZone({
    required String name,
    required double lat,
    required double lng,
    required SafeZoneType type,
    required String address,
    String? contactNumber,
  }) {
    return SafeZoneModel(
      id: '',
      name: name,
      type: type,
      latitude: lat,
      longitude: lng,
      address: address,
      contactNumber: contactNumber,
      operatingHours: '24/7',
      isVerified: true,
    );
  }

  // Save incidents to Firestore
  Future<int> _saveIncidents(List<IncidentModel> incidents) async {
    int count = 0;
    for (var incident in incidents) {
      try {
        await _firestore.collection('incidents').add(incident.toMap());
        count++;
      } catch (e) {
        debugPrint('Error saving incident: $e');
      }
    }
    return count;
  }

  // Save safe zones to Firestore
  Future<int> _saveSafeZones(List<SafeZoneModel> safeZones) async {
    int count = 0;
    for (var zone in safeZones) {
      try {
        await _firestore.collection('safeZones').add(zone.toMap());
        count++;
      } catch (e) {
        debugPrint('Error saving safe zone: $e');
      }
    }
    return count;
  }

  // Clear all seeded data (for testing)
  Future<void> clearAllData() async {
    try {
      // Delete all incidents
      final incidentsSnapshot = await _firestore.collection('incidents').get();
      for (var doc in incidentsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete all safe zones
      final safeZonesSnapshot = await _firestore.collection('safeZones').get();
      for (var doc in safeZonesSnapshot.docs) {
        await doc.reference.delete();
      }

      debugPrint('All data cleared');
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }
}
