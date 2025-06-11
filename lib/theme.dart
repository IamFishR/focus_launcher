import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  primaryColor: Colors.grey[800], // For main text elements
  colorScheme: ColorScheme.light(
    primary: Colors.blue, // Example primary color for buttons, etc.
    secondary: Colors.amber, // Example secondary color
    onPrimary: Colors.white, // Text on primary color
    onSecondary: Colors.black, // Text on secondary color
    surface: Colors.white, // Cards, dialogs background
    onSurface: Colors.grey[800]!, // Text on surface
    background: Colors.white,
    onBackground: Colors.grey[800]!,
    error: Colors.red,
    onError: Colors.white,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
        color: Colors.grey[800], fontSize: 72, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
        color: Colors.grey[800], fontSize: 48, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(
        color: Colors.grey[800], fontSize: 36, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(
        color: Colors.grey[800], fontSize: 24, fontWeight: FontWeight.normal),
    headlineSmall: TextStyle(
        color: Colors.grey[800], fontSize: 20, fontWeight: FontWeight.normal),
    titleLarge: TextStyle(
        color: Colors.grey[800], fontSize: 18, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: Colors.grey[800], fontSize: 16),
    bodyMedium: TextStyle(color: Colors.grey[800], fontSize: 14),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blue, // Example, can be refined
    foregroundColor: Colors.white, // Text/icons on app bar
    elevation: 2.0,
    titleTextStyle: TextStyle(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[100],
    hintStyle: TextStyle(color: Colors.grey[500]),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide.none,
    ),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.blue,
    selectionColor: Colors.blue.withAlpha((0.3 * 255).round()),
    selectionHandleColor: Colors.blue,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  primaryColor: Colors.grey[400], // For main text elements
  colorScheme: ColorScheme.dark(
    primary: Colors.blue[700]!, // Example primary color for buttons, etc.
    secondary: Colors.amber[700]!, // Example secondary color
    onPrimary: Colors.white, // Text on primary color
    onSecondary: Colors.black, // Text on secondary color
    surface: Colors.grey[850]!, // Cards, dialogs background
    onSurface: Colors.grey[300]!, // Text on surface
    background: Colors.black,
    onBackground: Colors.grey[300]!,
    error: Colors.redAccent,
    onError: Colors.white,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
        color: Colors.grey[300], fontSize: 72, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
        color: Colors.grey[300], fontSize: 48, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(
        color: Colors.grey[300], fontSize: 36, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(
        color: Colors.grey[300], fontSize: 24, fontWeight: FontWeight.normal),
    headlineSmall: TextStyle(
        color: Colors.grey[300], fontSize: 20, fontWeight: FontWeight.normal),
    titleLarge: TextStyle(
        color: Colors.grey[300], fontSize: 18, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: Colors.grey[300], fontSize: 16),
    bodyMedium: TextStyle(color: Colors.grey[300], fontSize: 14),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900], // Example, can be refined
    foregroundColor: Colors.white, // Text/icons on app bar
    elevation: 2.0,
    titleTextStyle: TextStyle(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[800],
    hintStyle: TextStyle(color: Colors.grey[500]),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide.none,
    ),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.blue[300],
    selectionColor: Colors.blue[300]?.withAlpha((0.3 * 255).round()),
    selectionHandleColor: Colors.blue[300],
  ),
);
