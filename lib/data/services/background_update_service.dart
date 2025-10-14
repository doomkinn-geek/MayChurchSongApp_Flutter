import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'song_updater.dart';
import '../database/song_dao.dart';
import 'preferences_service.dart';

class BackgroundUpdateService {
  static const String taskName = 'songUpdate';

  // Инициализация для Android
  static Future<void> initializeAndroid(PreferencesService prefs) async {
    if (!Platform.isAndroid) return;

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    // Планируем периодическую задачу, если автообновление включено
    if (prefs.isAutoUpdateEnabled) {
      await scheduleUpdate(prefs.updateIntervalHours);
    }
  }

  // Инициализация для iOS (пока заглушка)
  static Future<void> initializeIOS(PreferencesService prefs) async {
    if (!Platform.isIOS) return;
    
    // TODO: Реализовать фоновое обновление для iOS
    // Можно использовать URLSession background tasks или другие методы
    print('iOS фоновое обновление пока не реализовано');
  }

  // Планирование обновления (Android)
  static Future<void> scheduleUpdate(int intervalHours) async {
    if (!Platform.isAndroid) return;

    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: Duration(hours: intervalHours),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );

    print('Фоновое обновление запланировано каждые $intervalHours часов');
  }

  // Отмена обновления
  static Future<void> cancelUpdate() async {
    if (Platform.isAndroid) {
      await Workmanager().cancelByUniqueName(taskName);
    }
    // Для iOS пока ничего не делаем
  }

  // Выполнение обновления
  static Future<void> _performUpdate() async {
    try {
      final songDao = SongDao();
      final updater = SongUpdater(songDao);
      final result = await updater.updateSongs(forceUpdate: false);

      print('Фоновое обновление завершено: ${result.newSongsCount} новых песен');

      // Обновляем время последнего обновления
      final prefs = PreferencesService();
      await prefs.init();
      await prefs.setLastUpdateTime(DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Ошибка при фоновом обновлении: $e');
    }
  }
}

// Обработчик для Workmanager (Android)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('[Workmanager] Задача начата: $task');

    try {
      await BackgroundUpdateService._performUpdate();
      return Future.value(true);
    } catch (e) {
      print('[Workmanager] Ошибка: $e');
      return Future.value(false);
    }
  });
}
