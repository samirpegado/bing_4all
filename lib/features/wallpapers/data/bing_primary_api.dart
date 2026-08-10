import '../../../core/errors/app_exception.dart';
import '../../../core/http/safe_http_client.dart';
import '../domain/wallpaper.dart';
import '../domain/wallpaper_id.dart';

class BingPrimaryApi {
  BingPrimaryApi(this._http);

  final SafeHttpClient _http;

  static const baseUrl =
      'https://services.bingapis.com/ge-apps/api/v2/bwc/hpimages';

  Future<List<Wallpaper>> fetch(String market) async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: {'mkt': market});
    final json = await _http.getJson(uri);
    final images = json['images'];
    if (images is! List || images.isEmpty) {
      throw const BingUnavailableException(message: 'Resposta sem imagens');
    }

    return images
        .whereType<Map>()
        .map((raw) => _map(Map<String, dynamic>.from(raw), market))
        .toList(growable: false);
  }

  Wallpaper _map(Map<String, dynamic> item, String market) {
    final startdate = item['startdate']?.toString() ?? '';
    final urlbase = item['urlbase']?.toString() ?? '';
    if (startdate.isEmpty || urlbase.isEmpty) {
      throw const BingUnavailableException(message: 'Item de imagem incompleto');
    }

    final imageUrl = urlbase.startsWith('http')
        ? urlbase
        : 'https://www.bing.com${urlbase.startsWith('/') ? '' : '/'}$urlbase';

    return Wallpaper(
      id: buildWallpaperId(startdate, urlbase),
      date: startdate,
      availableUntil: item['enddate']?.toString(),
      imageUrl: imageUrl,
      title: item['title']?.toString() ?? '',
      headline: item['headline']?.toString() ?? '',
      description: item['description']?.toString() ?? '',
      copyright: item['copyrighttext']?.toString() ??
          item['copyright']?.toString() ??
          '',
      copyrightUrl: item['copyrightlink']?.toString() ?? '',
      market: market,
      fullDateString: item['fullDateString']?.toString() ?? '',
      availableForWallpaper: true,
    );
  }
}
