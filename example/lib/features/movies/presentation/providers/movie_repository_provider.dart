import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_content_explorer/core/config/tmdb_providers.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

/// Provee la instancia de [MovieRepository] del paquete `remote_tmdb_kit`.
///
/// Toda la capa de datos (cliente HTTP, mapeo de DTOs, manejo de errores) vive
/// dentro del paquete; aquí solo se inyecta la configuración y se consume.
final Provider<MovieRepository> movieRepositoryProvider =
    Provider<MovieRepository>((Ref ref) {
      final TmdbConfig baseConfig = TmdbConfig(
        apiKey: ref.watch(tmdbApiKeyProvider),
      );

      // En depuración: logs HTTP e idioma en inglés; en release, la base.
      final TmdbConfig config = kDebugMode
          ? baseConfig.copyWith(enableLogging: true, language: 'en-US')
          : baseConfig;

      return createTmdbMovieRepository(config);
    });
