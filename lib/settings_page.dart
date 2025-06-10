import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_launcher.dart';
import 'select_favorite_app_page.dart'; // Import the new page

// SharedPreferences keys
const String favApp1NameKey = 'favorite_app_1_name';
const String favApp1PackageKey = 'favorite_app_1_package';
const String favApp2NameKey = 'favorite_app_2_name';
const String favApp2PackageKey = 'favorite_app_2_package';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _favApp1Name;
  String? _favApp1Package;
  String? _favApp2Name;
  String? _favApp2Package;

  @override
  void initState() {
    super.initState();
    _loadFavoriteApps();
  }

  Future<void> _loadFavoriteApps() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _favApp1Name = prefs.getString(favApp1NameKey);
      _favApp1Package = prefs.getString(favApp1PackageKey);
      _favApp2Name = prefs.getString(favApp2NameKey);
      _favApp2Package = prefs.getString(favApp2PackageKey);
    });
  }

  Future<void> _saveFavoriteApp(int slot, String name, String packageName) async {
    final prefs = await SharedPreferences.getInstance();
    if (slot == 1) {
      await prefs.setString(favApp1NameKey, name);
      await prefs.setString(favApp1PackageKey, packageName);
      if (mounted) setState(() { _favApp1Name = name; _favApp1Package = packageName; });
    } else if (slot == 2) {
      await prefs.setString(favApp2NameKey, name);
      await prefs.setString(favApp2PackageKey, packageName);
      if (mounted) setState(() { _favApp2Name = name; _favApp2Package = packageName; });
    }
  }

  Future<void> _clearFavoriteApp(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    if (slot == 1) {
      await prefs.remove(favApp1NameKey);
      await prefs.remove(favApp1PackageKey);
      if (mounted) setState(() { _favApp1Name = null; _favApp1Package = null; });
    } else if (slot == 2) {
      await prefs.remove(favApp2NameKey);
      await prefs.remove(favApp2PackageKey);
      if (mounted) setState(() { _favApp2Name = null; _favApp2Package = null; });
    }
  }


  void _selectFavoriteApp(int slot) async {
    final selectedApp = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (context) => const SelectFavoriteAppPage()),
    );

    if (selectedApp != null && selectedApp['name'] != null && selectedApp['packageName'] != null) {
      await _saveFavoriteApp(slot, selectedApp['name']!, selectedApp['packageName']!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView( // Changed to ListView to accommodate more content
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Text(
            'Set Default Launcher',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Make Focus Launcher your default home screen for a distraction-free experience.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16.0),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () {
                AppLauncher.openDefaultLauncherSettings();
              },
              child: const Text('Set as Default Launcher'),
            ),
          ),
          const SizedBox(height: 12.0),
           Center(
             child: Text(
                'Tapping the button will take you to your phone\'s settings. Look for "Default home app" or "Home app" and select "Focus Launcher".',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
           ),
          const Divider(height: 40.0), // Visual separation

          Text(
            'Favorite Apps',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Choose two apps for quick access from the home screen.',
             style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16.0),

          ListTile(
            title: const Text('Favorite App 1'),
            subtitle: Text(
              _favApp1Name ?? 'Tap to select',
              style: TextStyle(color: _favApp1Name == null ? Colors.grey : Theme.of(context).textTheme.bodyMedium?.color),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit),
                if (_favApp1Name != null) // Show clear button only if an app is selected
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.redAccent),
                    onPressed: () => _clearFavoriteApp(1),
                    tooltip: 'Clear Favorite App 1',
                  ),
              ],
            ),
            onTap: () => _selectFavoriteApp(1),
          ),
          ListTile(
            title: const Text('Favorite App 2'),
            subtitle: Text(
              _favApp2Name ?? 'Tap to select',
               style: TextStyle(color: _favApp2Name == null ? Colors.grey : Theme.of(context).textTheme.bodyMedium?.color),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit),
                 if (_favApp2Name != null) // Show clear button only if an app is selected
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.redAccent),
                    onPressed: () => _clearFavoriteApp(2),
                    tooltip: 'Clear Favorite App 2',
                  ),
              ],
            ),
            onTap: () => _selectFavoriteApp(2),
          ),
        ],
      ),
    );
  }
}
