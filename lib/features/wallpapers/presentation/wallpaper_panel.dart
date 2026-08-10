import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../settings/presentation/settings_page.dart';
import '../data/wallpaper_cache.dart';
import '../domain/wallpaper.dart';

class WallpaperPanel extends ConsumerStatefulWidget {
  const WallpaperPanel({super.key});

  @override
  ConsumerState<WallpaperPanel> createState() => _WallpaperPanelState();
}

class _WallpaperPanelState extends ConsumerState<WallpaperPanel> {
  String? _actionMessage;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final wallpapers = ref.watch(wallpapersProvider);
    final selectedIndex = ref.watch(selectedIndexProvider);
    final controller = ref.read(wallpapersProvider.notifier);
    final runtime = ref.watch(runtimeStateProvider);
    final desktop = ref.watch(desktopEnvironmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/bing-seeklogo.svg',
              height: 28,
              width: 28,
            ),
            const SizedBox(width: 10),
            const Text('Bing 4All'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    await controller.refresh();
                    if (mounted) setState(() => _busy = false);
                  },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Configurações',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: wallpapers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorPane(
          message: error is AppException ? error.message : 'Falha inesperada',
          onRetry: controller.refresh,
        ),
        data: (items) {
          if (items.isEmpty) {
            return _ErrorPane(
              message: 'Nenhuma imagem disponível',
              onRetry: controller.refresh,
            );
          }
          final selected =
              items[selectedIndex.clamp(0, items.length - 1)];
          final currentId = runtime.valueOrNull?.currentWallpaperId;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _Preview(
                      wallpaper: selected,
                      cache: ref.watch(wallpaperCacheProvider),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          onPressed: controller.selectPrevious,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _busy
                                ? null
                                : () => _runAction(
                                      () => controller.applySelected(),
                                      success: 'Wallpaper aplicado',
                                    ),
                            icon: const Icon(Icons.wallpaper),
                            label: const Text('Aplicar'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _runAction(
                                    () => controller.downloadSelected(),
                                    success: 'Imagem salva no cache',
                                  ),
                          icon: const Icon(Icons.download),
                          label: const Text('Baixar'),
                        ),
                        IconButton(
                          onPressed: controller.selectNext,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    if (_actionMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _actionMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      selected.displayTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (selected.fullDateString.isNotEmpty)
                          selected.fullDateString
                        else
                          selected.date,
                        if (selected.title.isNotEmpty) selected.title,
                      ].join(' · '),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: selected.copyrightUrl.isEmpty
                          ? null
                          : () => launchUrl(Uri.parse(selected.copyrightUrl)),
                      child: Text(
                        selected.copyright.isEmpty
                            ? 'Créditos indisponíveis'
                            : selected.copyright,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: selected.copyrightUrl.isEmpty
                                  ? null
                                  : TextDecoration.underline,
                            ),
                      ),
                    ),
                    if (selected.description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(selected.description),
                    ],
                    const SizedBox(height: 12),
                    desktop.when(
                      data: (env) => Text(
                        'Ambiente: $env',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Galeria',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 96,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final selectedNow = index == selectedIndex;
                          final isCurrent = item.id == currentId;
                          return _GalleryThumb(
                            wallpaper: item,
                            selected: selectedNow,
                            isCurrent: isCurrent,
                            cachePath: ref
                                .watch(wallpaperCacheProvider)
                                .get(item.id)
                                ?.filePath,
                            onTap: () => controller.selectIndex(index),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _runAction(
    Future<void> Function() action, {
    required String success,
  }) async {
    setState(() {
      _busy = true;
      _actionMessage = null;
    });
    try {
      await action();
      if (mounted) {
        setState(() => _actionMessage = success);
        ref.invalidate(runtimeStateProvider);
      }
    } on AppException catch (e) {
      if (mounted) setState(() => _actionMessage = e.message);
    } catch (_) {
      if (mounted) setState(() => _actionMessage = 'Falha inesperada');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.wallpaper, required this.cache});

  final Wallpaper wallpaper;
  final WallpaperCache cache;

  @override
  Widget build(BuildContext context) {
    final path = cache.get(wallpaper.id)?.filePath;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: path != null && File(path).existsSync()
            ? Image.file(File(path), fit: BoxFit.cover)
            : Image.network(
                wallpaper.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
      ),
    );
  }
}

class _GalleryThumb extends StatelessWidget {
  const _GalleryThumb({
    required this.wallpaper,
    required this.selected,
    required this.isCurrent,
    required this.onTap,
    this.cachePath,
  });

  final Wallpaper wallpaper;
  final bool selected;
  final bool isCurrent;
  final VoidCallback onTap;
  final String? cachePath;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (cachePath != null && File(cachePath!).existsSync())
              Image.file(File(cachePath!), fit: BoxFit.cover)
            else
              Image.network(
                wallpaper.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: Colors.black12,
                ),
              ),
            Positioned(
              left: 4,
              right: 4,
              bottom: 4,
              child: Text(
                wallpaper.date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                ),
              ),
            ),
            if (isCurrent)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.check_circle, color: Colors.lightGreenAccent, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorPane extends StatelessWidget {
  const _ErrorPane({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
