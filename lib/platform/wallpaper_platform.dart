import '../core/errors/app_exception.dart';
import 'linux/linux_wallpaper_platform.dart';

abstract class WallpaperPlatform {
  Future<void> setWallpaper(String imagePath, {bool allMonitors = true});

  Future<String> detectEnvironment();

  static WallpaperPlatform create() {
    return LinuxWallpaperPlatform();
  }
}

/// Placeholder for macOS v2 — intentionally unsupported in v1.
class UnsupportedWallpaperPlatform implements WallpaperPlatform {
  @override
  Future<String> detectEnvironment() async => 'unsupported';

  @override
  Future<void> setWallpaper(String imagePath, {bool allMonitors = true}) {
    throw const UnsupportedDesktopException(message: 'Aplicação de wallpaper no macOS será implementada na v2',
    );
  }
}
