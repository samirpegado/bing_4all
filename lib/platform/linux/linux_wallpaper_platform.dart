import 'dart:io';

import '../../core/errors/app_exception.dart';
import '../wallpaper_platform.dart';

enum LinuxDesktopEnvironment {
  gnome,
  kde,
  xfce,
  cinnamon,
  mate,
  unknown,
}

class LinuxWallpaperPlatform implements WallpaperPlatform {
  LinuxWallpaperPlatform({
    Future<ProcessResult> Function(String, List<String>)? run,
    LinuxDesktopEnvironment? desktopOverride,
    Map<String, String>? environment,
  })  : _run = run ?? Process.run,
        _desktopOverride = desktopOverride,
        _environment = environment ?? Platform.environment;

  final Future<ProcessResult> Function(String executable, List<String> arguments)
      _run;
  final LinuxDesktopEnvironment? _desktopOverride;
  final Map<String, String> _environment;

  @override
  Future<String> detectEnvironment() async {
    return _detectDesktop().name;
  }

  @override
  Future<void> setWallpaper(String imagePath, {bool allMonitors = true}) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw ApplyWallpaperException(message: 'Arquivo não encontrado: $imagePath');
    }

    final desktop = _detectDesktop();
    try {
      switch (desktop) {
        case LinuxDesktopEnvironment.gnome:
        case LinuxDesktopEnvironment.cinnamon:
        case LinuxDesktopEnvironment.mate:
          await _setGsettings(imagePath);
        case LinuxDesktopEnvironment.kde:
          await _setKde(imagePath);
        case LinuxDesktopEnvironment.xfce:
          await _setXfce(imagePath);
        case LinuxDesktopEnvironment.unknown:
          await _setNitrogen(imagePath);
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApplyWallpaperException(cause: e);
    }
  }

  LinuxDesktopEnvironment _detectDesktop() {
    if (_desktopOverride != null) return _desktopOverride;
    final raw = (_environment['XDG_CURRENT_DESKTOP'] ??
            _environment['DESKTOP_SESSION'] ??
            '')
        .toLowerCase();
    if (raw.contains('gnome') || raw.contains('ubuntu')) {
      return LinuxDesktopEnvironment.gnome;
    }
    if (raw.contains('kde') || raw.contains('plasma')) {
      return LinuxDesktopEnvironment.kde;
    }
    if (raw.contains('xfce')) return LinuxDesktopEnvironment.xfce;
    if (raw.contains('cinnamon')) return LinuxDesktopEnvironment.cinnamon;
    if (raw.contains('mate')) return LinuxDesktopEnvironment.mate;
    return LinuxDesktopEnvironment.unknown;
  }

  Future<void> _setGsettings(String imagePath) async {
    final uri = Uri.file(imagePath).toString();
    final keys = [
      ['org.gnome.desktop.background', 'picture-uri'],
      ['org.gnome.desktop.background', 'picture-uri-dark'],
    ];
    for (final key in keys) {
      final result = await _run('gsettings', ['set', key[0], key[1], uri]);
      if (result.exitCode != 0 && key[1] == 'picture-uri') {
        throw ApplyWallpaperException(message: 'gsettings falhou: ${result.stderr}'.trim(),
        );
      }
    }
    await _run('gsettings', [
      'set',
      'org.gnome.desktop.background',
      'picture-options',
      'zoom',
    ]);
  }

  Future<void> _setKde(String imagePath) async {
    final script = '''
var allDesktops = desktops();
for (i=0;i<allDesktops.length;i++) {
  d = allDesktops[i];
  d.wallpaperPlugin = "org.kde.image";
  d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
  d.writeConfig("Image", "file://$imagePath");
}
''';
    final plasma = await _run('plasma-apply-wallpaperimage', [imagePath]);
    if (plasma.exitCode == 0) return;

    final qdbus = await _run('qdbus', [
      'org.kde.plasmashell',
      '/PlasmaShell',
      'org.kde.PlasmaShell.evaluateScript',
      script,
    ]);
    if (qdbus.exitCode != 0) {
      throw ApplyWallpaperException(message: 'KDE wallpaper falhou: ${plasma.stderr} ${qdbus.stderr}'.trim(),
      );
    }
  }

  Future<void> _setXfce(String imagePath) async {
    final props = await _run('xfconf-query', [
      '-c',
      'xfce4-desktop',
      '-l',
    ]);
    if (props.exitCode != 0) {
      throw ApplyWallpaperException(message: 'xfconf-query indisponível');
    }
    final lines = props.stdout
        .toString()
        .split('\n')
        .where((l) => l.contains('last-image'))
        .toList();
    if (lines.isEmpty) {
      throw const UnsupportedDesktopException(message: 'Não foi possível localizar monitores XFCE',
      );
    }
    for (final prop in lines) {
      final result = await _run('xfconf-query', [
        '-c',
        'xfce4-desktop',
        '-p',
        prop.trim(),
        '-s',
        imagePath,
      ]);
      if (result.exitCode != 0) {
        throw ApplyWallpaperException(message: 'xfce falhou em $prop');
      }
    }
  }

  Future<void> _setNitrogen(String imagePath) async {
    final which = await _run('which', ['nitrogen']);
    if (which.exitCode != 0) {
      throw const UnsupportedDesktopException();
    }
    final result = await _run('nitrogen', [
      '--set-zoom-fill',
      '--save',
      imagePath,
    ]);
    if (result.exitCode != 0) {
      throw ApplyWallpaperException(message: 'nitrogen falhou: ${result.stderr}'.trim(),
      );
    }
  }
}
