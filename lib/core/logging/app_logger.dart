import 'dart:io';

import 'package:path/path.dart' as p;

/// Local file logger without personal data.
class AppLogger {
  AppLogger(this._logDir);

  final Directory _logDir;
  IOSink? _sink;

  Future<void> init() async {
    await _logDir.create(recursive: true);
    final file = File(p.join(_logDir.path, 'app.log'));
    _sink = file.openWrite(mode: FileMode.append);
  }

  void info(String message) => _write('INFO', message);

  void warn(String message, [Object? error]) =>
      _write('WARN', error == null ? message : '$message | $error');

  void error(String message, [Object? error]) =>
      _write('ERROR', error == null ? message : '$message | $error');

  void _write(String level, String message) {
    final line = '${DateTime.now().toIso8601String()} [$level] $message';
    // ignore: avoid_print
    print(line);
    _sink?.writeln(line);
  }

  Future<void> dispose() async {
    await _sink?.flush();
    await _sink?.close();
    _sink = null;
  }
}
