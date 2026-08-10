# Empacotamento Linux e GitHub Releases

## Artefatos gerados

```bash
./scripts/build_linux_packages.sh
```

Em `dist/`:

| Arquivo | Uso |
|---------|-----|
| `bing-4all_<ver>_amd64.deb` | Debian, Ubuntu, Mint, Pop!_OS |
| `bing-4all-<ver>-1.x86_64.rpm` | Fedora, RHEL (precisa de `rpm`/`rpmbuild` no host) |
| `bing-4all-<ver>-linux-x64.tar.gz` | Portável + base para Arch |
| `arch/PKGBUILD` | `makepkg` local / base para AUR |
| `SHA256SUMS` | Checksums para a Release |

## Como as pessoas publicam no GitHub

Fluxo usual:

1. Atualizar `version:` no `pubspec.yaml` (ex.: `0.1.0+1`)
2. Commit
3. Criar e enviar tag anotada:

```bash
git tag -a v0.1.0 -m "Bing 4All 0.1.0"
git push origin v0.1.0
```

4. O workflow [`.github/workflows/release-linux.yml`](../../.github/workflows/release-linux.yml) sobe Flutter, gera os pacotes e cria a **GitHub Release** com os arquivos anexados.

### Manual (sem CI)

```bash
./scripts/build_linux_packages.sh
gh release create v0.1.0 \
  dist/*.deb dist/*.rpm dist/*.tar.gz dist/SHA256SUMS \
  --title "Bing 4All 0.1.0" \
  --generate-notes
```

## Instalação pelo usuário final

**Ubuntu/Debian**

```bash
sudo apt install ./bing-4all_0.1.0_amd64.deb
```

**Fedora**

```bash
sudo dnf install ./bing-4all-0.1.0-1.x86_64.rpm
```

**Arch (a partir do tarball + PKGBUILD)**

```bash
cd dist/arch
# copie o .tar.gz para esta pasta (o script já faz isso)
makepkg -si
```

**Tarball em qualquer distro**

```bash
tar -xzf bing-4all-0.1.0-linux-x64.tar.gz
cd bing-4all-0.1.0-linux-x64
./bing_4all
# ou: ./install.sh   → ~/.local
```

## Dependências de build no host

```bash
# comum
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev

# pacotes
sudo apt install dpkg-dev rpm
```
