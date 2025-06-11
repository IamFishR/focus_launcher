import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'app_launcher.dart';
import 'theme_notifier.dart';
import 'settings_page.dart';
import 'start_menu_apps_list.dart'; // Import the new widget

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

  // String? _favoriteApp1Name;
  // String? _favoriteApp1Name; // Removed: No longer used for home screen favs
  // String? _favoriteApp1Package; // Removed
  // String? _favoriteApp2Name; // Removed
  // String? _favoriteApp2Package; // Removed

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
    // _loadFavoriteApps(); // Removed: No longer used for home screen favs
  }

  // Future<void> _loadFavoriteApps() async { // Removed
  //   final prefs = await SharedPreferences.getInstance();
  //   if (!mounted) return;
  //   setState(() {
  //     _favoriteApp1Name = prefs.getString(favApp1NameKey);
  //     _favoriteApp1Package = prefs.getString(favApp1PackageKey);
  //     _favoriteApp2Name = prefs.getString(favApp2NameKey);
  //     _favoriteApp2Package = prefs.getString(favApp2PackageKey);
  //   });
  // }

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
    // _loadFavoriteApps(); // Removed: No longer used for home screen favs
  }

  // Method to build the right pane of the Start Menu
  Widget _buildStartMenuRightPane(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      // width: 180, // Fixed width for the right pane, or use flex
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      // color: theme.colorScheme.surfaceVariant.withAlpha((0.1 * 255).round()), // Optional subtle background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              "Pinned",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const Divider(thickness: 1),
          ListTile(
            leading:
                Icon(Icons.phone_outlined, color: theme.colorScheme.onSurface),
            title: Text("Phone",
                style: TextStyle(
                    fontSize: 14, color: theme.colorScheme.onSurface)),
            onTap: () {
              AppLauncher.openDialer();
              _toggleStartMenu(); // Close start menu
            },
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          // Add more Pinned items or Recents here later
          // For now, just a placeholder to fill some space or show it's empty
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                // child: Text(
                //   "More items coming soon...",
                //   textAlign: TextAlign.center,
                //   style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                // ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Taskbar time and date formats
    String taskbarFormattedTime =
        DateFormat('h:mm a').format(_currentTime); // e.g., "3:45 PM"
    String taskbarFormattedDate =
        DateFormat('M/d/yyyy').format(_currentTime); // e.g., "10/25/2023"

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = Theme.of(context); // Cache theme

    // Determine taskbar background color based on theme
    Color taskbarColor = themeNotifier.isDarkMode
        ? Colors.grey[850]! // Darker grey for dark mode taskbar
        : Colors.grey[200]!; // Lighter grey for light mode taskbar

    Color taskbarIconColor =
        theme.colorScheme.onSurface.withAlpha((0.8 * 255).round());
    TextStyle taskbarTextStyle = TextStyle(
        color: theme.colorScheme.onSurface.withAlpha((0.9 * 255).round()),
        fontSize: 13);
    const double taskbarHeight = 56.0;

    return Scaffold(
      body: Stack(
        // Wrap the main Column with a Stack to overlay the Start Menu
        children: [
          Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onVerticalDragUpdate: _onVerticalDragUpdate,
                  onTap: () {
                    // Tap on desktop area to close Start Menu
                    if (_isStartMenuVisible) {
                      _toggleStartMenu();
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Stack(
                      // This Stack is for the main desktop area buttons
                      children: [
                        // New Main Content: Title and Quote
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Focus",
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withAlpha((0.7 * 255).round()),
                                  ),
                                ),
                                const SizedBox(height: 24), // Increased spacing
                                Text(
                                  "\"The successful warrior is the average man, with laser-like focus.\" - Bruce Lee",
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: theme.colorScheme.onSurface
                                        .withAlpha((0.6 * 255).round()),
                                    height:
                                        1.5, // Improved line spacing for readability
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Settings and Theme Toggle Buttons (Top Right)
                        Positioned(
                          top: 40.0,
                          right: 20.0,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  themeNotifier.isDarkMode
                                      ? Icons.light_mode
                                      : Icons.dark_mode,
                                  color: theme.primaryColor.withAlpha(
                                      (0.7 * 255)
                                          .round()), // Slightly less prominent
                                ),
                                onPressed: () {
                                  Provider.of<ThemeNotifier>(context,
                                          listen: false)
                                      .toggleTheme();
                                },
                                tooltip: "Toggle Theme",
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.settings,
                                  color: theme.primaryColor.withAlpha(
                                      (0.7 * 255)
                                          .round()), // Slightly less prominent
                                ),
                                onPressed: _navigateToSettings,
                                tooltip: "Settings",
                              ),
                            ],
                          ),
                        ),
                        // Removed old Call Button and Favorite App Placeholders from here
                      ],
                    ),
                  ),
                ),
              ),
              // Taskbar Implementation
              Container(
                height: taskbarHeight,
                color: taskbarColor,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.widgets_outlined,
                          color: taskbarIconColor), // Updated "Start" icon
                      onPressed: _toggleStartMenu, // Call toggle method
                      tooltip: 'Start', // Updated tooltip
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.folder_outlined, color: taskbarIconColor),
                      onPressed: () {
                        AppLauncher.openFileManager();
                      },
                      tooltip: 'File Explorer', // Updated tooltip
                    ),
                    const Expanded(child: SizedBox()),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(taskbarFormattedTime, style: taskbarTextStyle),
                        Text(taskbarFormattedDate,
                            style: taskbarTextStyle.copyWith(fontSize: 11)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          // Start Menu Panel (Overlay)
          if (_isStartMenuVisible)
            Positioned(
              bottom: taskbarHeight, // Position above the taskbar
              left: 0,
              // width: MediaQuery.of(context).size.width * 0.3, // Example: 30% of screen width for a more PC like menu
              // Instead of right:0 for full width, let's give it a max width for larger screens
              // and center it if it's not full width.
              // For now, let's make it start from left and have a certain width or take full if small.
              child: SizedBox(
                // Use a container to constrain width if needed
                width: MediaQuery.of(context).size.width > 600
                    ? 400
                    : MediaQuery.of(context)
                        .size
                        .width, // Max width of 400, else full width
                height: MediaQuery.of(context).size.height *
                    0.65, // 65% of screen height
                child: Material(
                  elevation: 12.0, // Increased elevation for more pop
                  color: theme.colorScheme.surface.withAlpha((0.98 * 255)
                      .round()), // Use surface color from theme, slightly transparent
                  shape: const RoundedRectangleBorder(
                      // Optional: slightly rounded corners for the top
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8))),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "Start Menu", // Placeholder Title
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(color: theme.colorScheme.onSurface),
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 2, // App list takes more space
                              child: StartMenuAppsList(),
                            ),
                            const VerticalDivider(width: 1, thickness: 1),
                            // Right Pane for Pinned/Recent and User options
                            Expanded(
                              flex: 1, // Pinned/User takes less space
                              child: _buildStartMenuRightPane(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
  List<Map<String, dynamic>> _apps = []; // Changed type
  List<Map<String, dynamic>> _filteredApps = []; // Changed type
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
    final List<Map<String, dynamic>> apps =
        await AppLauncher.getInstalledApps(); // Changed type
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredApps.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'No apps installed.'
                              : 'No apps found matching your search.',
                          // Use theme for this text
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
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
                            title: Text(appName,
                                style: Theme.of(context).textTheme.bodyLarge),
                            onTap: () {
                              if (packageName.isNotEmpty) {
                                AppLauncher.launchApp(packageName);
                              } else {
                                print(
                                    "Error: Package name is missing for $appName");
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Cannot launch $appName: Package name missing.")));
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
