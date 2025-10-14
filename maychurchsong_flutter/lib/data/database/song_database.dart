import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SongDatabase {
  static Database? _database;
  static const String _databaseName = 'songs.db';
  static const int _databaseVersion = 1;

  // Singleton pattern
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Инициализация базы данных
  static Future<Database> _initDatabase() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String path = join(appDocDir.path, _databaseName);

    // Проверяем, существует ли база данных
    final bool exists = await databaseExists(path);

    if (!exists) {
      print('База данных не найдена, копируем из assets...');
      await _copyDatabaseFromAssets(path);
    }

    // Открываем базу данных
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Копирование базы данных из assets
  static Future<void> _copyDatabaseFromAssets(String path) async {
    try {
      // Загружаем базу данных из assets
      final ByteData data = await rootBundle.load(
        'maychurchsong_flutter/assets/database/prepopulated_songs.db',
      );

      // Конвертируем в список байтов
      final List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      // Записываем в файл
      await File(path).writeAsBytes(bytes, flush: true);
      print('База данных успешно скопирована из assets');
    } catch (e) {
      print('Ошибка при копировании базы данных: $e');
      rethrow;
    }
  }

  // Создание таблиц (если база данных создаётся впервые)
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS songs (
        id TEXT PRIMARY KEY,
        title TEXT,
        text TEXT,
        url TEXT,
        isFavorite INTEGER DEFAULT 0,
        lastAccessed INTEGER DEFAULT 0
      )
    ''');

    // Создаём индексы для оптимизации поиска
    await db.execute('CREATE INDEX IF NOT EXISTS idx_favorite ON songs(isFavorite)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_lastAccessed ON songs(lastAccessed)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_title ON songs(title)');
  }

  // Закрытие базы данных
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Проверка, открыта ли база данных
  static bool get isOpen => _database?.isOpen ?? false;
}

