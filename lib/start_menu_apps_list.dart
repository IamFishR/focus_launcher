import 'dart:async';
import 'package:flutter/material.dart';
import 'app_launcher.dart'; // We'll modify this later for icons

class StartMenuAppsList extends StatefulWidget {
  const StartMenuAppsList({super.key});

  @override
  State<StartMenuAppsList> createState() => _StartMenuAppsListState();
}

class _StartMenuAppsListState extends State<StartMenuAppsList> {
  List<Map<String, dynamic>> _apps = []; // Expect dynamic for icon later
  List<Map<String, dynamic>> _filteredApps = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchApps();
    _searchController.addListener(_filterApps);
  }

  Future<void> _fetchApps() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      // Temporarily, getInstalledApps will return List<Map<String, String>>
      // It will be updated to include icons later.
      final List<Map<String, String>> appsData = await AppLauncher.getInstalledApps();

      // Convert to List<Map<String, dynamic>> for future icon data
      List<Map<String, dynamic>> appsWithDynamic = appsData.map((app) => Map<String, dynamic>.from(app)).toList();

      // Sort apps alphabetically by name
      appsWithDynamic.sort((a, b) {
        final String nameA = a['name']?.toLowerCase() ?? '';
        final String nameB = b['name']?.toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });

      if (!mounted) return;
      setState(() {
        _apps = appsWithDynamic;
        _filteredApps = appsWithDynamic;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = "Failed to load apps: $e";
        print(_error);
      });
    }
  }

  void _filterApps() {
    if (!mounted) return;
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredApps = _apps.where((app) {
        final appName = app['name']?.toLowerCase() ?? '';
        return appName.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterApps);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search apps...',
              hintStyle: TextStyle(color: theme.hintColor, fontSize: 14),
              prefixIcon: Icon(Icons.search, size: 20, color: theme.hintColor),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, size: 20, color: theme.hintColor),
                      onPressed: () {
                        _searchController.clear();
                        // _filterApps(); // Already called by listener
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: theme.primaryColor),
              ),
            ),
          ),
        ),
        if (_isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_error.isNotEmpty)
          Expanded(child: Center(child: Text(_error, style: TextStyle(color: theme.colorScheme.error))))
        else if (_filteredApps.isEmpty)
          Expanded(child: Center(child: Text('No apps found.', style: theme.textTheme.bodyMedium)))
        else
          Expanded(
            child: ListView.builder(
              itemCount: _filteredApps.length,
              itemBuilder: (context, index) {
                final app = _filteredApps[index];
                final appName = app['name'] ?? 'Unknown App';
                final packageName = app['packageName'] ?? '';

                // Icon placeholder for now
                // final iconBytes = app['icon'] as Uint8List?;

                return ListTile(
                  // leading: iconBytes != null
                  //     ? Image.memory(iconBytes, width: 32, height: 32, gaplessPlayback: true)
                  //     : const Icon(Icons.apps, size: 32), // Placeholder icon
                  leading: const Icon(Icons.apps_outlined, size: 28), // Consistent placeholder
                  title: Text(appName, style: const TextStyle(fontSize: 14)),
                  onTap: () {
                    if (packageName.isNotEmpty) {
                      AppLauncher.launchApp(packageName);
                      // Consider closing start menu after launch:
                      // Provider.of<StartMenuNotifier>(context, listen: false).hide(); // If using a notifier
                    }
                  },
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                );
              },
            ),
          ),
      ],
    );
  }
}
