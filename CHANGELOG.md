# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Planned
- System tray (AppIndicator) on Linux
- macOS menu bar support (v2)

## [1.0.0] - 2026-08-10

First stable Linux release.

### Added
- Linux desktop client (Flutter) for daily Bing wallpapers
- Primary Bing API + HPImageArchive fallback
- Local image cache with configurable size limit
- Apply wallpaper on GNOME and KDE (XFCE/nitrogen fallbacks)
- Compact UI with gallery, apply/download, and settings
- XDG autostart and automatic daily update while the app is running
- Packaging for `.deb`, `.rpm`, and portable `.tar.gz`
- GitHub Actions release workflow for `v*` tags

### Fixed
- App menu and taskbar icons on Cinnamon / Papirus (multi-size hicolor icons, icon cache, absolute `Icon=` path)
- Autostart `.desktop` icon name and `StartupWMClass` matching the GTK application id
- Analyzer infos that caused CI `flutter analyze` to fail

## [0.1.0] - 2026-08-09

Initial public scaffold and packaging pipeline (superseded by 1.0.0).

[Unreleased]: https://github.com/samirpegado/bing_4all/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/samirpegado/bing_4all/releases/tag/v1.0.0
[0.1.0]: https://github.com/samirpegado/bing_4all/releases/tag/v0.1.0
