import 'dart:convert';

import '../../../core/storage/app_paths.dart';

class AppRuntimeState {
  const AppRuntimeState({
    this.lastSuccessfulUpdate,
    this.currentWallpaperId,
    this.previousWallpaperId,
    this.previousWallpaperPath,
    this.lastError,
  });

  final DateTime? lastSuccessfulUpdate;
  final String? currentWallpaperId;
  final String? previousWallpaperId;
  final String? previousWallpaperPath;
  final String? lastError;

  AppRuntimeState copyWith({
    DateTime? lastSuccessfulUpdate,
    String? currentWallpaperId,
    String? previousWallpaperId,
    String? previousWallpaperPath,
    String? lastError,
    bool clearError = false,
  }) {
    return AppRuntimeState(
      lastSuccessfulUpdate: lastSuccessfulUpdate ?? this.lastSuccessfulUpdate,
      currentWallpaperId: currentWallpaperId ?? this.currentWallpaperId,
      previousWallpaperId: previousWallpaperId ?? this.previousWallpaperId,
      previousWallpaperPath:
          previousWallpaperPath ?? this.previousWallpaperPath,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }

  Map<String, dynamic> toJson() => {
        'lastSuccessfulUpdate': lastSuccessfulUpdate?.toIso8601String(),
        'currentWallpaperId': currentWallpaperId,
        'previousWallpaperId': previousWallpaperId,
        'previousWallpaperPath': previousWallpaperPath,
        'lastError': lastError,
      };

  factory AppRuntimeState.fromJson(Map<String, dynamic> json) {
    return AppRuntimeState(
      lastSuccessfulUpdate: json['lastSuccessfulUpdate'] != null
          ? DateTime.tryParse(json['lastSuccessfulUpdate'] as String)
          : null,
      currentWallpaperId: json['currentWallpaperId'] as String?,
      previousWallpaperId: json['previousWallpaperId'] as String?,
      previousWallpaperPath: json['previousWallpaperPath'] as String?,
      lastError: json['lastError'] as String?,
    );
  }
}

class AppStateStore {
  AppStateStore(this._paths);

  final AppPaths _paths;

  Future<AppRuntimeState> load() async {
    final file = _paths.stateFile;
    if (!await file.exists()) return const AppRuntimeState();
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) return const AppRuntimeState();
    return AppRuntimeState.fromJson(decoded);
  }

  Future<void> save(AppRuntimeState state) async {
    await _paths.stateFile.writeAsString(jsonEncode(state.toJson()));
  }
}
