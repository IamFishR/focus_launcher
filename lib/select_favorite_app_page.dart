import 'package:flutter/material.dart';
import 'app_launcher.dart'; // To get the list of apps

class SelectFavoriteAppPage extends StatefulWidget {
  const SelectFavoriteAppPage({super.key});

  @override
  State<SelectFavoriteAppPage> createState() => _SelectFavoriteAppPageState();
}

class _SelectFavoriteAppPageState extends State<SelectFavoriteAppPage> {
  List<Map<String, dynamic>> _allApps = []; // Changed type
  List<Map<String, dynamic>> _filteredApps = []; // Changed type
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
    _searchController.addListener(_filterApps);
  }

  Future<void> _loadInstalledApps() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    // getInstalledApps now returns List<Map<String, dynamic>>
    final List<Map<String, dynamic>> apps =
        await AppLauncher.getInstalledApps(); // Changed type
    if (!mounted) return;
    setState(() {
      _allApps = apps;
      _filteredApps = apps;
      _isLoading = false;
    });
  }

  void _filterApps() {
    final query = _searchController.text.toLowerCase();
    if (!mounted) return;
    setState(() {
      _filteredApps = _allApps.where((app) {
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
      appBar: AppBar(
        title: const Text('Select Favorite App'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: 'Search apps...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withAlpha((0.7 * 255).round()),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredApps.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'No apps installed or found.'
                              : 'No apps found matching your search.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredApps.length,
                        itemBuilder: (context, index) {
                          final app = _filteredApps[index];
                          final appName = app['name'] ?? 'Unknown App';

                          return ListTile(
                            title: Text(appName,
                                style: Theme.of(context).textTheme.bodyLarge),
                            onTap: () {
                              // Pop with the selected app data
                              Navigator.pop(context, app);
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
