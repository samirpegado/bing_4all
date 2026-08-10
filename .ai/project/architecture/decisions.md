# Architecture Decisions

Use this file as a lightweight ADR log.

## ADR-0001 - Flutter desktop multiplataforma

- **Status**: accepted
- **Context**: produto precisa de UI leve + bandeja/menu bar em Linux e macOS
- **Decision**: usar Flutter para interface; código de plataforma isolado em adapters (`WallpaperPlatform`, `StartupPlatform`, `MonitorPlatform`)
- **Consequences**: UI não chama comandos do SO diretamente; macOS via Method Channels/Swift; Linux via adaptadores por DE

## ADR-0002 - Fonte de imagens Bing com fallback

- **Status**: accepted
- **Context**: endpoint principal pode falhar ou mudar; não há contrato estável público
- **Decision**: endpoint principal `services.bingapis.com/.../hpimages`; fallback `HPImageArchive.aspx`; cache local e sem chave de API
- **Consequences**: normalização de dois formatos JSON; testes com fixtures; falha de rede não remove wallpaper atual

## ADR-0003 - State management Flutter

- **Status**: accepted
- **Context**: era necessário fixar a abordagem antes das features
- **Decision**: Riverpod (`flutter_riverpod`)
- **Consequences**: providers como fronteira de estado/async; UI consome via `ConsumerWidget`/`ref`; evitar misturar outros state managers sem ADR nova

## ADR-0004 - Linux-first, macOS na v2

- **Status**: accepted
- **Context**: acelerar MVP utilizável; integração nativa macOS (menu bar, Method Channels) exige esforço separado
- **Decision**: v1 foca Linux (GNOME/KDE + fallbacks); macOS fica para v2
- **Consequences**: `WallpaperPlatform.create()` usa implementação Linux; bandeja via `tray_manager`/`window_manager`; autostart via XDG `.desktop`
