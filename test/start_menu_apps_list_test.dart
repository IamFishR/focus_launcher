import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focus_launcher/lib/start_menu_apps_list.dart'; // Adjust import path

// Key for SharedPreferences, consistent with settings_page.dart and start_menu_apps_list.dart
const String hiddenAppPackagesKey = 'hidden_app_packages';

void main() {
  // Mock data for getInstalledApps
  const List<Map<String, dynamic>> mockApps = [
    {'name': 'App A', 'packageName': 'com.appa', 'icon': null},
    {'name': 'App B', 'packageName': 'com.appb', 'icon': null},
    {'name': 'Gemini', 'packageName': 'com.gemini', 'icon': null},
  ];

  // MethodChannel mocking for AppLauncher.getInstalledApps
  const MethodChannel channel = MethodChannel('com.focuslauncher/app_ops');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getInstalledApps') {
        return mockApps;
      }
      // Mock for launchApp if needed, though not strictly necessary for these tests
      if (methodCall.method == 'launchApp') {
        return null; // Simulate successful launch
      }
      return null;
    });
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  group('Start Menu App List Filtering', () {
    testWidgets('displays loading indicator then app list', (WidgetTester tester) async {
      // Temporarily override handler for this test to introduce delay
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'getInstalledApps') {
          await Future.delayed(const Duration(milliseconds: 50));
          return []; // Initially empty
        }
        return null;
      });

      await tester.pumpWidget(const MaterialApp(home: StartMenuAppsList()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Setup handler to return apps now
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'getInstalledApps') {
          return mockApps;
        }
        return null;
      });

      await tester.pumpAndSettle(); // Complete loading

      expect(find.text('App A'), findsOneWidget);
      expect(find.text('App B'), findsOneWidget);
      expect(find.text('Gemini'), findsOneWidget);
    });

    testWidgets('displays all apps when no preferences set', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        // hiddenAppPackagesKey is not set or is empty
      });

      await tester.pumpWidget(const MaterialApp(home: StartMenuAppsList()));
      await tester.pumpAndSettle();

      expect(find.text('App A'), findsOneWidget);
      expect(find.text('App B'), findsOneWidget);
      expect(find.text('Gemini'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(mockApps.length));
    });

    testWidgets('filters hidden apps from display', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        hiddenAppPackagesKey: ['com.appb'], // App B is hidden
      });

      await tester.pumpWidget(const MaterialApp(home: StartMenuAppsList()));
      await tester.pumpAndSettle();

      expect(find.text('App A'), findsOneWidget);
      expect(find.text('App B'), findsNothing); // App B should not be found
      expect(find.text('Gemini'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(mockApps.length - 1));
    });

    testWidgets('search works on filtered list', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        hiddenAppPackagesKey: ['com.gemini'], // Gemini is hidden
      });

      await tester.pumpWidget(const MaterialApp(home: StartMenuAppsList()));
      await tester.pumpAndSettle();

      // Initially, App A and App B are visible, Gemini is not
      expect(find.text('App A'), findsOneWidget);
      expect(find.text('App B'), findsOneWidget);
      expect(find.text('Gemini'), findsNothing);

      // Find the search field
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Enter "App" in the search field
      await tester.enterText(searchField, 'App');
      await tester.pumpAndSettle();

      // Verify 'App A' and 'App B' are listed, 'Gemini' is not
      expect(find.text('App A'), findsOneWidget);
      expect(find.text('App B'), findsOneWidget);
      expect(find.text('Gemini'), findsNothing);

      // Enter "Gemini" in the search field
      await tester.enterText(searchField, 'Gemini');
      await tester.pumpAndSettle();

      // Verify 'Gemini' is not listed (as it's hidden)
      expect(find.text('Gemini'), findsNothing);
      // And since "Gemini" doesn't match "App A" or "App B", they shouldn't be found either.
      expect(find.text('App A'), findsNothing);
      expect(find.text('App B'), findsNothing);
      // Check for "No apps found" text if it's implemented for search misses
      // This depends on the exact implementation of the StartMenuAppsList UI when search yields no results
      // For now, we'll just check that the apps that shouldn't be there are not.
      // expect(find.text('No apps found.'), findsOneWidget); // Or similar message
       // Check for the "No apps found" text which is part of the widget's build method
      expect(find.text('No apps found.'), findsOneWidget);


      // Clear search to see App A and App B again
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
      expect(find.text('App A'), findsOneWidget);
      expect(find.text('App B'), findsOneWidget);
      expect(find.text('Gemini'), findsNothing);

    });
     testWidgets('displays "No apps found." when all apps are hidden', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        hiddenAppPackagesKey: ['com.appa', 'com.appb', 'com.gemini'], // All apps hidden
      });

      await tester.pumpWidget(const MaterialApp(home: StartMenuAppsList()));
      await tester.pumpAndSettle();

      expect(find.text('No apps found.'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });
  });
}
