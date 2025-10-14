import 'package:sqflite/sqflite.dart';
import '../models/song.dart';
import 'song_database.dart';

class SongDao {
  // Получить все песни
  Future<List<Song>> getAllSongs() async {
    final db = await SongDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      orderBy: 'id ASC',
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  // Получить песню по ID
  Future<Song?> getSongById(String id) async {
    final db = await SongDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Song.fromMap(maps.first);
  }

  // Получить избранные песни
  Future<List<Song>> getFavoriteSongs() async {
    final db = await SongDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: 'isFavorite = 1',
      orderBy: 'id ASC',
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  // Получить недавно просмотренные песни (последние 10)
  Future<List<Song>> getRecentSongs() async {
    final db = await SongDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: 'lastAccessed > 0',
      orderBy: 'lastAccessed DESC',
      limit: 10,
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  // Расширенный поиск с приоритизацией
  // Приоритет: точное совпадение ID > начало заголовка > заголовок > текст
  Future<List<Song>> advancedSearchSongs(String query) async {
    if (query.isEmpty) return [];

    final db = await SongDatabase.database;

    // SQL запрос с приоритизацией результатов
    final String sql = '''
      SELECT *, 
      CASE
        WHEN id = ? THEN 0
        WHEN CAST(CAST(id AS INTEGER) AS TEXT) = CAST(? AS TEXT) THEN 0
        WHEN id LIKE '0' || ? THEN 0
        WHEN id LIKE '00' || ? THEN 0
        WHEN title LIKE ? || '%' THEN 1
        WHEN title LIKE '%' || ? || '%' THEN 2
        WHEN text LIKE '%' || ? || '%' THEN 3
        ELSE 4
      END as priorityOrder
      FROM songs
      WHERE 
        id = ? 
        OR CAST(CAST(id AS INTEGER) AS TEXT) = CAST(? AS TEXT)
        OR id LIKE '0' || ?
        OR id LIKE '00' || ?
        OR title LIKE '%' || ? || '%' 
        OR text LIKE '%' || ? || '%'
      ORDER BY priorityOrder ASC, id ASC
    ''';

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      sql,
      [
        query, query, query, query, query, query, query, // для CASE
        query, query, query, query, query, query, // для WHERE
      ],
    );

    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  // Обновить статус избранного
  Future<void> updateFavoriteStatus(String id, bool isFavorite) async {
    final db = await SongDatabase.database;
    await db.update(
      'songs',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Обновить время последнего доступа
  Future<void> updateLastAccessed(String id, int timestamp) async {
    final db = await SongDatabase.database;
    await db.update(
      'songs',
      {'lastAccessed': timestamp},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Очистить все lastAccessed значения
  Future<void> clearAllLastAccessed() async {
    final db = await SongDatabase.database;
    await db.update('songs', {'lastAccessed': 0});
  }

  // Вставить песни (массово)
  Future<void> insertSongs(List<Song> songs) async {
    final db = await SongDatabase.database;
    final Batch batch = db.batch();

    for (final song in songs) {
      batch.insert(
        'songs',
        song.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // Вставить одну песню
  Future<void> insertSong(Song song) async {
    final db = await SongDatabase.database;
    await db.insert(
      'songs',
      song.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Обновить песню
  Future<void> updateSong(Song song) async {
    final db = await SongDatabase.database;
    await db.update(
      'songs',
      song.toMap(),
      where: 'id = ?',
      whereArgs: [song.id],
    );
  }

  // Получить количество песен
  Future<int> getSongsCount() async {
    final db = await SongDatabase.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM songs');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Получить список ID избранных песен
  Future<List<String>> getFavoriteIds() async {
    final db = await SongDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      columns: ['id'],
      where: 'isFavorite = 1',
    );
    return maps.map((map) => map['id'] as String).toList();
  }

  // Очистить все избранные
  Future<void> clearAllFavorites() async {
    final db = await SongDatabase.database;
    await db.update('songs', {'isFavorite': 0});
  }

  // Установить избранные по списку ID
  Future<void> setFavoritesByIds(List<String> songIds) async {
    if (songIds.isEmpty) return;

    final db = await SongDatabase.database;
    final String placeholders = List.filled(songIds.length, '?').join(',');
    await db.rawUpdate(
      'UPDATE songs SET isFavorite = 1 WHERE id IN ($placeholders)',
      songIds,
    );
  }
}

