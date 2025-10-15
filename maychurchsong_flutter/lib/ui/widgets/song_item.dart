import 'package:flutter/material.dart';
import '../../data/models/song.dart';

class SongItem extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;
  final double fontSize;

  const SongItem({
    super.key,
    required this.song,
    required this.onTap,
    this.onFavoriteToggle,
    this.fontSize = 13.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Номер песни
              Container(
                width: 48,
                alignment: Alignment.centerLeft,
                child: Text(
                  song.id,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Заголовок
              Expanded(
                child: Text(
                  song.title ?? 'Без названия',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Кнопка избранного
              if (onFavoriteToggle != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    song.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: song.isFavorite ? Colors.red : null,
                  ),
                  onPressed: onFavoriteToggle,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

