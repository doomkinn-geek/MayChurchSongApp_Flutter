import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AppTheme {
  // Светлая тема Material Design
  static ThemeData lightTheme(double interfaceFontSize) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: interfaceFontSize + 4,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: _buildTextTheme(interfaceFontSize, Brightness.light),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
    );
  }

  // Тёмная тема Material Design
  static ThemeData darkTheme(double interfaceFontSize) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: interfaceFontSize + 4,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: _buildTextTheme(interfaceFontSize, Brightness.dark),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
    );
  }

  // Построение TextTheme с учётом размера шрифта интерфейса
  static TextTheme _buildTextTheme(double baseFontSize, Brightness brightness) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: baseFontSize + 44,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontSize: baseFontSize + 38,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        fontSize: baseFontSize + 32,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        fontSize: baseFontSize + 20,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontSize: baseFontSize + 16,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontSize: baseFontSize + 12,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontSize: baseFontSize + 8,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        fontSize: baseFontSize + 4,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        fontSize: baseFontSize + 2,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        fontSize: baseFontSize + 2,
      ),
      bodyMedium: TextStyle(
        fontSize: baseFontSize,
      ),
      bodySmall: TextStyle(
        fontSize: baseFontSize - 2,
      ),
      labelLarge: TextStyle(
        fontSize: baseFontSize + 2,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        fontSize: baseFontSize,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        fontSize: baseFontSize - 2,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // Размер шрифта песни с учётом настройки
  static double getSongFontSize(int fontSizeSetting) {
    return AppConstants.songFontSizes[fontSizeSetting] ?? 17.0;
  }

  // Размер шрифта интерфейса с учётом настройки
  static double getInterfaceFontSize(int fontSizeSetting) {
    return AppConstants.interfaceFontSizes[fontSizeSetting] ?? 13.0;
  }
}

