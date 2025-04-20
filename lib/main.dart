import 'package:drive_notes/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'themes/theme_notifier.dart';

void main() {
  runApp(const ProviderScope(child: DriveNotesApp()));
}

class DriveNotesApp extends ConsumerWidget {
  const DriveNotesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
       final seedColor = Color(0xff6750a4);
    return MaterialApp(
      title: 'Drive Notes',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
 
      // Light theme using Material 3
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor:seedColor, 
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        // appBarTheme: AppBarTheme(
        //   backgroundColor: Colors.grey,
        //   foregroundColor: Colors.white,
        // ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: seedColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      // Dark theme using Material 3.
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
          ),
        ),
      ),
      home: LoginScreen(),
    );
      
  }
}
