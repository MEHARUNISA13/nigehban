import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
  
  static Future<bool> requestStoragePermission() async {
    // For Android 13+ use photos/audio/videos permissions
    final status = await Permission.storage.request();
    return status.isGranted;
  }
  
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
