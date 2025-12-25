import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency_contact.dart';
import 'location_service.dart';
import 'notification_service.dart';

class SOSService extends ChangeNotifier {
  bool _isSOSActive = false;
  bool _alarmPlaying = false;
  
  final LocationService _locationService;
  final NotificationService _notificationService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SOSService({
    required LocationService locationService,
    required NotificationService notificationService,
  })  : _locationService = locationService,
        _notificationService = notificationService;

  bool get isSOSActive => _isSOSActive;
  bool get alarmPlaying => _alarmPlaying;

  // Activate SOS emergency mode
  Future<void> activateSOS({
    required String userId,
    required List<EmergencyContact> contacts,
  }) async {
    if (_isSOSActive) return;

    _isSOSActive = true;
    notifyListeners();

    try {
      // Get current location
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        debugPrint('Could not get location for SOS');
        return;
      }

      // Create Google Maps link
      final locationLink = 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';

      // Play alarm sound
      await _playAlarm();

      // Send SMS to emergency contacts
      await _sendEmergencySMS(contacts, locationLink);

      // Save SOS event to Firestore
      await _saveSOSEvent(userId, position);

      // Show notification
      await _notificationService.showSafetyAlert(
        title: '🚨 SOS ACTIVATED',
        body: 'Emergency alerts sent to your contacts',
      );

      // Flash screen (handled in UI)
      _triggerScreenFlash();

    } catch (e) {
      debugPrint('Error activating SOS: $e');
    }
  }

  // Deactivate SOS
  Future<void> deactivateSOS() async {
    _isSOSActive = false;
    await _stopAlarm();
    notifyListeners();
  }

  // Play alarm sound
  Future<void> _playAlarm() async {
    try {
      _alarmPlaying = true;
      notifyListeners();
      
      // Use platform channel to play alarm at max volume
      // For now, using system sound
      await SystemSound.play(SystemSoundType.alert);
      
      // In production, you'd use audioplayers package:
      // final player = AudioPlayer();
      // await player.play(AssetSource('sounds/alarm.mp3'));
      // await player.setVolume(1.0);
      
    } catch (e) {
      debugPrint('Error playing alarm: $e');
    }
  }

  // Stop alarm
  Future<void> _stopAlarm() async {
    _alarmPlaying = false;
    notifyListeners();
    // Stop audio player if implemented
  }

  // Send emergency SMS to contacts
  Future<void> _sendEmergencySMS(
    List<EmergencyContact> contacts,
    String locationLink,
  ) async {
    final message = '🚨 EMERGENCY! I need help. My current location: $locationLink - Sent from Nigehbaan Safety App';

    for (final contact in contacts) {
      try {
        final uri = Uri(
          scheme: 'sms',
          path: contact.phoneNumber,
          queryParameters: {'body': message},
        );

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      } catch (e) {
        debugPrint('Error sending SMS to ${contact.name}: $e');
      }
    }
  }

  // Save SOS event to Firestore
  Future<void> _saveSOSEvent(String userId, Position position) async {
    try {
      await _firestore.collection('emergencies').add({
        'userId': userId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
      });
    } catch (e) {
      debugPrint('Error saving SOS event: $e');
    }
  }

  // Trigger screen flash (handled in UI layer)
  void _triggerScreenFlash() {
    // This will be handled by the UI listening to isSOSActive
    notifyListeners();
  }

  // Quick call emergency number
  Future<void> callEmergencyNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch phone dialer');
    }
  }

  // Share location via SMS
  Future<void> shareLocationViaSMS(String phoneNumber) async {
    final position = await _locationService.getCurrentLocation();
    if (position == null) return;

    final locationLink = 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';
    final message = 'My current location: $locationLink';

    final uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
