import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        MaterialPageRoute(builder: (context) => const AppDrawerScreen()),
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
      body: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onTap: () {
          if (_isStartMenuVisible) {
            _toggleStartMenu();
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/wallpapers/bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              _buildMainContent(theme),
              _buildSettingsButtons(themeNotifier, theme),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: TaskBar(
                  currentTime: _currentTime,
                  toggleStartMenu: _toggleStartMenu,
                  useBlur: false,
                ),
              ),
              if (_isStartMenuVisible)
                StartMenuPanel(
                  onClose: _toggleStartMenu,
                  useBlur: false,
                ),
            ],
          ),
        ),
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
