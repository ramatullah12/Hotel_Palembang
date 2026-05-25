import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Ganti tema (light <-> dark)
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Tema Light
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFFC62828),
      scaffoldBackgroundColor: const Color(0xFFFDF7F5),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFC62828),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFC62828),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC62828),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      useMaterial3: true,
    );
  }

  // Tema Dark
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFC62828),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFC62828),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2C2C2C),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC62828),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      useMaterial3: true,
    );
  }
}
