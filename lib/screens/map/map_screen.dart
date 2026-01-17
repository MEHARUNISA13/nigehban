import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../providers/location_provider.dart';
import '../../providers/safety_map_provider.dart';
import '../../models/incident_model.dart';
import '../../models/safe_zone_model.dart';
import '../../widgets/incident_details_sheet.dart';
import '../../config/routes.dart';
import 'report_incident_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  bool _isLoading = true;
  String? _errorMessage;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  bool _showIncidents = true;
  bool _showSafeZones = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied. Please enable location to use map.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permission permanently denied. Please enable in settings.';
          _isLoading = false;
        });
        return;
      }

      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Load safety data
      await _loadSafetyData();

      // Move camera to current location
      if (_mapController != null && _currentPosition != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition!, 15),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
        _isLoading = false;
      });
      debugPrint('Map initialization error: $e');
    }
  }

  Future<void> _loadSafetyData() async {
    if (_currentPosition == null) return;

    final safetyProvider = context.read<SafetyMapProvider>();
    
    // Load incidents and safe zones
    await Future.wait([
      safetyProvider.loadAllRecentIncidents(limit: 50),
      safetyProvider.loadSafeZones(
        centerLat: _currentPosition!.latitude,
        centerLng: _currentPosition!.longitude,
      ),
    ]);

    _updateMarkers();
  }

  void _updateMarkers() {
    final safetyProvider = context.read<SafetyMapProvider>();
    final newMarkers = <Marker>{};

    // Add incident markers
    if (_showIncidents) {
      for (var incident in safetyProvider.incidents) {
        newMarkers.add(
          Marker(
            markerId: MarkerId('incident_${incident.id}'),
            position: LatLng(incident.latitude, incident.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(_getIncidentColor(incident)),
            infoWindow: InfoWindow(
              title: incident.typeDisplayName,
              snippet: incident.severityDisplayName,
            ),
            onTap: () => _showIncidentDetails(incident),
          ),
        );
      }
    }

    // Add safe zone markers
    if (_showSafeZones) {
      for (var zone in safetyProvider.safeZones) {
        newMarkers.add(
          Marker(
            markerId: MarkerId('zone_${zone.id}'),
            position: LatLng(zone.latitude, zone.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(_getSafeZoneColor(zone)),
            infoWindow: InfoWindow(
              title: zone.name,
              snippet: zone.typeDisplayName,
            ),
          ),
        );
      }
    }

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });
  }

  double _getIncidentColor(IncidentModel incident) {
    switch (incident.severity) {
      case IncidentSeverity.critical:
        return BitmapDescriptor.hueRed;
      case IncidentSeverity.high:
        return BitmapDescriptor.hueOrange;
      case IncidentSeverity.medium:
        return BitmapDescriptor.hueYellow;
      case IncidentSeverity.low:
        return BitmapDescriptor.hueGreen;
    }
  }

  double _getSafeZoneColor(SafeZoneModel zone) {
    switch (zone.type) {
      case SafeZoneType.policeStation:
        return BitmapDescriptor.hueBlue;
      case SafeZoneType.hospital:
        return BitmapDescriptor.hueCyan;
      case SafeZoneType.safeHouse:
        return BitmapDescriptor.hueViolet;
      case SafeZoneType.publicArea:
        return BitmapDescriptor.hueGreen;
      case SafeZoneType.other:
        return BitmapDescriptor.hueAzure;
    }
  }

  void _showIncidentDetails(IncidentModel incident) {
    double? distance;
    if (_currentPosition != null) {
      distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        incident.latitude,
        incident.longitude,
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IncidentDetailsSheet(
        incident: incident,
        distanceInMeters: distance,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // If we already have position, move camera
    if (_currentPosition != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 15),
      );
    }
  }

  void _recenterMap() async {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 15),
      );
    } else {
      // Try to get location again
      await _initializeMap();
    }
  }

  void _triggerSOS() {
    Navigator.pushNamed(context, AppRoutes.sos);
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    try {
      final safetyProvider = context.read<SafetyMapProvider>();
      final result = await safetyProvider.searchLocation(query);

      if (result != null && _mapController != null) {
        final location = LatLng(result['latitude']!, result['longitude']!);
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(location, 15),
        );

        // Calculate safety score
        final score = await safetyProvider.calculateSafetyScore(
          lat: result['latitude']!,
          lng: result['longitude']!,
        );

        if (mounted) {
          // Determine safety level and color
          String safetyLevel;
          Color scoreColor;
          String emoji;
          
          if (score >= 80) {
            safetyLevel = 'Very Safe';
            scoreColor = Colors.green;
            emoji = '🟢';
          } else if (score >= 60) {
            safetyLevel = 'Moderately Safe';
            scoreColor = Colors.lightGreen;
            emoji = '🟡';
          } else if (score >= 40) {
            safetyLevel = 'Caution Advised';
            scoreColor = Colors.orange;
            emoji = '🟠';
          } else {
            safetyLevel = 'High Risk';
            scoreColor = Colors.red;
            emoji = '🔴';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$emoji Safety Score: ${score.toStringAsFixed(0)}/100 - $safetyLevel',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: scoreColor,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location not found')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _reportIncident() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportIncidentScreen(
          initialLocation: _currentPosition,
        ),
      ),
    );

    if (result == true) {
      // Reload incidents
      await _loadSafetyData();
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Map Filters',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Show Incidents'),
              value: _showIncidents,
              onChanged: (value) {
                setState(() => _showIncidents = value);
                _updateMarkers();
                Navigator.pop(context);
              },
            ),
            SwitchListTile(
              title: const Text('Show Safe Zones'),
              value: _showSafeZones,
              onChanged: (value) {
                setState(() => _showSafeZones = value);
                _updateMarkers();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Map'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map or Loading/Error State
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading safety map...'),
                ],
              ),
            )
          else if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _initializeMap();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        await Geolocator.openLocationSettings();
                      },
                      child: const Text('Open Settings'),
                    ),
                  ],
                ),
              ),
            )
          else
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition ?? const LatLng(
                  AppConstants.defaultLatitude,
                  AppConstants.defaultLongitude,
                ),
                zoom: AppConstants.defaultZoom,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
            ),

          // Search Bar (only show if map is loaded)
          if (!_isLoading && _errorMessage == null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search location for safety info...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _searchLocation(),
                  ),
                ),
              ),
            ),

          // Report Incident Button
          if (!_isLoading && _errorMessage == null)
            Positioned(
              bottom: 100,
              right: 20,
              child: FloatingActionButton(
                onPressed: _reportIncident,
                backgroundColor: AppTheme.warningColor,
                heroTag: 'report_button',
                child: const Icon(Icons.add_alert),
              ),
            ),

          // SOS Button
          if (!_isLoading && _errorMessage == null)
            Positioned(
              bottom: 30,
              left: 20,
              child: FloatingActionButton.extended(
                onPressed: _triggerSOS,
                backgroundColor: Colors.red,
                heroTag: 'sos_button',
                icon: const Icon(Icons.warning_amber_rounded),
                label: const Text('SOS'),
              ),
            ),
        ],
      ),
      floatingActionButton: _isLoading || _errorMessage != null
          ? null
          : FloatingActionButton(
              onPressed: _recenterMap,
              heroTag: 'recenter_button',
              child: const Icon(Icons.my_location),
            ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
