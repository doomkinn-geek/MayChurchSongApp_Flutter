import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../data/models/song.dart';
import '../../data/repositories/song_repository.dart';
import '../widgets/song_item.dart';
import 'song_detail_screen.dart';

class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  List<Song> _recentSongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Загружаем данные при каждом создании экрана
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    try {
      final repository = context.read<SongRepository>();
      final songs = await repository.getRecentSongs();
      
      if (mounted) {
        setState(() {
          _recentSongs = songs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('Ошибка загрузки недавних: $e');
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
        await _loadRecent();
      }
    }
  }

  Future<void> _toggleFavorite(Song song) async {
    final repository = context.read<SongRepository>();
    await repository.toggleFavorite(song.id);
    // Немедленно обновляем список после изменения (для обновления иконки)
    await _loadRecent();
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
        title: const Text('Недавние'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecent,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recentSongs.isEmpty
              ? const Center(
                  child: Text(
                    'Нет недавно просмотренных песен',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _recentSongs.length,
                  itemBuilder: (context, index) {
                    final song = _recentSongs[index];
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
        middle: const Text('Недавние'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.refresh),
          onPressed: _loadRecent,
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _recentSongs.isEmpty
                ? const Center(
                    child: Text(
                      'Нет недавно просмотренных песен',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _recentSongs.length,
                    itemBuilder: (context, index) {
                      final song = _recentSongs[index];
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
