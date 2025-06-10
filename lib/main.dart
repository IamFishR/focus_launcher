import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'app_launcher.dart';
import 'theme_notifier.dart';
import 'theme.dart';
import 'settings_page.dart'; // Import SettingsPage

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

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    // Check for swipe up with a velocity threshold
    if (details.primaryDelta != null && details.primaryDelta! < -7) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AppDrawer()),
      );
    }
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsPage()),
                        );
                      },
                    ),
                  ],
                )
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
