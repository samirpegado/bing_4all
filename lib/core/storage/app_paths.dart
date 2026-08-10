import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppPaths {
  AppPaths(this.root);

  final Directory root;

  Directory get cacheDir => Directory(p.join(root.path, 'cache'));
  Directory get originalsDir => Directory(p.join(cacheDir.path, 'originals'));
  Directory get thumbnailsDir => Directory(p.join(cacheDir.path, 'thumbnails'));
  Directory get logsDir => Directory(p.join(root.path, 'logs'));
  File get configFile => File(p.join(root.path, 'config.json'));
  File get stateFile => File(p.join(root.path, 'state.json'));
  File get metadataFile => File(p.join(cacheDir.path, 'metadata.json'));

  static Future<AppPaths> resolve() async {
    final support = await getApplicationSupportDirectory();
    final root = Directory(p.join(support.path, 'bing_4all'));
    final paths = AppPaths(root);
    await paths.ensureCreated();
    return paths;
  }

  Future<void> ensureCreated() async {
    await root.create(recursive: true);
    await cacheDir.create(recursive: true);
    await originalsDir.create(recursive: true);
    await thumbnailsDir.create(recursive: true);
    await logsDir.create(recursive: true);
  }
}
