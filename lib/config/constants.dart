class AppConstants {
  static const String appName = 'Nigehbaan';
  
  // Storage Keys (Hive/SharedPreferences)
  static const String kUserBox = 'user_box';
  static const String kSettingsBox = 'settings_box';
  static const String kFavoritesBox = 'favorites_box';
  static const String kHistoryBox = 'history_box';
  static const String kEmergencyContactsBox = 'emergency_contacts_box';
  
  static const String kFirstTimeUserMatch = 'is_first_time';
  static const String kAuthToken = 'auth_token';
  static const String kLanguageCode = 'language_code';
  
  // Firebase Collections
  static const String colUsers = 'users';
  static const String colReports = 'reports';
  static const String colSafetyZones = 'safety_zones';
  static const String colEmergencies = 'emergencies';
  
  // Map/Location Defaults
  static const double defaultLatitude = 33.6844; // Islamabad defaults
  static const double defaultLongitude = 73.0479;
  static const double defaultZoom = 14.0;
  
  // Assets Paths
  static const String logoPath = 'assets/images/branding/logo.png';
  static const String onboardingPath = 'assets/images/onboarding/';
  static const String markerPath = 'assets/images/markers/';
}
