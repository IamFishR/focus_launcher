import 'package:flutter/services.dart';

class AppLauncher {
  static const MethodChannel _channel =
      MethodChannel('com.focuslauncher/app_ops');

  // Updated to reflect that it can now contain icon data (Uint8List), hence dynamic
  static Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final List<dynamic>? apps =
          await _channel.invokeMethod('getInstalledApps');
      // Ensure each item in the list is a Map<String, dynamic>
      return apps?.map((app) {
            if (app is Map) {
              return Map<String, dynamic>.from(
                  app.map((key, value) => MapEntry(key.toString(), value)));
            }
            return <String,
                dynamic>{}; // Should not happen if native side is correct
          }).toList() ??
          [];
    } on PlatformException catch (e) {
      print("Failed to get installed apps: '${e.message}'.");
      return [];
    }
  }

  static Future<void> launchApp(String packageName) async {
    try {
      await _channel.invokeMethod('launchApp', {'packageName': packageName});
    } on PlatformException catch (e) {
      // Handle error
      print("Failed to launch app: '${e.message}'.");
    }
  }

  static Future<void> openDefaultLauncherSettings() async {
    try {
      await _channel.invokeMethod('openDefaultLauncherSettings');
    } on PlatformException catch (e) {
      print("Failed to open default launcher settings: '${e.message}'.");
    }
  }

  static Future<void> openDialer() async {
    try {
      await _channel.invokeMethod('openDialer');
    } on PlatformException catch (e) {
      print("Failed to open dialer: '${e.message}'.");
    }
  }

  static Future<void> openFileManager() async {
    try {
      await _channel.invokeMethod('openFileManager');
    } on PlatformException catch (e) {
      print("Failed to open file manager: '${e.message}'.");
      // Optionally, show a snackbar or toast to the user
    }
  }
}
