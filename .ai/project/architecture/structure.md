# Project Structure

## Intent

App Flutter desktop com camadas por feature (`wallpapers`, `settings`, `tray`), núcleo compartilhado (`core`) e adaptadores de plataforma (`platform`). A UI não deve executar comandos do sistema diretamente.

<!-- BEGIN: AUTO-STRUCTURE -->
## Detected top-level directories
- `.agents/`
- `.ai/`
- `.cursor/`
- `.docs/`
- `.github/`
- `.kiro/`
- `.vscode/`
- `assets/`
- `docs/`
- `lib/`
- `linux/`
- `macos/`
- `scripts/`
- `test/`
- `web/`

## Detected top-level files
- `.flutter-plugins-dependencies`
- `.gitattributes`
- `.gitignore`
- `.metadata`
- `AGENTS.md`
- `analysis_options.yaml`
- `bing_4all.iml`
- `CHANGELOG.md`
- `CLAUDE.md`
- `CODE_OF_CONDUCT.md`
- `CONTRIBUTING.md`
- `GEMINI.md`
- `LICENSE`
- `PRIVACY.md`
- `pubspec.lock`
- `pubspec.yaml`
- `README.md`
- `SECURITY.md`
<!-- END: AUTO-STRUCTURE -->

## Manual notes

Estrutura implementada (Linux-first):

```text
lib/
├── app/          # app.dart, providers, theme
├── core/         # errors, http, logging, storage
├── features/
│   ├── wallpapers/  # data / domain / presentation
│   ├── settings/
│   └── tray/
├── platform/     # linux wallpaper/startup/monitor
└── main.dart
```

macOS runner existe no scaffold, mas aplicação de wallpaper/menu bar fica para v2.
