import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../data/models/song.dart';
import '../../data/repositories/song_repository.dart';
import '../widgets/song_item.dart';
import '../widgets/platform_widgets.dart';
import '../../utils/constants.dart';
import 'song_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Song> _songs = [];
  List<Song> _displayedSongs = [];
  bool _isLoading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadSongs() async {
    setState(() => _isLoading = true);

    try {
      final repository = context.read<SongRepository>();
      final songs = await repository.getAllSongs();
      
      setState(() {
        _songs = songs..sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
        _displayedSongs = _songs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Ошибка загрузки песен: $e');
    }
  }

  void _onSearchChanged() {
    // Отменяем предыдущий таймер
    _debounce?.cancel();

    // Создаём новый таймер с задержкой
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () => _performSearch(_searchController.text),
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _displayedSongs = _songs..sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
      });
      return;
    }

    try {
      final repository = context.read<SongRepository>();
      final results = await repository.searchSongs(query.trim());
      
      setState(() {
        _displayedSongs = results;
      });
    } catch (e) {
      print('Ошибка поиска: $e');
    }
  }

  Future<void> _onSongTap(Song song) async {
    // Отмечаем песню как просмотренную
    final repository = context.read<SongRepository>();
    await repository.markAsViewed(song.id);

    // Переходим к экрану песни
    if (mounted) {
      final result = await (Platform.isIOS
          ? Navigator.of(context, rootNavigator: true).push(
              CupertinoPageRoute(
                builder: (context) => SongDetailScreen(song: song),
              ),
            )
          : Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SongDetailScreen(song: song),
              ),
            ));
      
      // После возвращения обновляем данные (для обновления иконки избранного)
      if (mounted) {
        await _loadSongs();
        // Если был активен поиск, повторяем его
        if (_searchController.text.isNotEmpty) {
          await _performSearch(_searchController.text);
        }
      }
    }
  }

  Future<void> _toggleFavorite(Song song) async {
    final repository = context.read<SongRepository>();
    await repository.toggleFavorite(song.id);
    await _loadSongs();
    
    // Если есть поиск, повторяем его
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  String _getSearchResultText(String query) {
    if (query.trim().isEmpty) {
      return 'Всего песен: ${_displayedSongs.length}';
    }

    final isNumericSearch = RegExp(r'^\d+$').hasMatch(query.trim());
    
    if (isNumericSearch) {
      if (_displayedSongs.isEmpty) {
        final formattedNumber = _formatSongNumber(query.trim());
        return 'Песни с номером "$formattedNumber" не найдено';
      } else if (_displayedSongs.length == 1) {
        return 'Найдена песня с номером "${_displayedSongs.first.id}"';
      }
    }

    return 'Найдено песен по запросу "$query": ${_displayedSongs.length}';
  }

  String _formatSongNumber(String number) {
    final num = int.tryParse(number) ?? 0;
    if (num < 10) return '000$num';
    if (num < 100) return '00$num';
    if (num < 1000) return '0$num';
    return num.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _buildIOSLayout();
    }
    return _buildMaterialLayout();
  }

  Widget _buildMaterialLayout() {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Духовные песни'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Поисковое поле
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Введите номер или текст для поиска...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Информация о результатах
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _getSearchResultText(_searchController.text),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
          // Список песен
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayedSongs.isEmpty
                    ? const Center(child: Text('Песен не найдено'))
                    : ListView.builder(
                        itemCount: _displayedSongs.length,
                        itemBuilder: (context, index) {
                          final song = _displayedSongs[index];
                          return SongItem(
                            song: song,
                            onTap: () => _onSongTap(song),
                            onFavoriteToggle: () => _toggleFavorite(song),
                            fontSize: theme.textTheme.bodyMedium?.fontSize ?? 13,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildIOSLayout() {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Духовные песни'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Поисковое поле
            Padding(
              padding: const EdgeInsets.all(16),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Поиск...',
                onChanged: (value) {
                  setState(() {}); // Для обновления кнопки очистки
                },
              ),
            ),
            // Информация о результатах
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _getSearchResultText(_searchController.text),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Список песен
            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _displayedSongs.isEmpty
                      ? const Center(child: Text('Песен не найдено'))
                      : ListView.builder(
                          itemCount: _displayedSongs.length,
                          itemBuilder: (context, index) {
                            final song = _displayedSongs[index];
                            return SongItem(
                              song: song,
                              onTap: () => _onSongTap(song),
                              onFavoriteToggle: () => _toggleFavorite(song),
                              fontSize: 13,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

