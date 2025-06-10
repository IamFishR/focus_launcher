import 'package:flutter/services.dart';

class AppLauncher {
  static const MethodChannel _channel = MethodChannel('com.focuslauncher/app_ops');

  static Future<List<Map<String, String>>> getInstalledApps() async {
    try {
      final List<dynamic>? apps = await _channel.invokeMethod('getInstalledApps');
      return apps?.map((app) => Map<String, String>.from(app)).toList() ?? [];
    } on PlatformException catch (e) {
      // Handle error, e.g., log it or show a user-friendly message
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
}
