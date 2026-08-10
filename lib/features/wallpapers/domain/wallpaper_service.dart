import 'dart:io';

import '../../../core/errors/app_exception.dart';
import '../../../core/logging/app_logger.dart';
import '../../../platform/startup_platform.dart';
import '../../../platform/wallpaper_platform.dart';
import '../../settings/data/app_state_store.dart';
import '../../settings/domain/app_settings.dart';
import '../data/wallpaper_cache.dart';
import '../data/wallpaper_repository.dart';
import 'market.dart';
import 'wallpaper.dart';

class WallpaperService {
  WallpaperService({
    required WallpaperRepository repository,
    required WallpaperPlatform wallpaperPlatform,
    required StartupPlatform startupPlatform,
    required AppStateStore stateStore,
    required AppLogger logger,
  })  : _repository = repository,
        _wallpaperPlatform = wallpaperPlatform,
        _startupPlatform = startupPlatform,
        _stateStore = stateStore,
        _logger = logger;

  final WallpaperRepository _repository;
  final WallpaperPlatform _wallpaperPlatform;
  final StartupPlatform _startupPlatform;
  final AppStateStore _stateStore;
  final AppLogger _logger;

  Future<List<Wallpaper>> refresh(AppSettings settings) async {
    final market = resolveMarket(settings.market);
    try {
      final items = await _repository.fetchWallpapers(market);
      await _stateStore.save(
        (await _stateStore.load()).copyWith(clearError: true),
      );
      return items;
    } on AppException catch (e) {
      await _persistError(e.message);
      rethrow;
    }
  }

  Future<void> applyWallpaper(
    Wallpaper wallpaper,
    AppSettings settings,
  ) async {
    final cached = await _repository.ensureDownloaded(wallpaper);
    final state = await _stateStore.load();

    await _wallpaperPlatform.setWallpaper(
      cached.filePath,
      allMonitors: settings.applyToAllMonitors,
    );

    await _repository.cache.enforceLimit(
      limitMb: settings.cacheLimitMb,
      protectId: wallpaper.id,
    );

    await _stateStore.save(
      state.copyWith(
        lastSuccessfulUpdate: DateTime.now(),
        previousWallpaperId: state.currentWallpaperId,
        previousWallpaperPath: state.currentWallpaperId == null
            ? state.previousWallpaperPath
            : _repository.cache.get(state.currentWallpaperId!)?.filePath,
        currentWallpaperId: wallpaper.id,
        clearError: true,
      ),
    );

    if (settings.downloadDirectory.trim().isNotEmpty) {
      await _copyToDownloads(cached, settings.downloadDirectory);
    }

    _logger.info('Wallpaper aplicado: ${wallpaper.id}');
  }

  Future<void> maybeAutoUpdate(AppSettings settings) async {
    if (!settings.autoUpdate) return;
    final state = await _stateStore.load();
    final last = state.lastSuccessfulUpdate;
    final now = DateTime.now();
    final alreadyToday = last != null &&
        last.year == now.year &&
        last.month == now.month &&
        last.day == now.day;
    if (alreadyToday) return;

    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      settings.updateHour,
      settings.updateMinute,
    );
    if (now.isBefore(scheduled) && last != null) return;

    final items = await refresh(settings);
    if (items.isEmpty) return;
    await applyWallpaper(items.first, settings);
  }

  Future<void> syncStartup(AppSettings settings) async {
    await _startupPlatform.setEnabled(settings.launchAtStartup);
  }

  Future<void> restorePreviousIfNeeded(AppSettings settings) async {
    if (!settings.restorePreviousOnExit) return;
    final state = await _stateStore.load();
    final path = state.previousWallpaperPath;
    if (path == null || !await File(path).exists()) return;
    await _wallpaperPlatform.setWallpaper(
      path,
      allMonitors: settings.applyToAllMonitors,
    );
  }

  Future<String> desktopEnvironment() =>
      _wallpaperPlatform.detectEnvironment();

  Future<void> _copyToDownloads(CachedWallpaper cached, String dir) async {
    try {
      final directory = Directory(dir);
      await directory.create(recursive: true);
      final target = File('${directory.path}/${cached.wallpaper.id}.jpg');
      await File(cached.filePath).copy(target.path);
    } catch (e) {
      _logger.warn('Falha ao copiar para downloads', e);
    }
  }

  Future<void> _persistError(String message) async {
    final state = await _stateStore.load();
    await _stateStore.save(state.copyWith(lastError: message));
  }
}
