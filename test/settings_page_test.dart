import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focus_launcher/lib/settings_page.dart'; // Adjust import path as needed

// Key for SharedPreferences, consistent with settings_page.dart
const String hiddenAppPackagesKey = 'hidden_app_packages';

void main() {
  // Mock data for getInstalledApps
  const List<Map<String, dynamic>> mockApps = [
    {'name': 'App A', 'packageName': 'com.appa', 'icon': null}, // Assuming icon can be null or byte data
    {'name': 'App B', 'packageName': 'com.appb', 'icon': null},
    {'name': 'Gemini', 'packageName': 'com.gemini', 'icon': null},
  ];

  // MethodChannel mocking for AppLauncher.getInstalledApps
  // Use the correct channel name as defined in app_launcher.dart (assuming 'com.focuslauncher/app_ops')
  const MethodChannel channel = MethodChannel('com.focuslauncher/app_ops');

  // Ensure TestWidgetsFlutterBinding is initialized
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Default handler: returns mockApps for getInstalledApps
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getInstalledApps') {
        return mockApps;
      }
      return null;
    });
    // Clear SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    // Clear the mock handler after each test
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  group('App Visibility Settings', () {
    testWidgets('shows loading indicator then app list', (WidgetTester tester) async {
      // Temporarily override handler for this test to introduce delay/initial empty state
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'getInstalledApps') {
          // Initially, no apps, simulate loading
          await Future.delayed(const Duration(milliseconds: 50)); // Small delay
          return []; // Return empty list first
        }
        return null;
      });

      await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

      // Expect loading indicator for apps
      expect(find.byType(CircularProgressIndicator), findsWidgets); // Might be more than one if fav apps also load

      // Setup handler to return apps now
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'getInstalledApps') {
          return mockApps;
        }
        return null;
      });

      await tester.pumpAndSettle(); // Let SharedPreferences and app loading complete

      // Expect app list items (SwitchListTile for each app)
      expect(find.byType(SwitchListTile), findsNWidgets(mockApps.length));
      expect(find.text('App A'), findsOneWidget);
      expect(find.text('App B'), findsOneWidget);
      expect(find.text('Gemini'), findsOneWidget);
    });

    testWidgets('all apps visible by default (switches ON)', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        // No hidden_app_packagesKey or it's empty
      });

      await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
      await tester.pumpAndSettle(); // Wait for async operations like loading apps and prefs

      // Verify all SwitchListTile widgets are value == true
      for (var app in mockApps) {
        final appName = app['name'] as String;
        final switchTile = tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, appName));
        expect(switchTile.value, isTrue, reason: '$appName switch should be ON');
      }
    });

    testWidgets('loads hidden apps correctly (switches OFF for hidden)', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        hiddenAppPackagesKey: ['com.appb'], // App B is hidden
      });

      await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
      await tester.pumpAndSettle();

      // Verify SwitchListTile for 'App B' is value == false
      final switchTileB = tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'App B'));
      expect(switchTileB.value, isFalse, reason: 'App B switch should be OFF');

      // Verify SwitchListTile for 'App A' and 'Gemini' are value == true
      final switchTileA = tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'App A'));
      expect(switchTileA.value, isTrue, reason: 'App A switch should be ON');
      final switchTileGemini = tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Gemini'));
      expect(switchTileGemini.value, isTrue, reason: 'Gemini switch should be ON');
    });

    testWidgets('toggling switch updates SharedPreferences and UI', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({}); // Start with no hidden apps

      await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
      await tester.pumpAndSettle();

      // Find SwitchListTile for 'App A', confirm it's ON
      final appATileFinder = find.widgetWithText(SwitchListTile, 'App A');
      expect(tester.widget<SwitchListTile>(appATileFinder).value, isTrue);

      // Tap the switch for App A to hide it
      await tester.tap(appATileFinder);
      await tester.pumpAndSettle();

      // Confirm switch for 'App A' is now OFF in UI
      expect(tester.widget<SwitchListTile>(appATileFinder).value, isFalse);
      // Verify SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(hiddenAppPackagesKey), contains('com.appa'));

      // Tap the switch for App A again to make it visible
      await tester.tap(appATileFinder);
      await tester.pumpAndSettle();

      // Confirm switch is ON
      expect(tester.widget<SwitchListTile>(appATileFinder).value, isTrue);
      // Verify SharedPreferences
      final prefsAfterUnhide = await SharedPreferences.getInstance();
      expect(prefsAfterUnhide.getStringList(hiddenAppPackagesKey), isNot(contains('com.appa')));
      expect(prefsAfterUnhide.getStringList(hiddenAppPackagesKey), isEmpty);
    });
  });
}
