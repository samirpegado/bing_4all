# Bing 4All

Cliente desktop **Linux** (não oficial) para wallpapers diários do Bing.

Consulta as imagens do dia, mostra créditos e permite aplicar como papel de parede — sem anúncios, sem telemetria e sem conta.

> Não afiliado à Microsoft. Imagens e marcas do Bing pertencem aos respectivos proprietários.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Linux-FCC624?logo=linux&logoColor=black)
![License](https://img.shields.io/badge/license-GPL--3.0--or--later-blue)

## Recursos (v0.1)

- Endpoint principal do Bing + fallback automático
- Galeria das imagens recentes com pré-visualização
- Aplicar / baixar (cache local)
- GNOME e KDE (fallbacks XFCE / nitrogen)
- Atualização automática diária e autostart (XDG)
- Configurações de mercado, tema, cache e monitores

macOS (menu bar) fica para a **v2**.

## Instalação

Baixe os pacotes na [página de Releases](https://github.com/samirpegado/bing_4all/releases).

### Debian / Ubuntu / Mint

```bash
sudo apt install ./bing-4all_*_amd64.deb
```

### Fedora

```bash
sudo dnf install ./bing-4all-*-x86_64.rpm
```

### Tarball (qualquer distro)

```bash
tar -xzf bing-4all-*-linux-x64.tar.gz
cd bing-4all-*-linux-x64
./bing_4all
# ou: ./install.sh   # instala em ~/.local
```

Depois: abra **Bing 4All** no menu ou rode `bing-4all`.

## Desenvolvimento

### Pré-requisitos

- [Flutter](https://docs.flutter.dev/get-started/install/linux) (channel stable)
- Linux com GTK 3

```bash
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev
```

### Rodar

```bash
flutter pub get
flutter run -d linux
```

### Testes e análise

```bash
flutter analyze
flutter test
```

### Empacotar localmente

```bash
./scripts/build_linux_packages.sh
```

Gera `.deb`, `.rpm` (se `rpmbuild` estiver instalado), `.tar.gz` e `SHA256SUMS` em `dist/`.  
Detalhes: [`linux/packaging/README.md`](linux/packaging/README.md).

### Publicar release

```bash
# atualize version em pubspec.yaml, commit, então:
git tag -a v0.1.0 -m "Bing 4All 0.1.0"
git push origin v0.1.0
```

O workflow [`.github/workflows/release-linux.yml`](.github/workflows/release-linux.yml) publica os artefatos na GitHub Release.

## Arquitetura

```text
lib/
├── app/           # MaterialApp, theme, Riverpod providers
├── core/          # HTTP seguro, storage, logging, erros
├── features/
│   ├── wallpapers/
│   ├── settings/
│   └── tray/
└── platform/      # adapters Linux (wallpaper, startup, monitors)
```

Spec completa: [`docs/SPEC.md`](docs/SPEC.md).

## Privacidade e segurança

- Apenas HTTPS e hosts permitidos
- Dados só no computador do usuário
- Sem telemetria por padrão

Ver [`PRIVACY.md`](PRIVACY.md) e [`SECURITY.md`](SECURITY.md).

## Contribuindo

Veja [`CONTRIBUTING.md`](CONTRIBUTING.md) e o [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).

## Licença

Código sob [GPL-3.0-or-later](LICENSE).

Wallpapers, fotografias e marcas Bing/Microsoft **não** são cobertos por esta licença.
