import 'package:flutter/services.dart';

class AppLauncher {
  static const MethodChannel _channel = MethodChannel('com.focuslauncher/app_ops');

  // Updated to reflect that it can now contain icon data (Uint8List), hence dynamic
  static Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final List<dynamic>? apps = await _channel.invokeMethod('getInstalledApps');
      // Ensure each item in the list is a Map<String, dynamic>
      return apps?.map((app) {
        if (app is Map) {
          return Map<String, dynamic>.from(app.map((key, value) => MapEntry(key.toString(), value)));
        }
        return <String, dynamic>{}; // Should not happen if native side is correct
      }).toList() ?? [];
    } catch (_) {
      // Handle error if needed
      return [];
    }
  }

  static Future<void> launchApp(String packageName) async {
    try {
      await _channel.invokeMethod('launchApp', {'packageName': packageName});
    } on PlatformException catch (_) {
      // Handle error
    }
  }

  static Future<void> openDefaultLauncherSettings() async {
    try {
      await _channel.invokeMethod('openDefaultLauncherSettings');
    } on PlatformException catch (_) {
      // Handle error
    }
  }

  static Future<void> openDialer() async {
    try {
      await _channel.invokeMethod('openDialer');
    } on PlatformException catch (_) {
      // Handle error
    }
  }

  static Future<void> openFileManager() async {
    try {
      await _channel.invokeMethod('openFileManager');
    } on PlatformException catch (_) {
      // Optionally, show a snackbar or toast to the user
    }
  }
}
