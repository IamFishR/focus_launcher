import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

import 'package:focus_launcher/services/pinned_apps_notifier.dart';
import 'package:provider/provider.dart';

class AppDrawerScreen extends StatefulWidget {
  const AppDrawerScreen({super.key});

  @override
  _AppDrawerScreenState createState() => _AppDrawerScreenState();
}

class _AppDrawerScreenState extends State<AppDrawerScreen> {
  List<AppInfo> _apps = [];

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    final apps = await InstalledApps.getInstalledApps(true, true);
    setState(() {
      _apps = apps;
    });
  }

  void _showPinAppDialog(AppInfo app) async {
    if (app.packageName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot pin this app (package name missing).")),
      );
      return;
    }

    final pinnedAppsNotifier =
        Provider.of<PinnedAppsNotifier>(context, listen: false);
    final isPinned = pinnedAppsNotifier.isPinned(app.packageName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isPinned ? "Unpin ${app.name}?" : "Pin ${app.name}?"),
          content: Text(isPinned
              ? "Do you want to unpin this app from the home screen?"
              : "Do you want to pin this app to the home screen?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(isPinned ? "Unpin" : "Pin"),
              onPressed: () async {
                await pinnedAppsNotifier.togglePin(app.packageName!);
                if (!mounted) return;
                Navigator.of(context).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          "${app.name} ${isPinned ? "unpinned" : "pinned"}!")),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Apps"),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _apps.length,
        itemBuilder: (context, index) {
          final app = _apps[index];
          return GestureDetector(
            onTap: () {
              if (app.packageName != null) {
                InstalledApps.startApp(app.packageName!);
              }
            },
            onLongPress: () {
              _showPinAppDialog(app);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (app.icon != null)
                  Image.memory(
                    app.icon!,
                    width: 48,
                    height: 48,
                  ),
                const SizedBox(height: 8.0),
                Text(
                  app.name,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

