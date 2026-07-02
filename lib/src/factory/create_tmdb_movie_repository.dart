import 'package:dio/dio.dart';

import '../config/tmdb_config.dart';
import '../network/dio/dio_http_service.dart';
import '../network/dio/logging_interceptor.dart';
import '../repositories/movie_repository.dart';
import '../repositories/remote_movie_repository_impl.dart';
import '../services/image_url_resolver.dart';

/// Crea la implementación por defecto de [MovieRepository], respaldada por
/// la API de TMDB y el cliente HTTP `dio`.
///
/// Este es el único punto del paquete donde se ensamblan las piezas
/// concretas (composition root): la interfaz [MovieRepository] permanece
/// libre de dependencias de infraestructura.
///
/// Recibe un objeto [TmdbConfig] con los parámetros de autenticación,
/// conexión, idioma y resolución de imágenes. Es obligatorio proveer
/// `apiKey` (v3) o `accessToken` (v4, recomendado).
///
/// ### Ejemplo de uso:
/// ```dart
/// final repository = createTmdbMovieRepository(
///   const TmdbConfig(accessToken: 'TU_ACCESS_TOKEN_V4'),
/// );
/// ```
MovieRepository createTmdbMovieRepository(TmdbConfig config) {
  final bool useBearer = config.accessToken != null;
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      queryParameters: <String, dynamic>{
        if (!useBearer) 'api_key': config.apiKey,
        'language': config.language,
      },
      headers: <String, dynamic>{
        if (useBearer) 'Authorization': 'Bearer ${config.accessToken}',
      },
    ),
  );

  if (config.enableLogging) {
    dio.interceptors.add(LoggingInterceptor(config.logger));
  }

  return RemoteMovieRepositoryImpl(
    DioHttpService(dio),
    ImageUrlResolver(
      imageBaseUrl: config.imageBaseUrl,
      actorImageBaseUrl: config.actorImageBaseUrl,
    ),
  );
}
