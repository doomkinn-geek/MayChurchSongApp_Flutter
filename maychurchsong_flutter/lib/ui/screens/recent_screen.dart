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
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    setState(() => _isLoading = true);

    try {
      final repository = context.read<SongRepository>();
      final songs = await repository.getRecentSongs();
      
      setState(() {
        _recentSongs = songs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Ошибка загрузки недавних: $e');
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
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Недавние'),
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

