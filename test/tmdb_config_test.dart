import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';
import 'package:test/test.dart';

void main() {
  group('TmdbConfig', () {
    test('given neither apiKey nor accessToken when constructed '
        'then throws an assertion error', () {
      expect(TmdbConfig.new, throwsA(isA<AssertionError>()));
    });

    test('accepts only an apiKey (v3)', () {
      const TmdbConfig config = TmdbConfig(apiKey: 'KEY');
      expect(config.apiKey, 'KEY');
      expect(config.accessToken, isNull);
    });

    test('accepts only an accessToken (v4)', () {
      const TmdbConfig config = TmdbConfig(accessToken: 'TOKEN');
      expect(config.accessToken, 'TOKEN');
      expect(config.apiKey, isNull);
    });

    test('exposes configurable timeouts with 5 second defaults', () {
      const TmdbConfig config = TmdbConfig(apiKey: 'KEY');
      expect(config.connectTimeout, const Duration(seconds: 5));
      expect(config.receiveTimeout, const Duration(seconds: 5));

      const TmdbConfig custom = TmdbConfig(
        apiKey: 'KEY',
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 30),
      );
      expect(custom.connectTimeout, const Duration(seconds: 10));
      expect(custom.receiveTimeout, const Duration(seconds: 30));
    });
  });

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
      expect(derived.connectTimeout, base.connectTimeout);
      expect(derived.receiveTimeout, base.receiveTimeout);
      expect(derived.logger, base.logger);
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
