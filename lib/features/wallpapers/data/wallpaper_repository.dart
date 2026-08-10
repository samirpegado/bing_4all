import 'dart:io';

import '../../../core/errors/app_exception.dart';
import '../../../core/http/safe_http_client.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/wallpaper.dart';
import 'bing_fallback_api.dart';
import 'bing_primary_api.dart';
import 'wallpaper_cache.dart';

class WallpaperRepository {
  WallpaperRepository({
    required SafeHttpClient http,
    required BingPrimaryApi primaryApi,
    required BingFallbackApi fallbackApi,
    required WallpaperCache cache,
    required AppLogger logger,
  })  : _http = http,
        _primaryApi = primaryApi,
        _fallbackApi = fallbackApi,
        _cache = cache,
        _logger = logger;

  final SafeHttpClient _http;
  final BingPrimaryApi _primaryApi;
  final BingFallbackApi _fallbackApi;
  final WallpaperCache _cache;
  final AppLogger _logger;

  WallpaperCache get cache => _cache;

  Future<List<Wallpaper>> fetchWallpapers(String market) async {
    try {
      final primary = await _withShortRetry(() => _primaryApi.fetch(market));
      return _mergedList(primary);
    } on AppException catch (e) {
      _logger.warn('Primary API falhou, tentando fallback', e);
      try {
        final fallback = await _fallbackApi.fetch(market);
        return _mergedList(fallback);
      } on AppException {
        final cached = _cache.wallpapers;
        if (cached.isNotEmpty) {
          _logger.warn('Usando cache offline');
          return cached;
        }
        rethrow;
      }
    }
  }

  Future<CachedWallpaper> ensureDownloaded(Wallpaper wallpaper) async {
    if (!wallpaper.availableForWallpaper) {
      throw const WallpaperUnavailableException();
    }

    final existing = _cache.get(wallpaper.id);
    if (existing != null && await File(existing.filePath).exists()) {
      return existing;
    }

    final candidates = _downloadCandidates(wallpaper);
    Object? lastError;
    for (final url in candidates) {
      try {
        final uri = Uri.parse(url);
        _http.allowHost(uri.host);
        final bytes = await _http.getImageBytes(uri);
        return _cache.store(
          wallpaper: wallpaper.copyWith(imageUrl: url),
          bytes: bytes,
        );
      } catch (e) {
        lastError = e;
        _logger.warn('Download falhou para $url', e);
      }
    }
    throw InvalidImageException(cause: lastError);
  }

  List<String> _downloadCandidates(Wallpaper wallpaper) {
    final url = wallpaper.imageUrl;
    if (url.contains('_UHD.jpg') || url.contains('_UHD.JPG')) {
      return [url];
    }
    return BingFallbackApi.downloadCandidates(wallpaper);
  }

  List<Wallpaper> _mergedList(List<Wallpaper> remote) {
    final byId = <String, Wallpaper>{
      for (final w in _cache.wallpapers) w.id: w,
      for (final w in remote) w.id: w,
    };
    final list = byId.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list.take(16).toList(growable: false);
  }

  Future<T> _withShortRetry<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return action();
    }
  }
}
