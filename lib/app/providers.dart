import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/http/safe_http_client.dart';
import '../core/logging/app_logger.dart';
import '../core/storage/app_paths.dart';
import '../features/settings/data/app_state_store.dart';
import '../features/settings/data/settings_store.dart';
import '../features/settings/domain/app_settings.dart';
import '../features/wallpapers/data/bing_fallback_api.dart';
import '../features/wallpapers/data/bing_primary_api.dart';
import '../features/wallpapers/data/wallpaper_cache.dart';
import '../features/wallpapers/data/wallpaper_repository.dart';
import '../features/wallpapers/domain/wallpaper.dart';
import '../features/wallpapers/domain/wallpaper_service.dart';
import '../platform/startup_platform.dart';
import '../platform/wallpaper_platform.dart';

final appPathsProvider = Provider<AppPaths>((ref) {
  throw UnimplementedError('AppPaths deve ser sobrescrito no bootstrap');
});

final appLoggerProvider = Provider<AppLogger>((ref) {
  throw UnimplementedError('AppLogger deve ser sobrescrito no bootstrap');
});

final safeHttpClientProvider = Provider<SafeHttpClient>((ref) {
  final client = SafeHttpClient();
  ref.onDispose(client.close);
  return client;
});

final settingsStoreProvider = Provider<SettingsStore>((ref) {
  return SettingsStore(ref.watch(appPathsProvider));
});

final appStateStoreProvider = Provider<AppStateStore>((ref) {
  return AppStateStore(ref.watch(appPathsProvider));
});

final wallpaperCacheProvider = Provider<WallpaperCache>((ref) {
  return WallpaperCache(ref.watch(appPathsProvider));
});

final wallpaperRepositoryProvider = Provider<WallpaperRepository>((ref) {
  final http = ref.watch(safeHttpClientProvider);
  return WallpaperRepository(
    http: http,
    primaryApi: BingPrimaryApi(http),
    fallbackApi: BingFallbackApi(http),
    cache: ref.watch(wallpaperCacheProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final wallpaperPlatformProvider = Provider<WallpaperPlatform>((ref) {
  return WallpaperPlatform.create();
});

final startupPlatformProvider = Provider<StartupPlatform>((ref) {
  return StartupPlatform.create();
});

final wallpaperServiceProvider = Provider<WallpaperService>((ref) {
  return WallpaperService(
    repository: ref.watch(wallpaperRepositoryProvider),
    wallpaperPlatform: ref.watch(wallpaperPlatformProvider),
    startupPlatform: ref.watch(startupPlatformProvider),
    stateStore: ref.watch(appStateStoreProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final settingsProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  return SettingsController(ref.watch(settingsStoreProvider));
});

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._store) : super(const AppSettings());

  final SettingsStore _store;

  Future<void> load() async {
    state = await _store.load();
  }

  Future<void> update(AppSettings Function(AppSettings) transform) async {
    state = transform(state);
    await _store.save(state);
  }
}

final selectedIndexProvider = StateProvider<int>((ref) => 0);

final wallpapersProvider =
    StateNotifierProvider<WallpapersController, AsyncValue<List<Wallpaper>>>(
        (ref) {
  return WallpapersController(ref);
});

class WallpapersController
    extends StateNotifier<AsyncValue<List<Wallpaper>>> {
  WallpapersController(this._ref) : super(const AsyncValue.loading());

  final Ref _ref;

  Wallpaper? get selected {
    final index = _ref.read(selectedIndexProvider);
    return state.maybeWhen(
      data: (items) =>
          items.isEmpty ? null : items[index.clamp(0, items.length - 1)],
      orElse: () => null,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final settings = _ref.read(settingsProvider);
    final service = _ref.read(wallpaperServiceProvider);
    state = await AsyncValue.guard(() => service.refresh(settings));
    _ref.read(selectedIndexProvider.notifier).state = 0;
  }

  void selectPrevious() {
    final items = state.valueOrNull;
    if (items == null || items.isEmpty) return;
    final current = _ref.read(selectedIndexProvider);
    _ref.read(selectedIndexProvider.notifier).state =
        (current - 1).clamp(0, items.length - 1);
  }

  void selectNext() {
    final items = state.valueOrNull;
    if (items == null || items.isEmpty) return;
    final current = _ref.read(selectedIndexProvider);
    _ref.read(selectedIndexProvider.notifier).state =
        (current + 1).clamp(0, items.length - 1);
  }

  void selectIndex(int index) {
    final items = state.valueOrNull;
    if (items == null || items.isEmpty) return;
    _ref.read(selectedIndexProvider.notifier).state =
        index.clamp(0, items.length - 1);
  }

  Future<void> applySelected() async {
    final wallpaper = selected;
    if (wallpaper == null) return;
    final settings = _ref.read(settingsProvider);
    await _ref.read(wallpaperServiceProvider).applyWallpaper(wallpaper, settings);
  }

  Future<void> downloadSelected() async {
    final wallpaper = selected;
    if (wallpaper == null) return;
    await _ref.read(wallpaperRepositoryProvider).ensureDownloaded(wallpaper);
  }
}

final runtimeStateProvider = FutureProvider<AppRuntimeState>((ref) async {
  return ref.watch(appStateStoreProvider).load();
});

final desktopEnvironmentProvider = FutureProvider<String>((ref) {
  return ref.watch(wallpaperServiceProvider).desktopEnvironment();
});
