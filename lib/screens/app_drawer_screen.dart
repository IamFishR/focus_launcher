import 'package:flutter/material.dart';
import '../services/app_launcher.dart';

class AppDrawerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> apps;

  const AppDrawerScreen({super.key, required this.apps});

  @override
  State<AppDrawerScreen> createState() => _AppDrawerScreenState();
}

class _AppDrawerScreenState extends State<AppDrawerScreen> {
  late List<Map<String, dynamic>> _filteredApps;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredApps = widget.apps;
    _searchController.addListener(_filterApps);
  }

  void _filterApps() {
    final query = _searchController.text.toLowerCase();
    if (!mounted) return;
    setState(() {
      _filteredApps = widget.apps.where((app) {
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
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
                16.0, 40.0, 16.0, 16.0), // Adjust top padding for status bar
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color), // Use theme for input text color
              decoration: InputDecoration(
                hintText: 'Search apps...',
                // hintStyle will be picked from inputDecorationTheme in theme.dart
                // fillColor will be picked from inputDecorationTheme in theme.dart
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withAlpha(
                          (0.7 * 255).round()), // Theme-aware icon color
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredApps.isEmpty
                ? Center(
                    child: Text(
                      'No apps found.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredApps.length,
                    itemBuilder: (context, index) {
                      final app = _filteredApps[index];
                      final appName = app['name'] ?? 'Unknown App';
                      final packageName = app['packageName'] ?? '';

                      return ListTile(
                        title: Text(
                          appName,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        onTap: () {
                          if (packageName.isNotEmpty) {
                            AppLauncher.launchApp(packageName);
                          } else {
                            print(
                                "Error: Package name is missing for $appName");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Cannot launch $appName: Package name missing."),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
