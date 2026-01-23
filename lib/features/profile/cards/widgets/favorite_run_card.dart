import 'dart:io';

import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/media/media_cache_service.dart';
import 'package:cyberdriver/core/ui/widgets/radial_fade_image.dart';
import 'package:flutter/material.dart';

const Duration _cacheDuration = Duration(days: 1);
const double _thumbWidth = 65;
const double _thumbHeight = 36;

class FavoriteRunCard extends StatelessWidget {
  const FavoriteRunCard({
    super.key,
    required this.distance,
    required this.duration,
    required this.imageHash,
    required this.title,
    required this.label,
    this.fadeRadius = 0.5,
    this.fadeStops = const [0.0, 0.6, 1.0],
    this.fadeColors = const [
      Colors.white,
      Colors.white,
      Colors.transparent,
    ],
  });

  final int distance;
  final int duration;
  final String imageHash;
  final String title;
  final String label;
  final double fadeRadius;
  final List<double> fadeStops;
  final List<Color> fadeColors;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: Colors.white.withValues(alpha: 0.6),
    );
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
      color: Colors.white.withValues(alpha: 0.95),
      height: 1.0,
    );
    final metaStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: Colors.white.withValues(alpha: 0.6),
      height: 1.0,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: _thumbWidth,
            height: _thumbHeight,
            child: FutureBuilder<File>(
              future: MediaCacheService.instance.getImageFile(
                id: imageHash,
                cacheDuration: _cacheDuration,
                config: AppConfig.dev,
              ),
              builder: (context, snapshot) {
                final file = snapshot.data;
                if (file == null) {
                  return const SizedBox.shrink();
                }
                return RadialFadeImage(
                  file: file,
                  radius: fadeRadius,
                  stops: fadeStops,
                  colors: fadeColors,
                );
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(height: 4),
                Text(title, style: titleStyle),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatDistance(distance), style: metaStyle),
              const SizedBox(height: 6),
              Text(_formatDuration(duration), style: metaStyle),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDistance(int meters) {
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(1)} КМ';
  }

  static String _formatDuration(int minutes) {
    if (minutes <= 0) return '0М';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours <= 0) return '${mins}М';
    return '$hoursЧ ${mins}М';
  }
}
