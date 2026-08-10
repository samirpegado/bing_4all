import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../errors/app_exception.dart';

/// HTTPS-only HTTP client with host allowlist and size/time limits.
class SafeHttpClient {
  SafeHttpClient({
    http.Client? client,
    this.connectTimeout = const Duration(seconds: 15),
    this.maxJsonBytes = 2 * 1024 * 1024,
    this.maxImageBytes = 40 * 1024 * 1024,
    Set<String>? allowedHosts,
  })  : _client = client ?? http.Client(),
        allowedHosts = allowedHosts ??
            {
              'services.bingapis.com',
              'www.bing.com',
              'bing.com',
              'th.bing.com',
              'tse1.mm.bing.net',
              'tse2.mm.bing.net',
              'tse3.mm.bing.net',
              'tse4.mm.bing.net',
            };

  final http.Client _client;
  final Duration connectTimeout;
  final int maxJsonBytes;
  final int maxImageBytes;
  final Set<String> allowedHosts;

  void allowHost(String host) {
    allowedHosts.add(host.toLowerCase());
  }

  Future<Map<String, dynamic>> getJson(Uri uri) async {
    _ensureHttps(uri);
    _ensureAllowedHost(uri);

    late final http.Response response;
    try {
      response = await _client.get(uri).timeout(connectTimeout);
    } on TimeoutException catch (e) {
      throw NetworkException(cause: e);
    } on http.ClientException catch (e) {
      throw NetworkException(cause: e);
    }

    if (response.statusCode == 429 || response.statusCode >= 500) {
      throw BingUnavailableException(cause: response.statusCode);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BingUnavailableException(message: 'Serviço do Bing indisponível (${response.statusCode})',
        cause: response.statusCode,
      );
    }
    if (response.bodyBytes.length > maxJsonBytes) {
      throw BingUnavailableException(message: 'Resposta JSON excede o limite');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw BingUnavailableException(message: 'JSON inesperado');
    }
    return decoded;
  }

  Future<Uint8List> getImageBytes(Uri uri) async {
    _ensureHttps(uri);
    _ensureAllowedHost(uri);

    late final http.Response response;
    try {
      response = await _client.get(uri).timeout(connectTimeout);
    } on TimeoutException catch (e) {
      throw NetworkException(cause: e);
    } on http.ClientException catch (e) {
      throw NetworkException(cause: e);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw InvalidImageException(message: 'Falha ao baixar imagem (${response.statusCode})',
      );
    }

    final contentType = response.headers['content-type']?.toLowerCase() ?? '';
    final isImage = contentType.contains('image/jpeg') ||
        contentType.contains('image/jpg') ||
        contentType.contains('image/png') ||
        contentType.contains('image/webp');
    if (!isImage) {
      throw const InvalidImageException();
    }
    if (response.bodyBytes.length > maxImageBytes) {
      throw const InvalidImageException(message: 'Imagem excede o tamanho máximo');
    }

    return response.bodyBytes;
  }

  void _ensureHttps(Uri uri) {
    if (uri.scheme != 'https') {
      throw const NetworkException(message: 'Somente HTTPS é permitido');
    }
  }

  void _ensureAllowedHost(Uri uri) {
    final host = uri.host.toLowerCase();
    if (!allowedHosts.contains(host)) {
      throw NetworkException(message: 'Host não permitido: $host');
    }
  }

  void close() => _client.close();
}
