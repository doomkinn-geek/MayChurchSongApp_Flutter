import 'package:flutter/material.dart';

class AppConstants {
  // Название приложения
  static const String appName = 'Духовные песни';
  static const String appSubtitle = 'Сборник Майской Церкви';

  // URL источника данных
  static const String songsWebsiteUrl = 'https://maychurch.ru/songs';

  // Размеры шрифтов для песен (в зависимости от настройки)
  static const Map<int, double> songFontSizes = {
    0: 14.0, // Small (уменьшено на 25%)
    1: 17.0, // Medium (уменьшено на 25%)
    2: 21.0, // Large (уменьшено на 25%)
  };

  // Размеры шрифтов для интерфейса
  static const Map<int, double> interfaceFontSizes = {
    0: 11.0, // Small (уменьшено на 33%)
    1: 13.0, // Medium (уменьшено на 33%)
    2: 16.0, // Large (уменьшено на 33%)
  };

  // Межстрочный интервал
  static const double lineHeightMultiplier = 1.3;

  // Задержка для дебаунсинга поиска (мс)
  static const int searchDebounceMs = 300;

  // Максимальное количество недавних песен
  static const int maxRecentSongs = 10;

  // Параметры масштабирования текста
  static const double minTextScale = 0.8;
  static const double maxTextScale = 2.5;
  static const double textScaleStep = 0.1;

  // Цвета приложения
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color primaryColorDark = Color(0xFF1565C0);
  static const Color accentColor = Color(0xFF03A9F4);

  // Отступы
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(12.0);
  static const double defaultSpacing = 8.0;

  // Анимации
  static const Duration animationDuration = Duration(milliseconds: 200);
}

