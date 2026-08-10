# Contributing

Thanks for helping improve Bing 4All.

## Before you start

- Read [`docs/SPEC.md`](docs/SPEC.md) for product and architecture intent.
- Linux is the supported target for v1; macOS is planned for v2.
- Keep changes small and reviewable.

## Development setup

```bash
# Dependencies (Ubuntu/Debian)
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev

flutter pub get
flutter analyze
flutter test
flutter run -d linux
```

## Branch & commits

1. Create a branch from `main` / `master`.
2. Prefer focused commits with clear messages (why > what).
3. Open a pull request describing the change and how you tested it.

## Code guidelines

- Follow existing architecture under `lib/` (`app`, `core`, `features`, `platform`).
- UI must not shell out to the OS directly — use platform adapters.
- Prefer Riverpod for state.
- Add/adjust unit tests for parsing, market resolution, and platform adapters when possible.
- Do not commit secrets, tokens, or personal data.

## Packaging

```bash
./scripts/build_linux_packages.sh
```

See [`linux/packaging/README.md`](linux/packaging/README.md).

## Reporting issues

Use GitHub Issues with:
- OS / desktop environment (e.g. Ubuntu 24.04 + GNOME Wayland)
- App version or commit
- Steps to reproduce
- Expected vs actual behavior
- Logs from the app data directory when relevant (no personal data)
