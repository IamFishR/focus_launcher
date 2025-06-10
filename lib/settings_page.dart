import 'package:flutter/material.dart';
import 'app_launcher.dart'; // Assuming AppLauncher will host the new method

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // The AppBar's color will be determined by the active theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Make Focus Launcher Your Default Home Screen',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Setting Focus Launcher as your default home screen will allow you to access your apps quickly and enjoy a distraction-free experience every time you unlock your phone or press the home button.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24.0),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // Use theme's colorScheme for button styling
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () {
                  // Call the method to open default launcher settings
                  AppLauncher.openDefaultLauncherSettings();
                },
                child: const Text('Set as Default Launcher'),
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Text(
                'Tapping the button will take you to your phone\'s settings. Look for the "Default home app" or "Home app" option and select "Focus Launcher".',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
