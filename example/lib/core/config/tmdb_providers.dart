import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provee la API key de TMDB a toda la aplicación.
///
/// Se declara sin valor y se configura en `main()` mediante
/// `ProviderScope(overrides: [...])`, dejando a `main` como único punto donde
/// se inyecta la clave (desde dotenv, --dart-define, etc.).
final Provider<String> tmdbApiKeyProvider = Provider<String>((Ref ref) {
  throw UnimplementedError(
    'tmdbApiKeyProvider debe configurarse en main() con la API key.',
  );
});
