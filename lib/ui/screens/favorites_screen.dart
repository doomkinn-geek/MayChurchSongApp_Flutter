import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../data/models/song.dart';
import '../../data/repositories/song_repository.dart';
import '../widgets/song_item.dart';
import 'song_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Song> _favoriteSongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    try {
      final repository = context.read<SongRepository>();
      final songs = await repository.getFavoriteSongs();
      
      setState(() {
        _favoriteSongs = songs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Ошибка загрузки избранных: $e');
    }
  }

  Future<void> _onSongTap(Song song) async {
    final repository = context.read<SongRepository>();
    await repository.markAsViewed(song.id);

    if (mounted) {
      if (Platform.isIOS) {
        Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(
            builder: (context) => SongDetailScreen(song: song),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SongDetailScreen(song: song),
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite(Song song) async {
    final repository = context.read<SongRepository>();
    await repository.toggleFavorite(song.id);
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
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Избранное'),
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

