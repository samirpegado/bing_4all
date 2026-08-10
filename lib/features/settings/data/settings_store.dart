import 'dart:convert';

import '../../../core/storage/app_paths.dart';
import '../domain/app_settings.dart';

class SettingsStore {
  SettingsStore(this._paths);

  final AppPaths _paths;

  Future<AppSettings> load() async {
    final file = _paths.configFile;
    if (!await file.exists()) return const AppSettings();
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) return const AppSettings();
    return AppSettings.fromJson(decoded);
  }

  Future<void> save(AppSettings settings) async {
    await _paths.configFile.writeAsString(jsonEncode(settings.toJson()));
  }
}
