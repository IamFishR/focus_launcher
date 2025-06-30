import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focus_launcher/services/pinned_apps_notifier.dart';
import 'theme_notifier.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => PinnedAppsNotifier()),
      ],
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
      debugShowCheckedModeBanner: false, // Hides the debug banner
      home: const HomeScreen(),
    );
  }
}
