import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'app_launcher.dart';
import 'theme_notifier.dart';
import 'theme.dart';
import 'settings_page.dart'; // Import SettingsPage // Already correctly importing keys from settings_page

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'Focus Launcher',
      theme: themeNotifier.currentTheme, // Use theme from ThemeNotifier
      // darkTheme: darkTheme, // Optionally provide darkTheme if you want system to also influence it
      // themeMode: themeNotifier.themeMode, // If you add ThemeMode to notifier
      debugShowCheckedModeBanner: false, // Hides the debug banner
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Timer _timer;
  late DateTime _currentTime;

  String? _favoriteApp1Name;
  String? _favoriteApp1Package;
  String? _favoriteApp2Name;
  String? _favoriteApp2Package;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
    _loadFavoriteApps();
  }

  Future<void> _loadFavoriteApps() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _favoriteApp1Name = prefs.getString(favApp1NameKey); // favApp1NameKey from settings_page.dart
      _favoriteApp1Package = prefs.getString(favApp1PackageKey);
      _favoriteApp2Name = prefs.getString(favApp2NameKey);
      _favoriteApp2Package = prefs.getString(favApp2PackageKey);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta != null && details.primaryDelta! < -7) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AppDrawer()),
      );
    }
  }

  void _navigateToSettings() async {
    // Navigate and then reload favorites when settings page is popped
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
    _loadFavoriteApps(); // Reload favorites after returning
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('HH:mm:ss').format(_currentTime);
    String formattedDate = DateFormat('EEE, MMM d, yyyy').format(_currentTime);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      // Background color will be handled by theme's scaffoldBackgroundColor
      body: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        child: Container(
          color: Colors.transparent, // Makes entire area draggable
          child: Stack( // Use Stack to position the theme toggle button
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      formattedTime,
                      // Use theme for text style
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Text(
                      formattedDate,
                      // Use theme for text style
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              Positioned( // Position the button in the top-right corner
                top: 40.0,
                right: 20.0,
                child: Row( // Use a Row to place buttons side-by-side
                  children: [
                    IconButton(
                      icon: Icon(
                        themeNotifier.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
                      },
                    ),
                    IconButton( // Settings button
                      icon: Icon(
                        Icons.settings,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: _navigateToSettings, // Updated to call _navigateToSettings
                    ),
                  ],
                )
              ),
              Positioned( // Position the call button in the bottom-left corner
                bottom: 40.0,
                left: 20.0,
                child: IconButton(
                  icon: Icon(
                    Icons.phone_outlined,
                    color: Theme.of(context).primaryColor, // Use primaryColor from theme
                    size: 28.0, // Slightly larger icon for a primary action button
                  ),
                  onPressed: () {
                    AppLauncher.openDialer();
                  },
                ),
              ),
              Positioned(
                bottom: 40.0, // Match the call button's vertical position
                right: 20.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (_favoriteApp1Name != null && _favoriteApp1Name!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0), // Add some padding below first fav
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero, // Remove default minimum size
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Remove extra tap area
                          ),
                          onPressed: () {
                            if (_favoriteApp1Package != null && _favoriteApp1Package!.isNotEmpty) {
                              AppLauncher.launchApp(_favoriteApp1Package!);
                            }
                          },
                          child: Text(
                            _favoriteApp1Name!,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    if (_favoriteApp2Name != null && _favoriteApp2Name!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0), // Add some padding above second fav
                        child: TextButton(
                           style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            if (_favoriteApp2Package != null && _favoriteApp2Package!.isNotEmpty) {
                              AppLauncher.launchApp(_favoriteApp2Package!);
                            }
                          },
                          child: Text(
                            _favoriteApp2Name!,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  List<Map<String, String>> _apps = [];
  List<Map<String, String>> _filteredApps = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApps();
    _searchController.addListener(_filterApps);
  }

  Future<void> _loadApps() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    final List<Map<String, String>> apps = await AppLauncher.getInstalledApps();
    if (!mounted) return;
    setState(() {
      _apps = apps;
      _filteredApps = apps;
      _isLoading = false;
    });
  }

  void _filterApps() {
    final query = _searchController.text.toLowerCase();
    if (!mounted) return;
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
    // AppDrawer's Scaffold will use the theme's scaffoldBackgroundColor automatically
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0), // Adjust top padding for status bar
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color), // Use theme for input text color
              decoration: InputDecoration(
                hintText: 'Search apps...',
                // hintStyle will be picked from inputDecorationTheme in theme.dart
                // fillColor will be picked from inputDecorationTheme in theme.dart
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7), // Theme-aware icon color
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
                              ? 'No apps installed.'
                              : 'No apps found matching your search.',
                          // Use theme for this text
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredApps.length,
                        itemBuilder: (context, index) {
                          final app = _filteredApps[index];
                          final appName = app['name'] ?? 'Unknown App';
                          final packageName = app['packageName'] ?? '';

                          return ListTile(
                            // Use theme for list item text
                            title: Text(appName, style: Theme.of(context).textTheme.bodyLarge),
                            onTap: () {
                              if (packageName.isNotEmpty) {
                                AppLauncher.launchApp(packageName);
                              } else {
                                print("Error: Package name is missing for $appName");
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Cannot launch $appName: Package name missing."))
                                  );
                                }
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
