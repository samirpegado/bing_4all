import 'dart:io';

import 'package:bing_4all/platform/linux/linux_wallpaper_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GNOME usa gsettings picture-uri', () async {
    final calls = <List<String>>[];
    final platform = LinuxWallpaperPlatform(
      desktopOverride: LinuxDesktopEnvironment.gnome,
      run: (exe, args) async {
        calls.add([exe, ...args]);
        return ProcessResult(0, 0, '', '');
      },
    );

    final temp = File('${Directory.systemTemp.path}/bing4all_wp_test.jpg');
    await temp.writeAsBytes([0xFF, 0xD8, 0xFF, 0xD9]);

    await platform.setWallpaper(temp.path);

    expect(calls.first.first, 'gsettings');
    expect(calls.first, contains('picture-uri'));
    expect(
      calls.any((c) => c.contains('picture-uri-dark')),
      isTrue,
    );
  });

  test('KDE tenta plasma-apply-wallpaperimage', () async {
    final calls = <List<String>>[];
    final platform = LinuxWallpaperPlatform(
      desktopOverride: LinuxDesktopEnvironment.kde,
      run: (exe, args) async {
        calls.add([exe, ...args]);
        return ProcessResult(0, 0, '', '');
      },
    );

    final temp = File('${Directory.systemTemp.path}/bing4all_wp_kde.jpg');
    await temp.writeAsBytes([0xFF, 0xD8, 0xFF, 0xD9]);

    await platform.setWallpaper(temp.path);
    expect(calls.first.first, 'plasma-apply-wallpaperimage');
  });
}
