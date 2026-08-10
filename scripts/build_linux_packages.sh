#!/usr/bin/env bash
# Empacota Bing 4All para distribuição Linux (padrão GitHub Releases).
#
# Gera em dist/:
#   bing-4all-<ver>-linux-x64.tar.gz   (portável / base Arch)
#   bing-4all_<ver>_amd64.deb          (Debian/Ubuntu)
#   bing-4all-<ver>-1.x86_64.rpm       (Fedora/RHEL, se rpmbuild existir)
#   arch/PKGBUILD                      (para makepkg / AUR)
#   SHA256SUMS
#
# Uso:
#   ./scripts/build_linux_packages.sh
#   ./scripts/build_linux_packages.sh --skip-build   # reutiliza bundle já buildado
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

APP_NAME="Bing 4All"
PKG_NAME="bing-4all"
BIN_NAME="bing_4all"
DESKTOP_ID="bing-4all"
WM_CLASS="com.samirpegado.bing_4all"
INSTALL_DIR="/usr/share/${PKG_NAME}"
ICON_NAME="bing-4all"
MAINTAINER="${MAINTAINER:-Samir <samir@localhost>}"
HOMEPAGE="${HOMEPAGE:-https://github.com/samirpegado/bing_4all}"

SKIP_BUILD=0
for arg in "$@"; do
  case "$arg" in
    --skip-build) SKIP_BUILD=1 ;;
    -h|--help)
      sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
  esac
done

VERSION_LINE="$(grep -E '^version:' pubspec.yaml | head -1 | awk '{print $2}')"
VERSION="${VERSION_LINE%%+*}"
RELEASE="${VERSION_LINE##*+}"
[[ "$RELEASE" == "$VERSION" ]] && RELEASE=1

DEB_ARCH="$(dpkg --print-architecture 2>/dev/null || echo amd64)"
RPM_ARCH="$(uname -m)"
[[ "$RPM_ARCH" == "x86_64" ]] || true

DIST_DIR="$ROOT/dist"
BUNDLE="$ROOT/build/linux/x64/release/bundle"
STAGE_FS="$DIST_DIR/stage-root"
TARBALL_DIR="$DIST_DIR/${PKG_NAME}-${VERSION}-linux-x64"
TARBALL="$DIST_DIR/${PKG_NAME}-${VERSION}-linux-x64.tar.gz"
OUT_DEB="$DIST_DIR/${PKG_NAME}_${VERSION}_${DEB_ARCH}.deb"
OUT_RPM="$DIST_DIR/${PKG_NAME}-${VERSION}-${RELEASE}.${RPM_ARCH}.rpm"
ARCH_DIR="$DIST_DIR/arch"

mkdir -p "$DIST_DIR"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Comando obrigatório ausente: $1" >&2
    exit 1
  }
}

build_flutter() {
  if [[ "$SKIP_BUILD" -eq 1 ]]; then
    echo "==> Pulando flutter build (--skip-build)"
  else
    echo "==> flutter build linux --release"
    require_cmd flutter
    flutter build linux --release
  fi
  if [[ ! -x "$BUNDLE/$BIN_NAME" ]]; then
    echo "Bundle não encontrado: $BUNDLE/$BIN_NAME" >&2
    exit 1
  fi
}

write_desktop_file() {
  local dest="$1"
  local exec_line="$2"
  local icon_value="${3:-$ICON_NAME}"
  cat > "$dest" <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=$APP_NAME
GenericName=Bing wallpapers
Comment=Wallpapers diários do Bing (não oficial)
Exec=$exec_line
Icon=$icon_value
Terminal=false
Categories=Utility;DesktopUtility;
StartupNotify=true
StartupWMClass=$WM_CLASS
EOF
}

install_hicolor_icons() {
  local root="$1"
  local sizes=(16 24 32 48 64 128 256 512)
  local src_master="$ROOT/assets/app_icon.png"

  for size in "${sizes[@]}"; do
    local dest_dir="$root/usr/share/icons/hicolor/${size}x${size}/apps"
    mkdir -p "$dest_dir"
    local packaged="$ROOT/linux/icons/hicolor/${size}x${size}/apps/bing_4all.png"
    if [[ -f "$packaged" ]]; then
      cp "$packaged" "$dest_dir/${ICON_NAME}.png"
    elif [[ -f "$src_master" ]] && command -v python3 >/dev/null 2>&1; then
      python3 - "$src_master" "$dest_dir/${ICON_NAME}.png" "$size" <<'PY'
import sys
from PIL import Image
src, dest, size = sys.argv[1], sys.argv[2], int(sys.argv[3])
im = Image.open(src).convert("RGBA")
canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
max_side = int(size * 0.9)
ratio = min(max_side / im.width, max_side / im.height)
w, h = max(1, int(im.width * ratio)), max(1, int(im.height * ratio))
logo = im.resize((w, h), Image.Resampling.LANCZOS)
canvas.paste(logo, ((size - w) // 2, (size - h) // 2), logo)
canvas.save(dest, "PNG")
PY
    elif [[ -f "$src_master" ]]; then
      cp "$src_master" "$dest_dir/${ICON_NAME}.png"
    fi
  done
}

populate_filesystem_tree() {
  local root="$1"
  rm -rf "$root"
  mkdir -p \
    "$root$INSTALL_DIR" \
    "$root/usr/bin" \
    "$root/usr/share/applications" \
    "$root/usr/share/doc/$PKG_NAME"

  cp -a "$BUNDLE/." "$root$INSTALL_DIR/"

  # Ensure data/app_icon.png exists next to the binary for native GTK icon load.
  if [[ -f "$ROOT/assets/app_icon.png" ]]; then
    mkdir -p "$root$INSTALL_DIR/data"
    cp "$ROOT/assets/app_icon.png" "$root$INSTALL_DIR/data/app_icon.png"
  fi

  cat > "$root/usr/bin/$DESKTOP_ID" <<EOF
#!/bin/sh
exec "$INSTALL_DIR/$BIN_NAME" "\$@"
EOF
  chmod 755 "$root/usr/bin/$DESKTOP_ID"

  install_hicolor_icons "$root"

  # Absolute icon path is more reliable on Cinnamon + icon themes like Papirus.
  write_desktop_file \
    "$root/usr/share/applications/${DESKTOP_ID}.desktop" \
    "$DESKTOP_ID" \
    "/usr/share/icons/hicolor/128x128/apps/${ICON_NAME}.png"

  cat > "$root/usr/share/doc/$PKG_NAME/copyright" <<EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: $APP_NAME
Source: $HOMEPAGE

Files: *
Copyright: $(date +%Y) Bing 4All contributors
License: GPL-3.0-or-later
Comment: Imagens e marcas do Bing pertencem aos respectivos proprietários.
EOF
}

build_tarball() {
  echo "==> Tarball portável"
  rm -rf "$TARBALL_DIR"
  mkdir -p "$TARBALL_DIR"
  cp -a "$BUNDLE/." "$TARBALL_DIR/"
  write_desktop_file "$TARBALL_DIR/${DESKTOP_ID}.desktop" "$BIN_NAME" "$ICON_NAME"
  if [[ -f "$ROOT/assets/app_icon.png" ]]; then
    cp "$ROOT/assets/app_icon.png" "$TARBALL_DIR/${DESKTOP_ID}.png"
    mkdir -p "$TARBALL_DIR/data"
    cp "$ROOT/assets/app_icon.png" "$TARBALL_DIR/data/app_icon.png"
  fi
  cat > "$TARBALL_DIR/install.sh" <<'EOF'
#!/bin/sh
# Instalação opcional no prefixo do usuário (~/.local)
set -eu
PREFIX="${PREFIX:-$HOME/.local}"
APP_ID="bing-4all"
WM_CLASS="com.samirpegado.bing_4all"
SRC="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
DEST="$PREFIX/share/$APP_ID"
BIN="$PREFIX/bin/$APP_ID"

mkdir -p "$DEST" "$PREFIX/bin" \
  "$PREFIX/share/applications" \
  "$PREFIX/share/icons/hicolor/48x48/apps" \
  "$PREFIX/share/icons/hicolor/128x128/apps" \
  "$PREFIX/share/icons/hicolor/512x512/apps"

rm -rf "$DEST"
mkdir -p "$DEST"
cp -a "$SRC"/. "$DEST/"
rm -f "$DEST/install.sh"

cat > "$BIN" <<WRAP
#!/bin/sh
exec "$DEST/bing_4all" "\$@"
WRAP
chmod 755 "$BIN"

ICON_PATH="$PREFIX/share/icons/hicolor/128x128/apps/${APP_ID}.png"
if [ -f "$DEST/${APP_ID}.png" ]; then
  cp "$DEST/${APP_ID}.png" "$PREFIX/share/icons/hicolor/48x48/apps/${APP_ID}.png"
  cp "$DEST/${APP_ID}.png" "$PREFIX/share/icons/hicolor/128x128/apps/${APP_ID}.png"
  cp "$DEST/${APP_ID}.png" "$PREFIX/share/icons/hicolor/512x512/apps/${APP_ID}.png"
fi

cat > "$PREFIX/share/applications/${APP_ID}.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Version=1.0
Name=Bing 4All
GenericName=Bing wallpapers
Comment=Wallpapers diários do Bing (não oficial)
Exec=$APP_ID
Icon=$ICON_PATH
Terminal=false
Categories=Utility;DesktopUtility;
StartupNotify=true
StartupWMClass=$WM_CLASS
DESKTOP

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -f -t "$PREFIX/share/icons/hicolor" >/dev/null 2>&1 || true
fi

echo "Instalado: $BIN"
echo "Abra pelo menu ou rode: $APP_ID"
EOF
  chmod 755 "$TARBALL_DIR/install.sh"

  tar -C "$DIST_DIR" -czf "$TARBALL" "$(basename "$TARBALL_DIR")"
  echo "    $TARBALL"
}

build_deb() {
  echo "==> Pacote .deb"
  require_cmd dpkg-deb
  local stage="$DIST_DIR/deb-root"
  populate_filesystem_tree "$stage"
  mkdir -p "$stage/DEBIAN"

  local installed_size
  installed_size="$(du -sk "$stage" | awk '{print $1}')"

  cat > "$stage/DEBIAN/control" <<EOF
Package: $PKG_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: $DEB_ARCH
Installed-Size: $installed_size
Depends: libgtk-3-0, libglib2.0-0, libstdc++6, libc6
Maintainer: $MAINTAINER
Description: $APP_NAME
 Cliente desktop Linux para wallpapers diários do Bing (não oficial).
 Consulta as imagens do dia, faz cache local e aplica no ambiente gráfico.
Homepage: $HOMEPAGE
EOF

  cat > "$stage/DEBIAN/postinst" <<'EOF'
#!/bin/sh
set -e
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications >/dev/null 2>&1 || true
fi
exit 0
EOF
  chmod 755 "$stage/DEBIAN/postinst"

  find "$stage" -type d -exec chmod 755 {} +
  find "$stage$INSTALL_DIR" -type f -exec chmod 644 {} +
  chmod 755 "$stage$INSTALL_DIR/$BIN_NAME" "$stage/usr/bin/$DESKTOP_ID"
  find "$stage$INSTALL_DIR/lib" -type f -name '*.so*' -exec chmod 755 {} + 2>/dev/null || true
  chmod 644 "$stage/DEBIAN/control"
  find "$stage/usr/share/icons" -type f -name '*.png' -exec chmod 644 {} + 2>/dev/null || true

  dpkg-deb --root-owner-group --build "$stage" "$OUT_DEB"
  echo "    $OUT_DEB"
}

build_rpm() {
  echo "==> Pacote .rpm"
  if ! command -v rpmbuild >/dev/null 2>&1; then
    echo "    rpmbuild não encontrado — pulando .rpm"
    echo "    Instale com: sudo apt install rpm"
    return 0
  fi

  populate_filesystem_tree "$STAGE_FS"
  local rpm_top="$DIST_DIR/rpmbuild"
  rm -rf "$rpm_top"
  mkdir -p "$rpm_top"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

  local spec="$rpm_top/SPECS/${PKG_NAME}.spec"
  cat > "$spec" <<EOF
Name:           $PKG_NAME
Version:        $VERSION
Release:        $RELEASE%{?dist}
Summary:        $APP_NAME — wallpapers diários do Bing (não oficial)
License:        GPL-3.0-or-later
URL:            $HOMEPAGE
AutoReqProv:    no

%description
Cliente desktop Linux para wallpapers diários do Bing (não oficial).

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
cp -a $STAGE_FS/. %{buildroot}/

%files
$INSTALL_DIR
/usr/bin/$DESKTOP_ID
/usr/share/applications/${DESKTOP_ID}.desktop
/usr/share/icons/hicolor
/usr/share/doc/$PKG_NAME

%changelog
* $(LC_ALL=C date '+%a %b %d %Y') $MAINTAINER - $VERSION-$RELEASE
- Empacotamento automatizado
EOF

  rpmbuild -bb \
    --define "_topdir $rpm_top" \
    --define "_build_id_links none" \
    --nocheck \
    "$spec"

  local built
  built="$(find "$rpm_top/RPMS" -type f -name '*.rpm' | head -1)"
  if [[ -z "$built" ]]; then
    echo "    Falha ao localizar RPM gerado" >&2
    return 1
  fi
  cp -f "$built" "$OUT_RPM"
  echo "    $OUT_RPM"
}

build_arch_pkgbuild() {
  echo "==> PKGBUILD (Arch)"
  mkdir -p "$ARCH_DIR"
  local tarball_name sha256
  tarball_name="$(basename "$TARBALL")"
  sha256="$(sha256sum "$TARBALL" | awk '{print $1}')"

  cat > "$ARCH_DIR/PKGBUILD" <<EOF
# Maintainer: $MAINTAINER
pkgname=$PKG_NAME-bin
pkgver=$VERSION
pkgrel=$RELEASE
pkgdesc="$APP_NAME — wallpapers diários do Bing (não oficial)"
arch=('x86_64')
url='$HOMEPAGE'
license=('GPL3')
depends=('gtk3' 'glib2')
provides=('$PKG_NAME')
conflicts=('$PKG_NAME')
options=('!strip')
# Local: deixe o tarball nesta pasta. Em AUR/GitHub Release use a URL:
# source=("\$url/releases/download/v\$pkgver/$tarball_name")
source=("$tarball_name")
sha256sums=('$sha256')

package() {
  local srcdir_app="\$srcdir/${PKG_NAME}-\${pkgver}-linux-x64"

  install -d "\$pkgdir$INSTALL_DIR"
  cp -a "\$srcdir_app"/. "\$pkgdir$INSTALL_DIR/"
  rm -f "\$pkgdir$INSTALL_DIR/install.sh" \\
        "\$pkgdir$INSTALL_DIR/${DESKTOP_ID}.desktop" \\
        "\$pkgdir$INSTALL_DIR/${DESKTOP_ID}.png"

  printf '%s\\n' '#!/bin/sh' "exec $INSTALL_DIR/$BIN_NAME \\"\\\$@\\"" \\
    | install -Dm755 /dev/stdin "\$pkgdir/usr/bin/$DESKTOP_ID"

  install -Dm644 "\$srcdir_app/${DESKTOP_ID}.desktop" \\
    "\$pkgdir/usr/share/applications/${DESKTOP_ID}.desktop"
  sed -i 's|^Exec=.*|Exec=$DESKTOP_ID|' \\
    "\$pkgdir/usr/share/applications/${DESKTOP_ID}.desktop"

  if [[ -f "\$srcdir_app/${DESKTOP_ID}.png" ]]; then
    install -Dm644 "\$srcdir_app/${DESKTOP_ID}.png" \\
      "\$pkgdir/usr/share/icons/hicolor/512x512/apps/${DESKTOP_ID}.png"
  fi
}
EOF

  cp -f "$TARBALL" "$ARCH_DIR/"
  echo "    $ARCH_DIR/PKGBUILD"
  echo "    (makepkg local: cd dist/arch && makepkg -si)"
}

write_checksums() {
  echo "==> SHA256SUMS"
  (
    cd "$DIST_DIR"
    rm -f SHA256SUMS
    # shellcheck disable=SC2035
    sha256sum *.deb *.rpm *.tar.gz 2>/dev/null > SHA256SUMS || true
    if [[ ! -s SHA256SUMS ]]; then
      find . -maxdepth 1 -type f \( -name '*.deb' -o -name '*.rpm' -o -name '*.tar.gz' \) \
        -exec sha256sum {} + > SHA256SUMS
    fi
  )
  echo "    $DIST_DIR/SHA256SUMS"
}

build_flutter
build_tarball
build_deb
build_rpm
build_arch_pkgbuild
write_checksums

echo
echo "Artefatos em $DIST_DIR:"
ls -lh "$DIST_DIR"/*.{deb,rpm,tar.gz} 2>/dev/null || ls -lh "$DIST_DIR"
echo
echo "Release no GitHub (tag v$VERSION):"
echo "  git tag v$VERSION && git push origin v$VERSION"
echo "  # ou: gh release create v$VERSION dist/*.deb dist/*.rpm dist/*.tar.gz dist/SHA256SUMS --generate-notes"
