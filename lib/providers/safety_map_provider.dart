import 'package:flutter/foundation.dart';
import '../models/incident_model.dart';
import '../models/safe_zone_model.dart';
import '../services/safety_map_service.dart';

class SafetyMapProvider extends ChangeNotifier {
  final SafetyMapService _safetyMapService = SafetyMapService();

  List<IncidentModel> _incidents = [];
  List<SafeZoneModel> _safeZones = [];
  IncidentModel? _selectedIncident;
  SafeZoneModel? _selectedSafeZone;
  
  bool _isLoadingIncidents = false;
  bool _isLoadingSafeZones = false;
  
  // Filters
  Set<IncidentType> _selectedIncidentTypes = {};
  Set<IncidentSeverity> _selectedSeverities = {};
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  // Getters
  List<IncidentModel> get incidents => _applyFilters(_incidents);
  List<SafeZoneModel> get safeZones => _safeZones;
  IncidentModel? get selectedIncident => _selectedIncident;
  SafeZoneModel? get selectedSafeZone => _selectedSafeZone;
  bool get isLoadingIncidents => _isLoadingIncidents;
  bool get isLoadingSafeZones => _isLoadingSafeZones;
  Set<IncidentType> get selectedIncidentTypes => _selectedIncidentTypes;
  Set<IncidentSeverity> get selectedSeverities => _selectedSeverities;

  // Load incidents for a specific area
  Future<void> loadIncidentsInArea({
    required double centerLat,
    required double centerLng,
    double radiusInKm = 5.0,
  }) async {
    _isLoadingIncidents = true;
    notifyListeners();

    try {
      _incidents = await _safetyMapService.getIncidentsInArea(
        centerLat: centerLat,
        centerLng: centerLng,
        radiusInKm: radiusInKm,
      );
    } catch (e) {
      debugPrint('Error loading incidents: $e');
      _incidents = [];
    } finally {
      _isLoadingIncidents = false;
      notifyListeners();
    }
  }

  // Load all recent incidents
  Future<void> loadAllRecentIncidents({int limit = 100}) async {
    _isLoadingIncidents = true;
    notifyListeners();

    try {
      _incidents = await _safetyMapService.getAllRecentIncidents(limit: limit);
    } catch (e) {
      debugPrint('Error loading all incidents: $e');
      _incidents = [];
    } finally {
      _isLoadingIncidents = false;
      notifyListeners();
    }
  }

  // Load safe zones
  Future<void> loadSafeZones({
    double? centerLat,
    double? centerLng,
    double radiusInKm = 10.0,
  }) async {
    _isLoadingSafeZones = true;
    notifyListeners();

    try {
      if (centerLat != null && centerLng != null) {
        _safeZones = await _safetyMapService.getSafeZonesInArea(
          centerLat: centerLat,
          centerLng: centerLng,
          radiusInKm: radiusInKm,
        );
      } else {
        _safeZones = await _safetyMapService.getAllSafeZones();
      }
    } catch (e) {
      debugPrint('Error loading safe zones: $e');
      _safeZones = [];
    } finally {
      _isLoadingSafeZones = false;
      notifyListeners();
    }
  }

  // Report a new incident
  Future<bool> reportIncident(IncidentModel incident) async {
    try {
      final success = await _safetyMapService.reportIncident(incident);
      if (success) {
        _incidents.insert(0, incident);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error reporting incident: $e');
      return false;
    }
  }

  // Select an incident
  void selectIncident(IncidentModel? incident) {
    _selectedIncident = incident;
    _selectedSafeZone = null;
    notifyListeners();
  }

  // Select a safe zone
  void selectSafeZone(SafeZoneModel? safeZone) {
    _selectedSafeZone = safeZone;
    _selectedIncident = null;
    notifyListeners();
  }

  // Filter methods
  void toggleIncidentTypeFilter(IncidentType type) {
    if (_selectedIncidentTypes.contains(type)) {
      _selectedIncidentTypes.remove(type);
    } else {
      _selectedIncidentTypes.add(type);
    }
    notifyListeners();
  }

  void toggleSeverityFilter(IncidentSeverity severity) {
    if (_selectedSeverities.contains(severity)) {
      _selectedSeverities.remove(severity);
    } else {
      _selectedSeverities.add(severity);
    }
    notifyListeners();
  }

  void setDateFilter(DateTime? startDate, DateTime? endDate) {
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    notifyListeners();
  }

  void clearFilters() {
    _selectedIncidentTypes.clear();
    _selectedSeverities.clear();
    _filterStartDate = null;
    _filterEndDate = null;
    notifyListeners();
  }

  // Apply filters to incidents
  List<IncidentModel> _applyFilters(List<IncidentModel> incidents) {
    var filtered = incidents;

    // Filter by type
    if (_selectedIncidentTypes.isNotEmpty) {
      filtered = filtered
          .where((incident) => _selectedIncidentTypes.contains(incident.type))
          .toList();
    }

    // Filter by severity
    if (_selectedSeverities.isNotEmpty) {
      filtered = filtered
          .where((incident) => _selectedSeverities.contains(incident.severity))
          .toList();
    }

    // Filter by date
    if (_filterStartDate != null) {
      filtered = filtered
          .where((incident) => incident.timestamp.isAfter(_filterStartDate!))
          .toList();
    }
    if (_filterEndDate != null) {
      filtered = filtered
          .where((incident) => incident.timestamp.isBefore(_filterEndDate!))
          .toList();
    }

    return filtered;
  }

  // Search for location
  Future<Map<String, double>?> searchLocation(String address) async {
    return await _safetyMapService.searchLocation(address);
  }

  // Calculate safety score
  Future<double> calculateSafetyScore({
    required double lat,
    required double lng,
    double radiusInKm = 1.0,
  }) async {
    return await _safetyMapService.calculateSafetyScore(
      lat: lat,
      lng: lng,
      radiusInKm: radiusInKm,
    );
  }
}
