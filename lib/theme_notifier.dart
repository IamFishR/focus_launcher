import 'package:flutter/material.dart';
import 'theme.dart'; // Import theme definitions

class ThemeNotifier extends ChangeNotifier {
  ThemeData _currentTheme = darkTheme; // Default to dark theme

  ThemeData get currentTheme => _currentTheme;

  bool get isDarkMode => true;

  // Optional: Method to set a specific theme if needed later
  void setTheme(ThemeData theme) {
    _currentTheme = theme;
    notifyListeners();
  }
}
