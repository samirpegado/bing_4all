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
      // Path is resolved under data/flutter_assets/ by window_manager.
      await windowManager.setIcon('assets/app_icon.png');
      await windowManager.show();
      await windowManager.focus();
    });

    windowManager.addListener(this);
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
