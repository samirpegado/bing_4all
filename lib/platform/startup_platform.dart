import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

abstract class StartupPlatform {
  Future<bool> isEnabled();
  Future<void> setEnabled(bool enabled);

  /// Installs the app icon into the user icon theme (Linux).
  Future<void> installIcon();

  static StartupPlatform create() => LinuxStartupPlatform();
}

/// XDG autostart (.desktop) for Linux.
class LinuxStartupPlatform implements StartupPlatform {
  File get _desktopFile {
    final home = Platform.environment['HOME'] ?? '';
    return File(p.join(home, '.config', 'autostart', 'bing_4all.desktop'));
  }

  @override
  Future<void> installIcon() async {
    final home = Platform.environment['HOME'] ?? '';
    if (home.isEmpty) return;

    final data = await rootBundle.load('assets/app_icon.png');
    final iconFile = File(
      p.join(
        home,
        '.local',
        'share',
        'icons',
        'hicolor',
        '512x512',
        'apps',
        'bing_4all.png',
      ),
    );
    await iconFile.parent.create(recursive: true);
    await iconFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
  }

  @override
  Future<bool> isEnabled() => _desktopFile.exists();

  @override
  Future<void> setEnabled(bool enabled) async {
    if (!enabled) {
      if (await _desktopFile.exists()) {
        await _desktopFile.delete();
      }
      return;
    }

    final executable = Platform.resolvedExecutable;
    await installIcon();
    await _desktopFile.parent.create(recursive: true);
    await _desktopFile.writeAsString('''
[Desktop Entry]
Type=Application
Version=1.0
Name=Bing 4All
Comment=Wallpapers diários do Bing (não oficial)
Exec=$executable
Icon=bing_4all
Terminal=false
Categories=Utility;
X-GNOME-Autostart-enabled=true
''');
  }
}
