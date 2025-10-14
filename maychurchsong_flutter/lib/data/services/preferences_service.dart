import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService extends ChangeNotifier {
  static const String _keyDarkTheme = 'dark_theme';
  static const String _keyUseSystemTheme = 'use_system_theme';
  static const String _keyFontSize = 'font_size';
  static const String _keyInterfaceFontSize = 'interface_font_size';
  static const String _keyAutoUpdateEnabled = 'auto_update_enabled';
  static const String _keyUpdateIntervalHours = 'update_interval_hours';
  static const String _keyLastUpdateTime = 'last_update_time';

  // Размеры шрифта
  static const int fontSizeSmall = 0;
  static const int fontSizeMedium = 1;
  static const int fontSizeLarge = 2;

  // Интервалы обновления (в часах)
  static const int updateInterval12Hours = 12;
  static const int updateInterval24Hours = 24;
  static const int updateInterval48Hours = 48;
  static const int updateIntervalWeek = 168;

  // Значения по умолчанию
  static const int defaultUpdateInterval = updateIntervalWeek;

  SharedPreferences? _prefs;

  // Инициализация
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('PreferencesService не инициализирован. Вызовите init() сначала.');
    }
    return _prefs!;
  }

  // Тема
  bool get isDarkTheme => prefs.getBool(_keyDarkTheme) ?? false;
  Future<void> setDarkTheme(bool value) async {
    await prefs.setBool(_keyDarkTheme, value);
    notifyListeners();
  }

  bool get useSystemTheme => prefs.getBool(_keyUseSystemTheme) ?? true;
  Future<void> setUseSystemTheme(bool value) async {
    await prefs.setBool(_keyUseSystemTheme, value);
    notifyListeners();
  }

  // Размеры шрифтов
  int get fontSize => prefs.getInt(_keyFontSize) ?? fontSizeMedium;
  Future<void> setFontSize(int value) async {
    await prefs.setInt(_keyFontSize, value);
    notifyListeners();
  }

  int get interfaceFontSize => prefs.getInt(_keyInterfaceFontSize) ?? fontSizeMedium;
  Future<void> setInterfaceFontSize(int value) async {
    await prefs.setInt(_keyInterfaceFontSize, value);
    notifyListeners();
  }

  // Автообновление
  bool get isAutoUpdateEnabled => prefs.getBool(_keyAutoUpdateEnabled) ?? true;
  Future<void> setAutoUpdateEnabled(bool value) async {
    await prefs.setBool(_keyAutoUpdateEnabled, value);
    notifyListeners();
  }

  int get updateIntervalHours => prefs.getInt(_keyUpdateIntervalHours) ?? defaultUpdateInterval;
  Future<void> setUpdateIntervalHours(int value) async {
    await prefs.setInt(_keyUpdateIntervalHours, value);
    notifyListeners();
  }

  int get lastUpdateTime => prefs.getInt(_keyLastUpdateTime) ?? 0;
  Future<void> setLastUpdateTime(int value) async {
    await prefs.setInt(_keyLastUpdateTime, value);
    notifyListeners();
  }

  // Форматированное время последнего обновления
  String getFormattedLastUpdateTime() {
    final timestamp = lastUpdateTime;
    if (timestamp == 0) return 'Никогда';

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Только что';
    if (difference.inHours < 1) return '${difference.inMinutes} мин. назад';
    if (difference.inDays < 1) return '${difference.inHours} ч. назад';
    if (difference.inDays < 7) return '${difference.inDays} дн. назад';

    return '${date.day}.${date.month}.${date.year} в ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

