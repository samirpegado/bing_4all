import 'package:bing_4all/features/wallpapers/domain/wallpaper_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildWallpaperId extrai token do urlbase', () {
    final id = buildWallpaperId(
      '20260809',
      'https://www.bing.com/th?id=OHR.Exemplo_PT-BR123_UHD.jpg',
    );
    expect(id, '20260809_OHR.Exemplo_PT-BR123');
  });

  test('buildWallpaperId funciona com caminho relativo', () {
    final id = buildWallpaperId('20260809', '/th?id=OHR.Exemplo');
    expect(id, '20260809_OHR.Exemplo');
  });
}
