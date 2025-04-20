import 'package:drive_notes/main.dart';
import 'package:drive_notes/themes/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


void main() {
  testWidgets('DriveNotesApp builds with light theme', (WidgetTester tester) async {
    // Create a ThemeNotifier with the desired initial state.
    final testThemeNotifier = ThemeNotifier(); // defaults to ThemeMode.light.

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override the themeProvider with our test notifier.
          themeProvider.overrideWith((ref) => testThemeNotifier),
        ],
        child: const DriveNotesApp(),
      ),
    );

    // Assertions (for example, checking that the initial theme is light).
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, equals(ThemeMode.light));
  });
}
