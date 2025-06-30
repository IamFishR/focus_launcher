import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../screens/app_drawer_screen.dart';

import '../services/pinned_apps_notifier.dart';

const String userNameKey = 'user_name';
const String userProfileImageKey = 'user_profile_image';

class StartMenuPanel extends StatefulWidget {
  final VoidCallback onClose;
  final bool useBlur;

  const StartMenuPanel({
    super.key,
    required this.onClose,
    this.useBlur = true,
  });

  @override
  StartMenuPanelState createState() => StartMenuPanelState();
}

class StartMenuPanelState extends State<StartMenuPanel> {
  final TextEditingController _searchController = TextEditingController();
  List<AppInfo> _apps = [];
  List<AppInfo> _filteredApps = [];
  String? _userName;
  String? _userProfileImage;
  late PinnedAppsNotifier _pinnedAppsNotifier;

  @override
  void initState() {
    super.initState();
    _loadApps();
    _loadUserProfile();
    _searchController.addListener(_filterApps);
    _pinnedAppsNotifier = Provider.of<PinnedAppsNotifier>(context, listen: false);
    _pinnedAppsNotifier.addListener(_onPinnedAppsChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pinnedAppsNotifier.removeListener(_onPinnedAppsChanged);
    super.dispose();
  }

  void _onPinnedAppsChanged() {
    setState(() {});
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString(userNameKey);
      _userProfileImage = prefs.getString(userProfileImageKey);
    });
  }

  Future<void> _loadApps() async {
    final apps = await InstalledApps.getInstalledApps(true, true);
    setState(() {
      _apps = apps;
      _filteredApps = apps;
    });
  }

  void _filterApps() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredApps = _apps
          .where((app) => (app.name ?? '').toLowerCase().contains(query))
          .toList();
    });
  }

  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double taskbarHeight = 52.0;

    return Positioned(
      bottom: taskbarHeight,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withAlpha(180),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withOpacity(0.1),
                  ),
                ),
                child: _buildMenuContent(context, theme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuContent(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _buildSearchBar(theme),
        _buildPinnedSection(context, theme),
        _buildFooter(context, theme),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Type here to search",
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface),
          filled: true,
          fillColor: theme.colorScheme.surface.withAlpha(100),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPinnedSection(BuildContext context, ThemeData theme) {
    final pinnedAppsNotifier = Provider.of<PinnedAppsNotifier>(context);
    final List<AppInfo> pinnedApps = _apps
        .where((app) => pinnedAppsNotifier.isPinned(app.packageName!))
        .toList();

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pinned",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppDrawerScreen(),
                      ),
                    );
                  },
                  child: const Text("All apps >"),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                ),
                itemCount: pinnedApps.length,
                itemBuilder: (context, index) {
                  final app = pinnedApps[index];
                  return _buildAppIcon(app);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(AppInfo app) {
    return InkWell(
      onTap: () {
        if (app.packageName != null) {
          InstalledApps.startApp(app.packageName!);
          widget.onClose(); // Close the start menu after launching the app
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (app.icon != null)
            Image.memory(
              app.icon!,
              width: 32,
              height: 32,
            ),
          const SizedBox(height: 4.0),
          Text(
            app.name ?? 'Unknown',
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(100),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12.0),
          bottomRight: Radius.circular(12.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: _userProfileImage != null
                    ? FileImage(File(_userProfileImage!))
                    : null,
                child: _userProfileImage == null
                    ? const Icon(Icons.person, size: 20)
                    : null,
              ),
              const SizedBox(width: 8.0),
              Text(
                _userName ?? "User",
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: () {
              // Placeholder for power options
            },
          ),
        ],
      ),
    );
  }
}
