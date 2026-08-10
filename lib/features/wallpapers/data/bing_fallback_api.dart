import '../../../core/errors/app_exception.dart';
import '../../../core/http/safe_http_client.dart';
import '../domain/wallpaper.dart';
import '../domain/wallpaper_id.dart';

class BingFallbackApi {
  BingFallbackApi(this._http);

  final SafeHttpClient _http;

  static const baseUrl = 'https://www.bing.com/HPImageArchive.aspx';

  Future<List<Wallpaper>> fetch(String market) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'format': 'js',
        'idx': '0',
        'n': '8',
        'mkt': market,
      },
    );
    final json = await _http.getJson(uri);
    final images = json['images'];
    if (images is! List || images.isEmpty) {
      throw const BingUnavailableException(message: 'Fallback sem imagens');
    }

    return images
        .whereType<Map>()
        .map((raw) => _map(Map<String, dynamic>.from(raw), market))
        .where((w) => w.availableForWallpaper)
        .toList(growable: false);
  }

  Wallpaper _map(Map<String, dynamic> item, String market) {
    final startdate = item['startdate']?.toString() ?? '';
    final urlbaseRaw = item['urlbase']?.toString() ?? '';
    final urlRaw = item['url']?.toString() ?? '';
    if (startdate.isEmpty || (urlbaseRaw.isEmpty && urlRaw.isEmpty)) {
      throw const BingUnavailableException(message: 'Item fallback incompleto');
    }

    final absoluteBase = _absolute(urlbaseRaw.isNotEmpty ? urlbaseRaw : urlRaw);
    final candidates = <String>[
      if (urlbaseRaw.isNotEmpty) '${_absolute(urlbaseRaw)}_UHD.jpg',
      if (urlbaseRaw.isNotEmpty) '${_absolute(urlbaseRaw)}_1920x1080.jpg',
      if (urlRaw.isNotEmpty) _absolute(urlRaw),
      absoluteBase,
    ];

    final wp = item['wp'];
    final available = wp == null || wp == true || wp == 'true' || wp == 1;

    return Wallpaper(
      id: buildWallpaperId(startdate, urlbaseRaw.isNotEmpty ? urlbaseRaw : urlRaw),
      date: startdate,
      imageUrl: candidates.first,
      title: item['title']?.toString() ?? '',
      copyright: item['copyright']?.toString() ?? '',
      copyrightUrl: item['copyrightlink']?.toString() ?? '',
      market: market,
      availableForWallpaper: available,
      description: '',
      headline: item['title']?.toString() ?? '',
    );
  }

  String _absolute(String value) {
    if (value.startsWith('http')) return value;
    if (value.startsWith('/')) return 'https://www.bing.com$value';
    return 'https://www.bing.com/$value';
  }

  /// Candidate download URLs for a fallback wallpaper, quality-ordered.
  static List<String> downloadCandidates(Wallpaper wallpaper) {
    final base = wallpaper.imageUrl
        .replaceAll(RegExp(r'_UHD\.jpg$', caseSensitive: false), '')
        .replaceAll(RegExp(r'_\d+x\d+\.jpg$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\.jpg$', caseSensitive: false), '');
    return [
      '${base}_UHD.jpg',
      '${base}_1920x1080.jpg',
      wallpaper.imageUrl,
    ];
  }
}
