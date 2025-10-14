import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'package:background_fetch/background_fetch.dart';
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

  // Инициализация для iOS
  static Future<void> initializeIOS(PreferencesService prefs) async {
    if (!Platform.isIOS) return;

    await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: prefs.updateIntervalHours * 60, // в минутах
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.ANY,
      ),
      _onBackgroundFetch,
      _onBackgroundFetchTimeout,
    );

    // Запускаем, если автообновление включено
    if (prefs.isAutoUpdateEnabled) {
      await BackgroundFetch.start();
    } else {
      await BackgroundFetch.stop();
    }
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
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );

    print('Фоновое обновление запланировано каждые $intervalHours часов');
  }

  // Отмена обновления
  static Future<void> cancelUpdate() async {
    if (Platform.isAndroid) {
      await Workmanager().cancelByUniqueName(taskName);
    } else if (Platform.isIOS) {
      await BackgroundFetch.stop();
    }
  }

  // Обработчик для iOS
  static Future<void> _onBackgroundFetch(String taskId) async {
    print('[BackgroundFetch] Задача начата: $taskId');
    
    try {
      await _performUpdate();
      BackgroundFetch.finish(taskId);
    } catch (e) {
      print('[BackgroundFetch] Ошибка: $e');
      BackgroundFetch.finish(taskId);
    }
  }

  static Future<void> _onBackgroundFetchTimeout(String taskId) async {
    print('[BackgroundFetch] Таймаут: $taskId');
    BackgroundFetch.finish(taskId);
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

