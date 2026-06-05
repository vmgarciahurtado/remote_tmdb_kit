import 'package:dio/dio.dart';
import '../errors/failures.dart';
import '../models/actor.dart';
import '../models/movie.dart';
import '../models/movie_search_filter.dart';
import '../network/dio/dio_http_service.dart';
import '../network/dio/logging_interceptor.dart';
import '../result/result.dart';
import '../services/image_url_resolver.dart';
import 'remote_movie_repository_impl.dart';

/// Repositorio de acceso a datos para consultar información de películas y actores desde la API de TMDB.
///
/// Permite recuperar películas en cartelera, populares, realizar búsquedas con filtros
/// y obtener los créditos del reparto de una película.
abstract interface class MovieRepository {
  /// Obtiene la lista de películas actualmente en cartelera en los cines.
  ///
  /// El parámetro opcional [page] (por defecto `1`) define la página de resultados a solicitar de la API.
  /// Retorna un [Result] que contiene una lista de objetos [Movie] en caso de éxito,
  /// o un [Failure] si ocurre algún inconveniente de red, autorización o servidor.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final Result<List<Movie>> result = await repository.getNowPlaying(page: 1);
  /// if (result is Success<List<Movie>>) {
  ///   final movies = result.data;
  ///   // Trabajar con el listado de películas...
  /// } else if (result is FailureResult<List<Movie>>) {
  ///   print('Error: ${result.failure.userMessage}');
  /// }
  /// ```
  Future<Result<List<Movie>>> getNowPlaying({int page = 1});

  /// Obtiene la lista de películas populares según las estadísticas de TMDB.
  ///
  /// El parámetro opcional [page] (por defecto `1`) define la página de resultados.
  /// Retorna un [Result] con el listado de películas populares o un error detallado.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final Result<List<Movie>> result = await repository.getPopular(page: 1);
  /// ```
  Future<Result<List<Movie>>> getPopular({int page = 1});

  /// Realiza una búsqueda de películas que coincidan con la consulta de texto libre [query].
  ///
  /// Permite paginar los resultados con [page] (por defecto `1`) y aplicar criterios de filtrado
  /// avanzados a través del objeto opcional [filter] (por ejemplo, año de lanzamiento o idioma).
  /// Retorna un [Result] con las películas que coincidan con la búsqueda.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final filter = MovieSearchFilter(
  ///   primaryReleaseYear: 2024,
  ///   includeAdult: false,
  /// );
  /// final Result<List<Movie>> result = await repository.searchMovies(
  ///   'Batman',
  ///   page: 1,
  ///   filter: filter,
  /// );
  /// ```
  Future<Result<List<Movie>>> searchMovies(
    String query, {
    int page = 1,
    MovieSearchFilter? filter,
  });

  /// Obtiene el reparto principal (actores) de una película identificada por su [movieId].
  ///
  /// Retorna un [Result] que envuelve la lista de actores [Actor] que participaron en la producción.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final Result<List<Actor>> result = await repository.getMovieCast(550); // Fight Club
  /// ```
  Future<Result<List<Actor>>> getMovieCast(int movieId);

  /// Constructor de factoría para instanciar la implementación predeterminada de [MovieRepository].
  ///
  /// - [apiKey]: Tu clave de acceso a la API de TMDB (requerida).
  /// - [enableLogging]: Si es `true` (por defecto es `false`), registra en consola las llamadas HTTP.
  /// - [baseUrl]: La URL base de la API de TMDB (por defecto versión 3).
  /// - [imageBaseUrl]: URL base para resolver imágenes de películas.
  /// - [actorImageBaseUrl]: URL base para resolver fotos de actores.
  /// - [noImageUrl]: Imagen de fallback en caso de que un póster no esté disponible.
  /// - [language]: Idioma de los datos devueltos por la API (por defecto `es-ES`).
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final repository = MovieRepository.create(
  ///   apiKey: 'TU_API_KEY_DE_TMDB',
  ///   enableLogging: false,
  /// );
  /// ```
  factory MovieRepository.create({
    required String apiKey,
    bool enableLogging = false, // Por defecto false
    String baseUrl = 'https://api.themoviedb.org/3/',
    String imageBaseUrl = 'https://image.tmdb.org/t/p/w500',
    String actorImageBaseUrl = 'https://image.tmdb.org/t/p/w185',
    String noImageUrl = 'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg',
    String language = 'es-ES',
  }) {
    final dio = Dio();
    dio.options.baseUrl = baseUrl;
    dio.options.queryParameters = <String, dynamic>{
      'api_key': apiKey,
      'language': language,
    };
    dio.options.headers['Content-Type'] = 'application/json; charset=utf-8';
    dio.options.contentType = 'application/json';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 5);
    
    if (enableLogging) {
      dio.interceptors.add(LoggingInterceptor());
    }

    final httpService = DioHttpService(dio);
    final imageUrlResolver = ImageUrlResolver(
      imageBaseUrl: imageBaseUrl,
      actorImageBaseUrl: actorImageBaseUrl,
      noImageUrl: noImageUrl,
    );

    return RemoteMovieRepositoryImpl(httpService, imageUrlResolver);
  }
}
