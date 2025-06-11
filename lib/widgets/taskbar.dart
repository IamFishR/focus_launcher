import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Assuming these are your custom files.
// If the paths are different, please adjust the import statements.
import '../services/app_launcher.dart';
import '../theme_notifier.dart';

/// A widget that displays a taskbar at the bottom of the screen with a
/// blurred, semi-transparent background.
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
    // Use Provider to get the current theme notifier.
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    // Determine taskbar background color based on the current theme.
    final Color taskbarColor = themeNotifier.isDarkMode
        ? Colors.black.withAlpha(180) // Darker background for dark mode
        : Colors.white.withAlpha(180); // Lighter background for light mode

    // Define consistent styling for icons and text.
    const Color taskbarIconColor = Color(0xFF0078D7); // Windows-style blue
    final TextStyle taskbarTextStyle = TextStyle(
      color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
      shadows: [
        Shadow(
          color: Colors.black.withAlpha(102), // Replaced withOpacity(0.4)
          blurRadius: 2,
          offset: const Offset(1, 1),
        ),
      ],
      fontSize: 13,
    );
    const double taskbarHeight = 52.0;

    // Format the time and date to be displayed on the taskbar.
    final String formattedTime = DateFormat('h:mm a').format(currentTime);
    final String formattedDate = DateFormat('M/d/yyyy').format(currentTime);

    // To achieve the blur effect, the area behind this widget must be clipped.
    // This is typically done on a parent widget, but ClipRect is added here
    // for safety. The BackdropFilter then blurs everything visible within
    // the clipped area behind this widget.
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          height: taskbarHeight,
          color: taskbarColor,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: <Widget>[
              // Start Menu Button
              IconButton(
                icon: const Icon(Icons.dashboard, color: taskbarIconColor),
                onPressed: toggleStartMenu,
                tooltip: 'Start',
              ),
              // File Explorer Button
              IconButton(
                icon: const Icon(Icons.folder_open_rounded,
                    color: taskbarIconColor),
                onPressed: () {
                  // This assumes you have a static method to open the file manager.
                  // AppLauncher.openFileManager();
                  print("File Explorer Opened"); // Placeholder action
                },
                tooltip: 'File Explorer',
              ),
              // Spacer to push the clock to the right
              const Spacer(),
              // Time and Date Display
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formattedTime, style: taskbarTextStyle),
                  Text(
                    formattedDate,
                    style: taskbarTextStyle.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
