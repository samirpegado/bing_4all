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
  static const iconName = 'bing-4all';
  static const wmClass = 'com.samirpegado.bing_4all';

  File get _desktopFile {
    final home = Platform.environment['HOME'] ?? '';
    return File(p.join(home, '.config', 'autostart', 'bing-4all.desktop'));
  }

  /// Legacy autostart filename from earlier builds.
  File get _legacyDesktopFile {
    final home = Platform.environment['HOME'] ?? '';
    return File(p.join(home, '.config', 'autostart', 'bing_4all.desktop'));
  }

  String get _systemIconPath =>
      '/usr/share/icons/hicolor/128x128/apps/$iconName.png';

  @override
  Future<void> installIcon() async {
    final home = Platform.environment['HOME'] ?? '';
    if (home.isEmpty) return;

    final data = await rootBundle.load('assets/app_icon.png');
    final bytes = data.buffer.asUint8List();
    for (final size in const [48, 64, 128, 256, 512]) {
      final iconFile = File(
        p.join(
          home,
          '.local',
          'share',
          'icons',
          'hicolor',
          '${size}x$size',
          'apps',
          '$iconName.png',
        ),
      );
      await iconFile.parent.create(recursive: true);
      await iconFile.writeAsBytes(bytes, flush: true);
    }
  }

  @override
  Future<bool> isEnabled() async {
    if (await _desktopFile.exists()) return true;
    return _legacyDesktopFile.exists();
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    if (!enabled) {
      if (await _desktopFile.exists()) await _desktopFile.delete();
      if (await _legacyDesktopFile.exists()) await _legacyDesktopFile.delete();
      return;
    }

    final executable = Platform.resolvedExecutable;
    await installIcon();
    await _desktopFile.parent.create(recursive: true);

    // Prefer themed name; absolute path as fallback for Cinnamon/Papirus.
    final iconValue =
        await File(_systemIconPath).exists() ? _systemIconPath : iconName;

    await _desktopFile.writeAsString('''
[Desktop Entry]
Type=Application
Version=1.0
Name=Bing 4All
Comment=Wallpapers diários do Bing (não oficial)
Exec=$executable
Icon=$iconValue
Terminal=false
Categories=Utility;
StartupNotify=true
StartupWMClass=$wmClass
X-GNOME-Autostart-enabled=true
''');

    // Remove legacy file to avoid duplicate autostart entries.
    if (await _legacyDesktopFile.exists()) {
      await _legacyDesktopFile.delete();
    }
  }
}
