import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:cyberdriver/core/config/app_config.dart';

class MediaCacheService {
  MediaCacheService._();

  static final MediaCacheService instance = MediaCacheService._();

  final Map<Duration, CacheManager> _managers = {};

  Future<File> getImageFile({
    required String id,
    Duration cacheDuration = const Duration(days: 7),
    bool forceRefresh = false,
    AppConfig config = AppConfig.dev,
  }) async {
    final url = _buildImageUrl(id, config);
    final manager = _managerFor(cacheDuration);

    if (forceRefresh) {
      await manager.removeFile(url);
    }

    return manager.getSingleFile(url);
  }

  CacheManager _managerFor(Duration duration) {
    return _managers.putIfAbsent(
      duration,
      () => CacheManager(
        Config(
          'media-cache-${duration.inSeconds}',
          stalePeriod: duration,
          maxNrOfCacheObjects: 200,
        ),
      ),
    );
  }

  String _buildImageUrl(String id, AppConfig config) {
    final base = config.apiBaseUrl ?? '';
    final baseTrimmed = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    return '$baseTrimmed/api/${config.apiVersion}/images/$id';
  }

  Future<void> clearAll() async {
    for (final manager in _managers.values) {
      await manager.emptyCache();
    }
  }
}
