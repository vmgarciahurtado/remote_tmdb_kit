import 'package:flutter_test/flutter_test.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

void main() {
  group('TmdbConfig.copyWith', () {
    test('overrides only the provided fields and keeps the rest', () {
      const TmdbConfig base = TmdbConfig(apiKey: 'KEY');

      final TmdbConfig derived = base.copyWith(
        enableLogging: true,
        language: 'en-US',
      );

      expect(derived.apiKey, 'KEY');
      expect(derived.enableLogging, isTrue);
      expect(derived.language, 'en-US');
      // El resto de los campos conserva los valores del original.
      expect(derived.baseUrl, base.baseUrl);
      expect(derived.imageBaseUrl, base.imageBaseUrl);
      expect(derived.actorImageBaseUrl, base.actorImageBaseUrl);
      expect(derived.noImageUrl, base.noImageUrl);
    });

    test('with no arguments returns an equivalent configuration', () {
      const TmdbConfig base = TmdbConfig(apiKey: 'KEY', language: 'fr-FR');

      final TmdbConfig copy = base.copyWith();

      expect(copy.apiKey, base.apiKey);
      expect(copy.language, base.language);
      expect(copy.baseUrl, base.baseUrl);
      expect(copy.enableLogging, base.enableLogging);
    });
  });
}
