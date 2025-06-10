import 'package:flutter/material.dart';
import 'theme.dart'; // Import theme definitions

class ThemeNotifier extends ChangeNotifier {
  ThemeData _currentTheme = lightTheme; // Default to light theme

  ThemeData get currentTheme => _currentTheme;

  bool get isDarkMode => _currentTheme.brightness == Brightness.dark;

  void toggleTheme() {
    if (_currentTheme.brightness == Brightness.light) {
      _currentTheme = darkTheme;
    } else {
      _currentTheme = lightTheme;
    }
    notifyListeners();
  }

  // Optional: Method to set a specific theme if needed later
  void setTheme(ThemeData theme) {
    _currentTheme = theme;
    notifyListeners();
  }
}
