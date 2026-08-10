import 'package:bing_4all/features/wallpapers/domain/market.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolveMarket usa configuração válida', () {
    expect(resolveMarket('pt-BR'), 'pt-BR');
    expect(resolveMarket('en_US'), 'en-US');
  });

  test('resolveMarket cai para en-US quando inválido', () {
    expect(resolveMarket('xx-YY'), 'en-US');
  });
}
