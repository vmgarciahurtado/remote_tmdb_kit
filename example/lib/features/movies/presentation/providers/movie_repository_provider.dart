import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_content_explorer/core/constants/env.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

/// Provee la instancia de [MovieRepository] del paquete `remote_tmdb_kit`.
///
/// Toda la capa de datos (cliente HTTP, mapeo de DTOs, manejo de errores) vive
/// dentro del paquete; aquí solo se inyecta la API key y se consume.
final Provider<MovieRepository> movieRepositoryProvider =
    Provider<MovieRepository>((Ref ref) {
      return MovieRepository.create(apiKey: Env.apiKey);
    });
