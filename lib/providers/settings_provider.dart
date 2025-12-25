import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _locationTrackingEnabled = true;
  bool _darkModeEnabled = false;
  String _languageCode = 'en';
  bool _soundEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get locationTrackingEnabled => _locationTrackingEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  String get languageCode => _languageCode;
  bool get soundEnabled => _soundEnabled;

  // Load settings from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _locationTrackingEnabled = prefs.getBool('location_tracking_enabled') ?? true;
    _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
    _languageCode = prefs.getString('language_code') ?? 'en';
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    notifyListeners();
  }

  // Toggle notifications
  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    notifyListeners();
  }

  // Toggle location tracking
  Future<void> toggleLocationTracking(bool value) async {
    _locationTrackingEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_tracking_enabled', value);
    notifyListeners();
  }

  // Toggle dark mode
  Future<void> toggleDarkMode(bool value) async {
    _darkModeEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode_enabled', value);
    notifyListeners();
  }

  // Change language
  Future<void> changeLanguage(String code) async {
    _languageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
    notifyListeners();
  }

  // Toggle sound
  Future<void> toggleSound(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
    notifyListeners();
  }
}
