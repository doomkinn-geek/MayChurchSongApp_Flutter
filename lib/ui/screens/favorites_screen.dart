import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../data/models/song.dart';
import '../../data/repositories/song_repository.dart';
import '../widgets/song_item.dart';
import 'song_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Song> _favoriteSongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Загружаем данные при каждом создании экрана
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    try {
      final repository = context.read<SongRepository>();
      final songs = await repository.getFavoriteSongs();
      
      if (mounted) {
        setState(() {
          _favoriteSongs = songs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('Ошибка загрузки избранных: $e');
    }
  }

  Future<void> _onSongTap(Song song) async {
    final repository = context.read<SongRepository>();
    await repository.markAsViewed(song.id);

    if (mounted) {
      await (Platform.isIOS
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
      
      // После возвращения с экрана песни обновляем список
      if (mounted) {
        await _loadFavorites();
      }
    }
  }

  Future<void> _toggleFavorite(Song song) async {
    final repository = context.read<SongRepository>();
    await repository.toggleFavorite(song.id);
    // Немедленно обновляем список после изменения
    await _loadFavorites();
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
        title: const Text('Избранное'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteSongs.isEmpty
              ? const Center(
                  child: Text(
                    'Нет избранных песен',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _favoriteSongs.length,
                  itemBuilder: (context, index) {
                    final song = _favoriteSongs[index];
                    return SongItem(
                      song: song,
                      onTap: () => _onSongTap(song),
                      onFavoriteToggle: () => _toggleFavorite(song),
                      fontSize: theme.textTheme.bodyMedium?.fontSize ?? 13,
                    );
                  },
                ),
    );
  }

  Widget _buildIOSLayout() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Избранное'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.refresh),
          onPressed: _loadFavorites,
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _favoriteSongs.isEmpty
                ? const Center(
                    child: Text(
                      'Нет избранных песен',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _favoriteSongs.length,
                    itemBuilder: (context, index) {
                      final song = _favoriteSongs[index];
                      return SongItem(
                        song: song,
                        onTap: () => _onSongTap(song),
                        onFavoriteToggle: () => _toggleFavorite(song),
                        fontSize: 13,
                      );
                    },
                  ),
      ),
    );
  }
}
