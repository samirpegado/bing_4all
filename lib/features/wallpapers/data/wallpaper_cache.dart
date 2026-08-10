import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../../../core/errors/app_exception.dart';
import '../../../core/storage/app_paths.dart';
import '../domain/wallpaper.dart';

class CachedWallpaper {
  const CachedWallpaper({
    required this.wallpaper,
    required this.filePath,
    required this.sha256,
    required this.sizeBytes,
  });

  final Wallpaper wallpaper;
  final String filePath;
  final String sha256;
  final int sizeBytes;

  Map<String, dynamic> toJson() => {
        'wallpaper': wallpaper.toJson(),
        'filePath': filePath,
        'sha256': sha256,
        'sizeBytes': sizeBytes,
      };

  factory CachedWallpaper.fromJson(Map<String, dynamic> json) {
    return CachedWallpaper(
      wallpaper: Wallpaper.fromJson(
        Map<String, dynamic>.from(json['wallpaper'] as Map),
      ),
      filePath: json['filePath'] as String,
      sha256: json['sha256'] as String,
      sizeBytes: json['sizeBytes'] as int? ?? 0,
    );
  }
}

class WallpaperCache {
  WallpaperCache(this._paths);

  final AppPaths _paths;
  final Map<String, CachedWallpaper> _entries = {};

  Future<void> load() async {
    final file = _paths.metadataFile;
    if (!await file.exists()) return;
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) return;
    final items = decoded['items'];
    if (items is! List) return;
    for (final item in items.whereType<Map>()) {
      final entry =
          CachedWallpaper.fromJson(Map<String, dynamic>.from(item));
      if (await File(entry.filePath).exists()) {
        _entries[entry.wallpaper.id] = entry;
      }
    }
  }

  List<Wallpaper> get wallpapers =>
      _entries.values.map((e) => e.wallpaper).toList(growable: false);

  CachedWallpaper? get(String id) => _entries[id];

  bool has(String id) => _entries.containsKey(id);

  Future<CachedWallpaper> store({
    required Wallpaper wallpaper,
    required Uint8List bytes,
  }) async {
    try {
      final hash = sha256.convert(bytes).toString();
      final ext = _extensionFor(bytes);
      final file = File(
        p.join(_paths.originalsDir.path, '${wallpaper.id}$ext'),
      );
      await file.writeAsBytes(bytes, flush: true);
      final entry = CachedWallpaper(
        wallpaper: wallpaper,
        filePath: file.path,
        sha256: hash,
        sizeBytes: bytes.length,
      );
      _entries[wallpaper.id] = entry;
      await _persist();
      return entry;
    } on FileSystemException catch (e) {
      throw StoragePermissionException(cause: e);
    }
  }

  Future<void> enforceLimit({
    required int limitMb,
    String? protectId,
  }) async {
    final limitBytes = limitMb * 1024 * 1024;
    var total = _entries.values.fold<int>(0, (sum, e) => sum + e.sizeBytes);
    if (total <= limitBytes) return;

    final ordered = _entries.values.toList()
      ..sort((a, b) => a.wallpaper.date.compareTo(b.wallpaper.date));

    for (final entry in ordered) {
      if (total <= limitBytes) break;
      if (entry.wallpaper.id == protectId) continue;
      await File(entry.filePath).delete().catchError((_) => File(''));
      _entries.remove(entry.wallpaper.id);
      total -= entry.sizeBytes;
    }
    await _persist();
  }

  Future<void> _persist() async {
    final payload = {
      'items': _entries.values.map((e) => e.toJson()).toList(),
    };
    await _paths.metadataFile.writeAsString(jsonEncode(payload));
  }

  String _extensionFor(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return '.jpg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return '.png';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46) {
      return '.webp';
    }
    return '.jpg';
  }
}
