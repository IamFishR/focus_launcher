import 'package:flutter/material.dart';
import '../services/app_launcher.dart';

class StartMenu extends StatelessWidget {
  final List<Map<String, dynamic>> filteredApps;

  const StartMenu({super.key, required this.filteredApps});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      itemCount: filteredApps.length,
      itemBuilder: (context, index) {
        final app = filteredApps[index];
        final appName = app['name'] ?? 'Unknown App';
        final packageName = app['packageName'] ?? '';
        final firstLetter = appName.isNotEmpty ? appName[0].toUpperCase() : '#';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0 ||
                (index > 0 &&
                    filteredApps[index - 1]['name'][0].toUpperCase() !=
                        firstLetter))
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  firstLetter,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ListTile(
              title: Text(
                appName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                ),
              ),
              onTap: () {
                if (packageName.isNotEmpty) {
                  AppLauncher.launchApp(packageName);
                } else {
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text("Cannot launch $appName: Package name missing."),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
