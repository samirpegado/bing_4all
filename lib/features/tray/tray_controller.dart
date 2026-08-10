import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Linux window lifecycle helper.
///
/// Full system-tray (AppIndicator) requires `libayatana-appindicator3-dev`
/// and will return in a follow-up once the host package is available.
class TrayController with WindowListener {
  Future<void> init() async {
    if (kIsWeb || !Platform.isLinux) return;

    await windowManager.ensureInitialized();
    const options = WindowOptions(
      size: Size(440, 720),
      minimumSize: Size(380, 560),
      center: true,
      title: 'Bing 4All',
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.setTitle('Bing 4All');
      await _setWindowIcon();
      await windowManager.show();
      await windowManager.focus();
    });

    windowManager.addListener(this);
  }

  Future<void> _setWindowIcon() async {
    // Prefer absolute packaged icon; fall back to Flutter asset path.
    const candidates = <String>[
      '/usr/share/bing-4all/data/app_icon.png',
      '/usr/share/icons/hicolor/128x128/apps/bing-4all.png',
      '/usr/share/icons/hicolor/48x48/apps/bing-4all.png',
    ];
    for (final path in candidates) {
      if (await File(path).exists()) {
        try {
          // window_manager joins with data/flutter_assets unless absolute.
          // Absolute paths still work on Linux after join semantics reset.
          await windowManager.setIcon(path);
          return;
        } catch (_) {}
      }
    }
    try {
      await windowManager.setIcon('assets/app_icon.png');
    } catch (_) {}
  }

  @override
  void onWindowClose() async {
    // Keep process alive for background auto-update; hide instead of quit.
    await windowManager.hide();
  }

  Future<void> dispose() async {
    windowManager.removeListener(this);
  }
}
