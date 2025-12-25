import 'package:flutter/foundation.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService;
  final NotificationService _notificationService;

  Position? _currentPosition;
  bool _isTracking = false;
  List<Map<String, dynamic>> _unsafeZones = [];

  LocationProvider({
    required LocationService locationService,
    required NotificationService notificationService,
  })  : _locationService = locationService,
        _notificationService = notificationService {
    _initialize();
  }

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  List<Map<String, dynamic>> get unsafeZones => _unsafeZones;

  Future<void> _initialize() async {
    await _locationService.checkAndRequestPermission();
    _locationService.addListener(_onLocationUpdate);
  }

  void _onLocationUpdate() {
    _currentPosition = _locationService.currentPosition;
    _isTracking = _locationService.isTracking;
    
    // Check if user entered unsafe zone
    _checkUnsafeZones();
    
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    _currentPosition = await _locationService.getCurrentLocation();
    notifyListeners();
  }

  void startTracking() {
    _locationService.startTracking();
  }

  void stopTracking() {
    _locationService.stopTracking();
  }

  void setUnsafeZones(List<Map<String, dynamic>> zones) {
    _unsafeZones = zones;
    notifyListeners();
  }

  void _checkUnsafeZones() {
    if (_currentPosition == null) return;

    for (final zone in _unsafeZones) {
      final isInside = _locationService.isWithinRadius(
        zone['latitude'],
        zone['longitude'],
        zone['radius'] ?? 500.0,
      );

      if (isInside && zone['isSafe'] == false) {
        _notificationService.showSafetyAlert(
          title: '⚠️ Unsafe Zone Alert',
          body: 'You are entering an area marked as unsafe. Stay alert!',
        );
      }
    }
  }

  @override
  void dispose() {
    _locationService.removeListener(_onLocationUpdate);
    super.dispose();
  }
}
