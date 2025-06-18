import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/app_launcher.dart';
import 'start_menu_list.dart';

class StartMenuPanel extends StatelessWidget {
  final List<Map<String, dynamic>> apps;
  final VoidCallback onClose;
  final bool useBlur;

  const StartMenuPanel({
    super.key,
    required this.apps,
    required this.onClose,
    this.useBlur = true, // Default to true for backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double taskbarHeight = 52.0; // Match taskbar height

    return Positioned(
      bottom: taskbarHeight, // Position above the taskbar
      left: MediaQuery.of(context).size.width > 600
          ? MediaQuery.of(context).size.width *
              0.3 // Centered for larger screens
          : 20, // Small padding for smaller screens
      child: SizedBox(
        width: MediaQuery.of(context).size.width > 600
            ? MediaQuery.of(context).size.width * 0.4 // 40% of screen width
            : MediaQuery.of(context).size.width -
                40, // Full width minus padding
        height:
            MediaQuery.of(context).size.height * 0.65, // 65% of screen height
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
          child: useBlur
              ? BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 6.0, sigmaY: 6.0), // Matching taskbar blur
                  child: _buildMenuContainer(theme),
                )
              : _buildMenuContainer(theme),
        ),
      ),
    );
  }

  // Helper method to build the menu container with proper styling
  Widget _buildMenuContainer(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface
            .withAlpha(100), // Matching taskbar opacity
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 20.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Start Menu", // Title
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 16, // Smaller font size
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            height: 1,
            color: theme.colorScheme.onSurface.withAlpha(51), // Subtle divider
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2, // App list takes more space
                  child: Container(
                    // Use a slightly different background color for the apps list
                    color: theme.colorScheme.surface.withAlpha(10),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 8.0),
                    child: StartMenu(filteredApps: apps),
                  ),
                ),
                Container(
                  width: 1,
                  color: theme.colorScheme.onSurface
                      .withAlpha(51), // Subtle vertical divider
                ),
                Expanded(
                  flex: 1, // Pinned/User takes less space
                  child: _buildStartMenuRightPane(theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to build the right pane of the Start Menu
  Widget _buildStartMenuRightPane(ThemeData theme) {
    return Container(
      // Use a slightly different background color for the pinned section
      color: theme.colorScheme.surface.withAlpha(10),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
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
          Container(
            height: 1,
            color: theme.colorScheme.onSurface.withAlpha(51), // Subtle divider
          ),
          ListTile(
            leading:
                Icon(Icons.phone_outlined, color: theme.colorScheme.onSurface),
            title: Text(
              "Phone",
              style:
                  TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
            ),
            onTap: () {
              AppLauncher.openDialer();
              onClose(); // Close start menu
            },
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
