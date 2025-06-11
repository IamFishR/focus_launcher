import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/app_launcher.dart';
import '../theme_notifier.dart';

class TaskBar extends StatelessWidget {
  final DateTime currentTime;
  final VoidCallback toggleStartMenu;

  const TaskBar({
    super.key,
    required this.currentTime,
    required this.toggleStartMenu,
  });

  @override
  Widget build(BuildContext context) {
    // Taskbar time and date formats
    String taskbarFormattedTime =
        DateFormat('h:mm a').format(currentTime); // e.g., "3:45 PM"
    String taskbarFormattedDate =
        DateFormat('M/d/yyyy').format(currentTime); // e.g., "10/25/2023"

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = Theme.of(context); // Cache theme

    // Determine taskbar background color based on theme
    Color taskbarColor = themeNotifier.isDarkMode
        ? Colors.grey[850]! // Darker grey for dark mode taskbar
        : Colors.grey[200]!; // Lighter grey for light mode taskbar

    // Windows-style blue color for the start button
    Color taskbarIconColor = const Color(0xFF0078D7); // Windows blue
    IconData startIcon = Icons.dashboard_rounded; // Filled dashboard icon
    TextStyle taskbarTextStyle = TextStyle(
        color: theme.colorScheme.onSurface.withAlpha((0.9 * 255).round()),
        fontSize: 13);
    const double taskbarHeight = 56.0;

    return Container(
      height: taskbarHeight,
      color: taskbarColor,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(startIcon, color: taskbarIconColor),
            onPressed: toggleStartMenu,
            tooltip: 'Start',
          ),
          IconButton(
            icon: Icon(Icons.folder, color: taskbarIconColor),
            onPressed: () {
              AppLauncher.openFileManager();
            },
            tooltip: 'File Explorer',
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
    );
  }
}
