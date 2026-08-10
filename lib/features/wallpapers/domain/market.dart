import 'dart:io';
import 'dart:ui';

const supportedMarkets = <String>{
  'pt-BR',
  'pt-PT',
  'en-US',
  'en-GB',
  'es-ES',
  'de-DE',
  'fr-FR',
  'ja-JP',
};

String resolveMarket(String configured) {
  if (configured.trim().isNotEmpty) {
    return _normalize(configured);
  }
  return detectSystemMarket();
}

String detectSystemMarket() {
  final langEnv = Platform.environment['LANG'] ??
      Platform.environment['LC_ALL'] ??
      Platform.environment['LC_MESSAGES'] ??
      '';
  final fromEnv = _fromLocaleTag(langEnv.split('.').first.replaceAll('_', '-'));
  if (fromEnv != null) return fromEnv;

  final locale = PlatformDispatcher.instance.locale;
  final fromPlatform = _fromLocaleTag('${locale.languageCode}-${locale.countryCode}');
  if (fromPlatform != null) return fromPlatform;

  return 'en-US';
}

String _normalize(String value) {
  final tag = value.trim().replaceAll('_', '-');
  final matched = _fromLocaleTag(tag);
  return matched ?? 'en-US';
}

String? _fromLocaleTag(String tag) {
  if (tag.isEmpty || tag == '-') return null;
  if (supportedMarkets.contains(tag)) return tag;

  final lower = tag.toLowerCase();
  for (final market in supportedMarkets) {
    if (market.toLowerCase() == lower) return market;
  }

  final language = tag.split('-').first.toLowerCase();
  switch (language) {
    case 'pt':
      return tag.toUpperCase().contains('PT') ? 'pt-PT' : 'pt-BR';
    case 'en':
      return tag.toUpperCase().contains('GB') ? 'en-GB' : 'en-US';
    case 'es':
      return 'es-ES';
    case 'de':
      return 'de-DE';
    case 'fr':
      return 'fr-FR';
    case 'ja':
      return 'ja-JP';
  }
  return null;
}
