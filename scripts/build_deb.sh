#!/usr/bin/env bash
# Compat: gera apenas o .deb (via script unificado).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "$ROOT/scripts/build_linux_packages.sh" "$@"
