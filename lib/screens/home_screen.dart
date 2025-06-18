import 'dart:async';
import 'dart:ui'; // Import for BackdropFilter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_launcher.dart';
import '../widgets/start_menu.dart';
import '../widgets/taskbar.dart';
import '../theme_notifier.dart';
import 'settings_screen.dart';
import 'app_drawer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  late DateTime _currentTime;

  bool _isStartMenuVisible = false;
  List<Map<String, dynamic>> _apps = []; // Centralize apps list here
  // Method to toggle Start Menu visibility
  void _toggleStartMenu() {
    if (mounted) {
      setState(() {
        _isStartMenuVisible = !_isStartMenuVisible;
      });
    }
  }

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
    _loadInstalledApps(); // Load installed apps for the Start Menu
  }

  // Method to load installed apps
  Future<void> _loadInstalledApps() async {
    try {
      final apps = await AppLauncher.getInstalledApps();
      if (mounted) {
        setState(() {
          _apps = apps;
        });
      }
    } catch (e) {
      print('Error loading apps: $e');
      if (mounted) {
        setState(() {
          _apps = []; // Set to empty list on error
        });
      }
    }
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
        MaterialPageRoute(builder: (context) => AppDrawerScreen(apps: _apps)),
      );
    }
  }

  void _navigateToSettings() async {
    // Navigate and then reload favorites when settings page is popped
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    // You can add any callback functionality here if needed
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = Theme.of(context); // Cache theme

    return Scaffold(
      body: Stack(
        children: [
          // Background image covering the entire screen
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/wallpapers/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ), // Global blur container applied to everything
          BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: _isStartMenuVisible ? 10.0 : 0.0,
                sigmaY: _isStartMenuVisible
                    ? 6.0
                    : 0.0), // Apply blur when start menu is visible
            child: Container(              color: Colors.transparent, // Fully transparent container
              child: Stack(
                children: [
                  // Main content area
                  Positioned.fill(
                    child: GestureDetector(
                      onVerticalDragUpdate: _onVerticalDragUpdate,
                      onTap: () {
                        // Tap on desktop area to close Start Menu
                        if (_isStartMenuVisible) {
                          _toggleStartMenu();
                        }
                      },
                      child: Stack(
                        children: [
                          _buildMainContent(theme),
                          _buildSettingsButtons(themeNotifier, theme),
                        ],
                      ),
                    ),
                  ),
                  // Taskbar positioned at the bottom of the screen
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: TaskBar(
                      currentTime: _currentTime,
                      toggleStartMenu: _toggleStartMenu,
                      useBlur: false, // Flag to disable individual blur
                    ),
                  ),
                  // Start menu panel when visible
                  if (_isStartMenuVisible)
                    StartMenuPanel(
                      apps: _apps,
                      onClose: _toggleStartMenu,
                      useBlur: false, // Flag to disable individual blur
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Focus",
              style: theme.textTheme.headlineMedium?.copyWith(
                color:
                    theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "\"The successful warrior is the average man, with laser-like focus.\" - Bruce Lee",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontStyle: FontStyle.italic,
                color:
                    theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsButtons(ThemeNotifier themeNotifier, ThemeData theme) {
    return Positioned(
      top: 40.0,
      right: 20.0,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              themeNotifier.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: theme.primaryColor.withAlpha((0.7 * 255).round()),
            ),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
            tooltip: "Toggle Theme",
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: theme.primaryColor.withAlpha((0.7 * 255).round()),
            ),
            onPressed: _navigateToSettings,
            tooltip: "Settings",
          ),
        ],
      ),
    );
  }
}
