import '../models/song.dart';
import '../database/song_dao.dart';
import '../services/song_updater.dart';

class SongRepository {
  final SongDao _songDao;
  late final SongUpdater _songUpdater;

  SongRepository(this._songDao) {
    _songUpdater = SongUpdater(_songDao);
  }

  // Получить все песни
  Future<List<Song>> getAllSongs() => _songDao.getAllSongs();

  // Получить песню по ID
  Future<Song?> getSongById(String id) => _songDao.getSongById(id);

  // Получить избранные песни
  Future<List<Song>> getFavoriteSongs() => _songDao.getFavoriteSongs();

  // Получить недавние песни
  Future<List<Song>> getRecentSongs() => _songDao.getRecentSongs();

  // Поиск песен
  Future<List<Song>> searchSongs(String query) {
    if (query.trim().isEmpty) {
      return getAllSongs();
    }
    return _songDao.advancedSearchSongs(query.trim());
  }

  // Переключить избранное
  Future<void> toggleFavorite(String id) async {
    final song = await _songDao.getSongById(id);
    if (song != null) {
      await _songDao.updateFavoriteStatus(id, !song.isFavorite);
    }
  }

  // Обновить статус избранного
  Future<void> updateFavoriteStatus(String id, bool isFavorite) {
    return _songDao.updateFavoriteStatus(id, isFavorite);
  }

  // Отметить песню как просмотренную
  Future<void> markAsViewed(String id) {
    return _songDao.updateLastAccessed(id, DateTime.now().millisecondsSinceEpoch);
  }

  // Очистить недавние песни
  Future<void> clearRecentSongs() => _songDao.clearAllLastAccessed();

  // Получить количество песен
  Future<int> getSongsCount() => _songDao.getSongsCount();

  // Обновить песни с сайта
  Future<SongUpdater.UpdateResult> refreshSongsFromWebsite({
    bool forceUpdate = false,
  }) {
    return _songUpdater.updateSongs(forceUpdate: forceUpdate);
  }

  // Инициализация базы данных (если пуста)
  Future<bool> initializeDatabaseIfNeeded() async {
    final count = await _songDao.getSongsCount();
    print('Количество песен в базе данных: $count');

    if (count == 0) {
      print('База данных пуста, начинаем загрузку песен...');
      
      try {
        // Даём время на копирование базы из assets
        await Future.delayed(const Duration(seconds: 2));
        
        final countAfterDelay = await _songDao.getSongsCount();
        print('После задержки количество песен: $countAfterDelay');

        if (countAfterDelay == 0) {
          // База всё ещё пуста, попробуем загрузить с сайта
          print('Загружаем песни с сайта...');
          await _songUpdater.updateSongs(forceUpdate: true);
          
          final finalCount = await _songDao.getSongsCount();
          print('После загрузки с сайта в базе $finalCount песен');
          return true;
        }
        
        return true;
      } catch (e) {
        print('Ошибка при инициализации базы данных: $e');
        return false;
      }
    }

    print('База данных уже инициализирована (содержит $count песен)');
    return false;
  }
}

