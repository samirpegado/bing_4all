# Current Stack

## Declared stack

Document the real stack currently used by the repository.

<!-- BEGIN: AUTO-STACK -->
- **Detected variant**: `flutter-app`
- **Primary runtime**: Flutter / Dart toolchain
- **Primary language**: Dart
- **pubspec name**: `bing_4all`
- **Dart/Flutter SDK constraint**: `^3.12.2`
- **Key pubspec dependencies**: crypto, flutter, flutter_riverpod, flutter_svg, http, intl, path, path_provider, url_launcher, window_manager
- **Key pubspec dev_dependencies**: flutter_test, flutter_lints, uses-material-design, assets
<!-- END: AUTO-STACK -->

## Decisions and notes

- Alvo v1: Linux (GNOME/KDE); macOS na v2
- Dependências: `flutter_riverpod`, `http`, `path_provider`, `window_manager`, `url_launcher`, `crypto`
- Linux wallpaper: `gsettings` / `plasma-apply-wallpaperimage` / fallbacks XFCE/nitrogen
- Window lifecycle Linux via `window_manager` (bandeja AppIndicator pendente — ver `notes/linux-tray.md`)
- State management: Riverpod
- Spec: `docs/SPEC.md`
