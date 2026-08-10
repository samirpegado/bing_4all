import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/logging/app_logger.dart';
import 'core/storage/app_paths.dart';
import 'features/tray/tray_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final paths = await AppPaths.resolve();
  final logger = AppLogger(paths.logsDir);
  await logger.init();

  final container = ProviderContainer(
    overrides: [
      appPathsProvider.overrideWithValue(paths),
      appLoggerProvider.overrideWithValue(logger),
    ],
  );

  final cache = container.read(wallpaperCacheProvider);
  await cache.load();
  await container.read(settingsProvider.notifier).load();

  final tray = TrayController();
  if (Platform.isLinux) {
    await windowManager.ensureInitialized();
    await windowManager.setPreventClose(true);
    await tray.init();
  }

  final settings = container.read(settingsProvider);
  final service = container.read(wallpaperServiceProvider);
  final startup = container.read(startupPlatformProvider);
  if (Platform.isLinux) {
    await startup.installIcon();
  }
  await service.syncStartup(settings);

  unawaited(() async {
    try {
      await container.read(wallpapersProvider.notifier).refresh();
      await service.maybeAutoUpdate(container.read(settingsProvider));
    } catch (e) {
      logger.warn('Bootstrap de wallpapers falhou', e);
    }
  }());

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const Bing4AllApp(),
    ),
  );
}
