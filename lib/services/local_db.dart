
import 'package:shared_preferences/shared_preferences.dart';

class LocalDB {
  static const String _pinnedAppsKey = 'pinned_apps';

  static Future<List<String>> getPinnedApps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_pinnedAppsKey) ?? [];
  }

  static Future<void> pinApp(String packageName) async {
    final prefs = await SharedPreferences.getInstance();
    final pinnedApps = await getPinnedApps();
    if (!pinnedApps.contains(packageName)) {
      pinnedApps.add(packageName);
      await prefs.setStringList(_pinnedAppsKey, pinnedApps);
    }
  }

  static Future<void> unpinApp(String packageName) async {
    final prefs = await SharedPreferences.getInstance();
    final pinnedApps = await getPinnedApps();
    if (pinnedApps.contains(packageName)) {
      pinnedApps.remove(packageName);
      await prefs.setStringList(_pinnedAppsKey, pinnedApps);
    }
  }
}
