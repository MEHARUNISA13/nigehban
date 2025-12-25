import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  bool _isTracking = false;
  bool _permissionGranted = false;
  
  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  bool get permissionGranted => _permissionGranted;

  // Check and request location permissions
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied');
      return false;
    }

    _permissionGranted = true;
    notifyListeners();
    return true;
  }

  // Get current location once
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      notifyListeners();
      return _currentPosition;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  // Start continuous location tracking
  void startTracking() {
    if (_isTracking) return;
    
    _isTracking = true;
    notifyListeners();

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      _currentPosition = position;
      notifyListeners();
    });
  }

  // Stop location tracking
  void stopTracking() {
    _isTracking = false;
    notifyListeners();
  }

  // Calculate distance between two points
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  // Check if user is within a certain radius of a point
  bool isWithinRadius(
    double centerLat,
    double centerLng,
    double radiusInMeters,
  ) {
    if (_currentPosition == null) return false;
    
    final distance = calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      centerLat,
      centerLng,
    );
    
    return distance <= radiusInMeters;
  }

  // Get address from coordinates (requires geocoding package)
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    // This will be implemented with geocoding package
    return 'Location: $lat, $lng';
  }
}
