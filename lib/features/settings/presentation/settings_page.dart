import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../wallpapers/domain/market.dart';
import '../domain/app_settings.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Iniciar com o sistema'),
            value: settings.launchAtStartup,
            onChanged: (value) async {
              await controller.update((s) => s.copyWith(launchAtStartup: value));
              await ref.read(wallpaperServiceProvider).syncStartup(
                    ref.read(settingsProvider),
                  );
            },
          ),
          SwitchListTile(
            title: const Text('Atualizar automaticamente'),
            value: settings.autoUpdate,
            onChanged: (value) =>
                controller.update((s) => s.copyWith(autoUpdate: value)),
          ),
          ListTile(
            title: const Text('Horário de atualização'),
            subtitle: Text(
              '${settings.updateHour.toString().padLeft(2, '0')}:'
              '${settings.updateMinute.toString().padLeft(2, '0')}',
            ),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: settings.updateHour,
                  minute: settings.updateMinute,
                ),
              );
              if (time == null) return;
              await controller.update(
                (s) => s.copyWith(
                  updateHour: time.hour,
                  updateMinute: time.minute,
                ),
              );
            },
          ),
          DropdownButtonFormField<String>(
            initialValue: settings.market.isEmpty
                ? resolveMarket('')
                : resolveMarket(settings.market),
            decoration: const InputDecoration(labelText: 'Região / idioma'),
            items: supportedMarkets
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              controller.update((s) => s.copyWith(market: value));
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Aplicar em todos os monitores'),
            value: settings.applyToAllMonitors,
            onChanged: (value) =>
                controller.update((s) => s.copyWith(applyToAllMonitors: value)),
          ),
          DropdownButtonFormField<ImageQuality>(
            initialValue: settings.preferredQuality,
            decoration: const InputDecoration(labelText: 'Qualidade preferida'),
            items: const [
              DropdownMenuItem(
                value: ImageQuality.uhd,
                child: Text('UHD'),
              ),
              DropdownMenuItem(
                value: ImageQuality.hd1080,
                child: Text('1920×1080'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              controller.update((s) => s.copyWith(preferredQuality: value));
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('download-${settings.downloadDirectory}'),
            initialValue: settings.downloadDirectory,
            decoration: const InputDecoration(
              labelText: 'Diretório para imagens salvas',
              hintText: '/home/usuario/Imagens/bing_4all',
            ),
            onChanged: (value) =>
                controller.update((s) => s.copyWith(downloadDirectory: value)),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('cache-${settings.cacheLimitMb}'),
            initialValue: '${settings.cacheLimitMb}',
            decoration: const InputDecoration(labelText: 'Limite do cache (MB)'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final parsed = int.tryParse(value);
              if (parsed == null || parsed <= 0) return;
              controller.update((s) => s.copyWith(cacheLimitMb: parsed));
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ThemePreference>(
            initialValue: settings.theme,
            decoration: const InputDecoration(labelText: 'Tema'),
            items: const [
              DropdownMenuItem(
                value: ThemePreference.system,
                child: Text('Automático'),
              ),
              DropdownMenuItem(
                value: ThemePreference.light,
                child: Text('Claro'),
              ),
              DropdownMenuItem(
                value: ThemePreference.dark,
                child: Text('Escuro'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              controller.update((s) => s.copyWith(theme: value));
            },
          ),
          SwitchListTile(
            title: const Text('Notificações'),
            value: settings.notifications,
            onChanged: (value) =>
                controller.update((s) => s.copyWith(notifications: value)),
          ),
          SwitchListTile(
            title: const Text('Restaurar wallpaper anterior ao sair'),
            value: settings.restorePreviousOnExit,
            onChanged: (value) => controller
                .update((s) => s.copyWith(restorePreviousOnExit: value)),
          ),
          const SizedBox(height: 24),
          Text(
            'Aplicativo não oficial, sem associação com a Microsoft. '
            'macOS fica para a v2; este build foca em Linux (GNOME/KDE).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
