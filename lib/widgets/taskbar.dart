import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Import theme notifier
import '../theme_notifier.dart';

/// A widget that displays a taskbar at the bottom of the screen with a
/// blurred, semi-transparent background.
class TaskBar extends StatelessWidget {
  final DateTime currentTime;
  final VoidCallback toggleStartMenu;
  final bool useBlur;

  const TaskBar({
    super.key,
    required this.currentTime,
    required this.toggleStartMenu,
    this.useBlur = true, // Default to true for backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    // Use Provider to get the current theme notifier.
    final themeNotifier = Provider.of<ThemeNotifier>(
        context); // Determine taskbar background color based on the current theme.
    final Color taskbarColor = themeNotifier.isDarkMode
        ? Colors.black
            .withAlpha(200) // Slightly more opaque for better readability
        : Colors.white.withAlpha(
            200); // Slightly more opaque for better readability// Define consistent styling for icons and text.
    const Color taskbarIconColor = Color(0xFF0078D7); // Windows-style blue
    final TextStyle taskbarTextStyle = TextStyle(
      color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
      fontWeight: FontWeight.w500, // Medium weight for better clarity
      fontSize: 13,
      letterSpacing: 0.3, // Slight spacing for better readability
    );
    const double taskbarHeight = 52.0;

    // Format the time and date to be displayed on the taskbar.
    final String formattedTime = DateFormat('h:mm a').format(currentTime);
    final String formattedDate = DateFormat('M/d/yyyy').format(
        currentTime); // To achieve the blur effect, the area behind this widget must be clipped.
    // This is typically done on a parent widget, but ClipRect is added here
    // for safety. The BackdropFilter then blurs everything visible within
    // the clipped area behind this widget.
    return ClipRect(
      child: useBlur
          ? BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: 8.0, sigmaY: 8.0), // Reduced blur for better clarity
              child: _buildTaskbarContent(
                  taskbarColor,
                  taskbarIconColor,
                  taskbarTextStyle,
                  formattedTime,
                  formattedDate,
                  taskbarHeight),
            )
          : _buildTaskbarContent(taskbarColor, taskbarIconColor,
              taskbarTextStyle, formattedTime, formattedDate, taskbarHeight),
    );
  }

  // Helper method to build the taskbar content
  Widget _buildTaskbarContent(
      Color taskbarColor,
      Color taskbarIconColor,
      TextStyle taskbarTextStyle,
      String formattedTime,
      String formattedDate,
      double taskbarHeight) {
    return Container(
      height: taskbarHeight,
      color: taskbarColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: <Widget>[
          // Start Menu Button
          IconButton(
            icon: Icon(Icons.dashboard, color: taskbarIconColor),
            onPressed: toggleStartMenu,
            tooltip: 'Start',
          ), // File Explorer Button
          IconButton(
            icon: Icon(Icons.folder_open_rounded, color: taskbarIconColor),
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
                style: taskbarTextStyle.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w400, // Slightly lighter than the time
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
