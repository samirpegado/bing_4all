/// Builds a stable wallpaper id from startdate + urlbase token.
String buildWallpaperId(String startdate, String urlbase) {
  final match = RegExp(r'id=([^&]+)').firstMatch(urlbase);
  var token = match?.group(1) ?? urlbase;
  token = token
      .replaceAll(RegExp(r'_UHD\.jpg$', caseSensitive: false), '')
      .replaceAll(RegExp(r'_\d+x\d+\.jpg$', caseSensitive: false), '')
      .replaceAll(RegExp(r'\.jpg$', caseSensitive: false), '');
  final sanitized = token.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  return '${startdate}_$sanitized';
}
