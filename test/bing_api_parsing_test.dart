import 'dart:convert';

import 'package:bing_4all/core/http/safe_http_client.dart';
import 'package:bing_4all/features/wallpapers/data/bing_fallback_api.dart';
import 'package:bing_4all/features/wallpapers/data/bing_primary_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('BingPrimaryApi mapeia campos principais', () async {
    final client = SafeHttpClient(
      client: MockClient((request) async {
        expect(request.url.host, 'services.bingapis.com');
        expect(request.url.queryParameters['mkt'], 'pt-BR');
        return http.Response(
          jsonEncode({
            'images': [
              {
                'startdate': '20260809',
                'enddate': '20260810',
                'urlbase':
                    'https://www.bing.com/th?id=OHR.Exemplo_PT-BR123_UHD.jpg',
                'copyrighttext': '© Fotógrafo',
                'copyrightlink': 'https://www.bing.com/search?q=1',
                'title': 'Local',
                'description': 'Descrição',
                'headline': 'Manchete',
                'fullDateString': '9 ago. 2026',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final api = BingPrimaryApi(client);
    final items = await api.fetch('pt-BR');
    expect(items, hasLength(1));
    expect(items.first.id, contains('20260809'));
    expect(items.first.headline, 'Manchete');
    expect(items.first.copyright, '© Fotógrafo');
    expect(items.first.imageUrl, contains('UHD.jpg'));
  });

  test('BingFallbackApi ignora wp=false e monta URL absoluta', () async {
    final client = SafeHttpClient(
      client: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'images': [
              {
                'startdate': '20260809',
                'url': '/th?id=OHR.Skip_1920x1080.jpg',
                'urlbase': '/th?id=OHR.Skip',
                'copyright': 'Skip',
                'copyrightlink': 'https://www.bing.com/search?q=skip',
                'title': 'Skip',
                'wp': false,
              },
              {
                'startdate': '20260808',
                'url': '/th?id=OHR.Ok_1920x1080.jpg',
                'urlbase': '/th?id=OHR.Ok',
                'copyright': 'Ok (© Fotógrafo)',
                'copyrightlink': 'https://www.bing.com/search?q=ok',
                'title': 'Ok',
                'wp': true,
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final api = BingFallbackApi(client);
    final items = await api.fetch('en-US');
    expect(items, hasLength(1));
    expect(items.first.title, 'Ok');
    expect(items.first.imageUrl, startsWith('https://www.bing.com/'));
    expect(items.first.imageUrl, contains('UHD.jpg'));
  });
}
