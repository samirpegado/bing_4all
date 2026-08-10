# Technical Requirements

## Required capabilities

- Flutter UI + bandeja (Linux) / menu bar (macOS)
- Fetch do endpoint principal e fallback; normalização para modelo interno
- Download UHD com validação de Content-Type; cache com limite configurável
- Aplicação de wallpaper em monitores selecionados (MVP: todos / comportamento por monitor básico)
- Agendamento diário, update no start e ao retornar de suspensão
- Preferência de mercado (`mkt`) inferida do sistema, fallback `en-US`
- Inicialização com o sistema (macOS `SMAppService`; Linux conforme DE)

## Integrations

- Bing primary + fallback APIs (HTTPS only)
- macOS: `NSWorkspace.setDesktopImageURL`, `NSScreen`, menu bar app
- Linux: GNOME/Ubuntu `gsettings`; KDE `plasma-apply-wallpaperimage`/DBus; fallback `nitrogen` quando instalado

## Environments

- Desenvolvimento local com Flutter SDK (`^3.12.2`)
- Sem variáveis de ambiente obrigatórias / sem `.env.example`
- Dados do usuário em diretório local de app-data (config, state, logs, cache)

## Explicit context decisions

Record decisions that cannot be inferred from repository files in `.ai/project/context-decisions.json`. Keep a value as `undecided` only while the corresponding question remains open.

<!-- BEGIN: AUTO-TECH-BASELINE -->
Baseline técnico inferido automaticamente:

- **Detected variant**: `flutter-app`
- **Primary runtime**: Flutter / Dart toolchain
- **Primary language**: Dart
- **pubspec name**: `bing_4all`
- **Dart/Flutter SDK constraint**: `^3.12.2`
- **Key pubspec dependencies**: crypto, flutter, flutter_riverpod, flutter_svg, http, intl, path, path_provider, url_launcher, window_manager
- **Key pubspec dev_dependencies**: flutter_test, flutter_lints, uses-material-design, assets

Lacunas restantes:

- Nenhuma lacuna crítica detectada pelo bootstrap automático.
<!-- END: AUTO-TECH-BASELINE -->
