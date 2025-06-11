import 'package:flutter/services.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class AppLauncher {
  static const MethodChannel _channel =
      MethodChannel('com.focuslauncher/app_ops');

  // Updated to use InstalledApps package for getting installed apps
  static Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      // Get installed apps using InstalledApps package
      // excludeSystemApps: true - Only get user apps
      // withIcon: false - Don't load icons for performance (can be changed if needed)
      // packageNamePrefix: "" - No filter on package names
      final List<AppInfo> apps =
          await InstalledApps.getInstalledApps(true, false, "");

      // Convert AppInfo objects to Map<String, dynamic>
      final List<Map<String, dynamic>> appsList = apps
          .map((app) => {
                'name': app.name,
                'packageName': app.packageName,
                // Add any other properties you need
              })
          .toList();

      // Sort apps alphabetically by name (A-Z)
      appsList.sort((a, b) => (a['name'] as String)
          .toLowerCase()
          .compareTo((b['name'] as String).toLowerCase()));

      return appsList;
    } on PlatformException catch (e) {
      print("Failed to get installed apps: '${e.message}'.");
      return [];
    }
  }

  // Updated to use InstalledApps package for launching apps
  static Future<void> launchApp(String packageName) async {
    try {
      await InstalledApps.startApp(packageName);
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
