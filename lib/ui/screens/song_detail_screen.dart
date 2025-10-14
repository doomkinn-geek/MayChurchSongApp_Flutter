import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../data/models/song.dart';
import '../../data/repositories/song_repository.dart';
import '../../data/services/preferences_service.dart';
import '../../ui/themes/app_theme.dart';
import '../../utils/constants.dart';

class SongDetailScreen extends StatefulWidget {
  final Song song;

  const SongDetailScreen({Key? key, required this.song}) : super(key: key);

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  double _textScale = 1.0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.song.isFavorite;
  }

  Future<void> _toggleFavorite() async {
    final repository = context.read<SongRepository>();
    await repository.toggleFavorite(widget.song.id);
    
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _zoomIn() {
    setState(() {
      _textScale = (_textScale + AppConstants.textScaleStep)
          .clamp(AppConstants.minTextScale, AppConstants.maxTextScale);
    });
  }

  void _zoomOut() {
    setState(() {
      _textScale = (_textScale - AppConstants.textScaleStep)
          .clamp(AppConstants.minTextScale, AppConstants.maxTextScale);
    });
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
    final prefs = context.watch<PreferencesService>();
    final baseFontSize = AppTheme.getSongFontSize(prefs.fontSize);
    final scaledFontSize = baseFontSize * _textScale;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.song.title ?? 'Песня'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: _zoomOut,
            tooltip: 'Уменьшить',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: _zoomIn,
            tooltip: 'Увеличить',
          ),
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
            tooltip: _isFavorite ? 'Удалить из избранного' : 'Добавить в избранное',
          ),
        ],
      ),
      body: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            _textScale = (_textScale * details.scale)
                .clamp(AppConstants.minTextScale, AppConstants.maxTextScale);
          });
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  Text(
                    widget.song.title ?? '',
                    style: TextStyle(
                      fontSize: scaledFontSize + 4,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      height: AppConstants.lineHeightMultiplier,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Текст песни
                  Text(
                    widget.song.text ?? '',
                    style: TextStyle(
                      fontSize: scaledFontSize,
                      height: AppConstants.lineHeightMultiplier,
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            // Индикатор масштаба
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Масштаб: ${(_textScale * 100).toInt()}%',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIOSLayout() {
    final prefs = context.watch<PreferencesService>();
    final baseFontSize = AppTheme.getSongFontSize(prefs.fontSize);
    final scaledFontSize = baseFontSize * _textScale;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.song.title ?? 'Песня'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _zoomOut,
              child: const Icon(CupertinoIcons.zoom_out, size: 24),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _zoomIn,
              child: const Icon(CupertinoIcons.zoom_in, size: 24),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _toggleFavorite,
              child: Icon(
                _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                size: 24,
                color: _isFavorite ? CupertinoColors.systemRed : null,
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: GestureDetector(
          onScaleUpdate: (details) {
            setState(() {
              _textScale = (_textScale * details.scale)
                  .clamp(AppConstants.minTextScale, AppConstants.maxTextScale);
            });
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок
                    Text(
                      widget.song.title ?? '',
                      style: TextStyle(
                        fontSize: scaledFontSize + 4,
                        fontWeight: FontWeight.bold,
                        height: AppConstants.lineHeightMultiplier,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Текст песни
                    Text(
                      widget.song.text ?? '',
                      style: TextStyle(
                        fontSize: scaledFontSize,
                        height: AppConstants.lineHeightMultiplier,
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              // Индикатор масштаба
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBackground.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: CupertinoColors.systemGrey.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'Масштаб: ${(_textScale * 100).toInt()}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

