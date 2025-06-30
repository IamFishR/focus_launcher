import 'package:flutter/foundation.dart';
import 'package:focus_launcher/services/local_db.dart';

class PinnedAppsNotifier extends ChangeNotifier {
  List<String> _pinnedApps = [];

  List<String> get pinnedApps => _pinnedApps;

  PinnedAppsNotifier() {
    _loadPinnedApps();
  }

  Future<void> _loadPinnedApps() async {
    _pinnedApps = await LocalDB.getPinnedApps();
    notifyListeners();
  }

  Future<void> togglePin(String packageName) async {
    if (_pinnedApps.contains(packageName)) {
      await LocalDB.unpinApp(packageName);
    } else {
      await LocalDB.pinApp(packageName);
    }
    await _loadPinnedApps(); // Reload and notify listeners
  }

  bool isPinned(String packageName) {
    return _pinnedApps.contains(packageName);
  }
}