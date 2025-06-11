import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/app_launcher.dart';
import 'start_menu_list.dart';

class StartMenuPanel extends StatelessWidget {
  final List<Map<String, dynamic>> apps;
  final VoidCallback onClose;

  const StartMenuPanel({
    super.key,
    required this.apps,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double taskbarHeight = 56.0;

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
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Blur effect
            child: Material(
              elevation: 12.0, // Increased elevation for more pop
              color: theme.colorScheme.surface
                  .withOpacity(0.8), // Semi-transparent
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "Start Menu", // Title
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16, // Smaller font size
                      ),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2, // App list takes more space
                          child: StartMenu(filteredApps: apps),
                        ),
                        const VerticalDivider(width: 1, thickness: 1),
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
      ),
    );
  }

  // Method to build the right pane of the Start Menu
  Widget _buildStartMenuRightPane(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
          const Divider(thickness: 1),
          ListTile(
            leading:
                Icon(Icons.phone_outlined, color: theme.colorScheme.onSurface),
            title: Text("Phone",
                style: TextStyle(
                    fontSize: 14, color: theme.colorScheme.onSurface)),
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
