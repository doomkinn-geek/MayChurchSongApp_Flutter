import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../models/song.dart';
import '../database/song_dao.dart';

class SongUpdater {
  static const String baseUrl = 'https://maychurch.ru/songs';
  final SongDao songDao;

  SongUpdater(this.songDao);

  // Результат обновления
  class UpdateResult {
    final int newSongsCount;
    final int updatedSongsCount;
    final int totalSongsCount;

    UpdateResult({
      required this.newSongsCount,
      required this.updatedSongsCount,
      required this.totalSongsCount,
    });
  }

  // Информация о песне из оглавления
  class SongInfo {
    final String id;
    final String title;
    final String url;

    SongInfo({required this.id, required this.title, required this.url});
  }

  // Основной метод обновления
  Future<UpdateResult> updateSongs({bool forceUpdate = false}) async {
    print('Начинаем обновление песен. Принудительное обновление: $forceUpdate');

    try {
      // Получаем список всех песен с оглавлений
      final allSongsInfo = await _getAllSongsFromIndexPages();

      if (allSongsInfo.isEmpty) {
        throw Exception('Не удалось получить список песен с сайта');
      }

      print('Найдено ${allSongsInfo.length} песен в оглавлении');

      // Получаем существующие песни из базы данных
      final existingSongs = await songDao.getAllSongs();
      final existingSongIds = existingSongs.map((s) => s.id).toSet();

      // Определяем новые песни
      final newSongInfos = allSongsInfo.where((info) => !existingSongIds.contains(info.id)).toList();

      final newSongs = <Song>[];
      final updatedSongs = <Song>[];

      // Загружаем новые песни
      if (newSongInfos.isNotEmpty) {
        print('Найдено ${newSongInfos.length} новых песен для добавления');

        for (var i = 0; i < newSongInfos.length; i++) {
          try {
            final songInfo = newSongInfos[i];
            print('Загрузка новой песни ${i + 1}/${newSongInfos.length}: ${songInfo.id}');

            final song = await _downloadSong(songInfo);
            if (song != null) {
              newSongs.add(song);
            }

            // Небольшая задержка между запросами
            await Future.delayed(const Duration(milliseconds: 200));
          } catch (e) {
            print('Ошибка при загрузке песни: $e');
          }
        }

        // Сохраняем новые песни
        if (newSongs.isNotEmpty) {
          await songDao.insertSongs(newSongs);
          print('Добавлено ${newSongs.length} новых песен в базу данных');
        }
      } else {
        print('Новых песен не найдено');
      }

      // Формируем результат
      return UpdateResult(
        newSongsCount: newSongs.length,
        updatedSongsCount: updatedSongs.length,
        totalSongsCount: existingSongs.length + newSongs.length,
      );
    } catch (e) {
      print('Ошибка при обновлении песен: $e');
      rethrow;
    }
  }

  // Получить список песен из всех страниц оглавления
  Future<List<SongInfo>> _getAllSongsFromIndexPages() async {
    final result = <SongInfo>[];
    final existingIds = <String>{};

    // Обрабатываем страницы p01.htm - p28.htm
    for (var i = 1; i <= 28; i++) {
      final indexPageName = 'p${i.toString().padLeft(2, '0')}.htm';
      final indexPageUrl = '$baseUrl/$indexPageName';

      try {
        print('Загрузка страницы оглавления: $indexPageUrl');

        final response = await http.get(
          Uri.parse(indexPageUrl),
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        );

        if (response.statusCode == 200) {
          // Парсим HTML с правильной кодировкой (windows-1251)
          final body = _decodeWindows1251(response.bodyBytes);
          final songs = _parseSongsFromIndexPage(body);
          
          var countOnPage = 0;
          for (final song in songs) {
            if (!existingIds.contains(song.id)) {
              existingIds.add(song.id);
              result.add(song);
              countOnPage++;
            }
          }

          print('Найдено $countOnPage песен на странице $indexPageName');
        }

        // Задержка между загрузкой страниц
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        print('Ошибка при загрузке страницы оглавления $indexPageUrl: $e');
      }
    }

    print('Всего найдено песен в оглавлениях: ${result.length}');
    return result;
  }

  // Декодирование Windows-1251
  String _decodeWindows1251(List<int> bytes) {
    // Простое декодирование windows-1251 в UTF-8
    final buffer = StringBuffer();
    for (final byte in bytes) {
      if (byte < 128) {
        buffer.writeCharCode(byte);
      } else if (byte >= 192 && byte <= 255) {
        // Кириллица в windows-1251
        buffer.writeCharCode(byte + 848);
      } else if (byte == 168) {
        buffer.writeCharCode(1025); // Ё
      } else if (byte == 184) {
        buffer.writeCharCode(1105); // ё
      } else {
        buffer.writeCharCode(byte);
      }
    }
    return buffer.toString();
  }

  // Парсинг песен со страницы оглавления
  List<SongInfo> _parseSongsFromIndexPage(String htmlContent) {
    final result = <SongInfo>[];
    final document = html_parser.parse(htmlContent);

    // Ищем все ссылки на песни (формат: <a href="0039.htm">...)
    final links = document.querySelectorAll('a[href]');

    for (final link in links) {
      final href = link.attributes['href'] ?? '';
      
      // Проверяем, что это ссылка на песню (формат: XXXX.htm)
      final match = RegExp(r'^(\d{4})\.htm$').firstMatch(href);
      if (match != null) {
        final songId = match.group(1)!;
        
        // Пропускаем файл 0000.html (оглавление)
        if (songId == '0000') continue;

        // Извлекаем заголовок из содержимого ссылки
        final titleDiv = link.querySelector('.list-grid-item-text');
        if (titleDiv != null) {
          var title = titleDiv.text.trim();
          
          // Удаляем завершающий номер (4 цифры)
          title = title.replaceAll(RegExp(r'\s+\d{4}\s*$'), '').trim();
          
          final songUrl = '$baseUrl/$songId.htm';
          result.add(SongInfo(id: songId, title: title, url: songUrl));
        }
      }
    }

    return result;
  }

  // Загрузка песни
  Future<Song?> _downloadSong(SongInfo songInfo) async {
    try {
      final response = await http.get(
        Uri.parse(songInfo.url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        // Декодируем HTML
        final body = _decodeWindows1251(response.bodyBytes);
        final document = html_parser.parse(body);

        // Извлекаем текст из <div class="song">
        final songDiv = document.querySelector('.song');
        if (songDiv != null) {
          final songText = _parseSongContent(songDiv);

          if (songText.isEmpty) {
            print('Пустой текст песни: ${songInfo.id}');
            return null;
          }

          return Song(
            id: songInfo.id,
            title: songInfo.title,
            text: songText,
            url: songInfo.url,
            isFavorite: false,
            lastAccessed: 0,
          );
        }
      }

      return null;
    } catch (e) {
      print('Ошибка при загрузке песни ${songInfo.id}: $e');
      return null;
    }
  }

  // Парсинг содержимого песни
  String _parseSongContent(dynamic songElement) {
    final buffer = StringBuffer();
    
    // Извлекаем все <p> элементы
    final paragraphs = songElement.querySelectorAll('p');
    
    for (var i = 0; i < paragraphs.length; i++) {
      final p = paragraphs[i];
      final lines = <String>[];
      
      // Обрабатываем содержимое параграфа
      for (final node in p.nodes) {
        if (node.nodeType == 3) {
          // Текстовый узел
          final text = node.text?.trim() ?? '';
          if (text.isNotEmpty) {
            lines.add(text);
          }
        } else if (node.nodeName == 'br') {
          // Тег <br> - разделитель строк внутри параграфа
          lines.add('');
        }
      }
      
      // Добавляем строки параграфа
      for (var j = 0; j < lines.length; j++) {
        if (lines[j].isNotEmpty) {
          buffer.writeln(lines[j]);
        }
      }
      
      // Добавляем пустую строку между параграфами (строфами)
      if (i < paragraphs.length - 1) {
        buffer.writeln();
      }
    }
    
    return buffer.toString().trim();
  }
}

