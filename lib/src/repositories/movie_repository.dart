import '../models/actor.dart';
import '../models/movie.dart';
import '../models/movie_search_filter.dart';
import '../models/paged_result.dart';
import '../result/result.dart';

/// Repositorio de acceso a datos para consultar información de películas
/// y actores desde la API de TMDB.
///
/// Permite recuperar películas en cartelera, populares, realizar búsquedas
/// con filtros y obtener los créditos del reparto de una película.
///
/// Este contrato no depende de ningún cliente HTTP ni implementación
/// concreta: para obtener la implementación por defecto respaldada por
/// TMDB usa la factoría `createTmdbMovieRepository`, o implementa esta
/// interfaz con tu propia fuente de datos.
abstract interface class MovieRepository {
  /// Obtiene la lista de películas actualmente en cartelera en los cines.
  ///
  /// El parámetro opcional [page] (por defecto `1`) define la página de
  /// resultados a solicitar de la API. Retorna un [Result] que contiene un
  /// [PagedResult] de objetos [Movie] en caso de éxito, o un [Failure] si
  /// ocurre algún inconveniente de red, autorización o servidor.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final result = await repository.getNowPlaying(page: 1);
  /// switch (result) {
  ///   case Success(data: final paged):
  ///     print('${paged.results.length} de ${paged.totalResults}');
  ///   case FailureResult(failure: final failure):
  ///     print('Error: ${failure.userMessage}');
  /// }
  /// ```
  Future<Result<PagedResult<Movie>>> getNowPlaying({int page = 1});

  /// Obtiene la lista de películas populares según las estadísticas de TMDB.
  ///
  /// El parámetro opcional [page] (por defecto `1`) define la página de
  /// resultados. Retorna un [Result] con la página de películas populares
  /// o un error detallado.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final result = await repository.getPopular(page: 1);
  /// ```
  Future<Result<PagedResult<Movie>>> getPopular({int page = 1});

  /// Realiza una búsqueda de películas que coincidan con la consulta de
  /// texto libre [query].
  ///
  /// Permite paginar los resultados con [page] (por defecto `1`) y aplicar
  /// criterios de filtrado avanzados a través del objeto opcional [filter]
  /// (por ejemplo, año de lanzamiento o idioma). Retorna un [Result] con la
  /// página de películas que coincidan con la búsqueda.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final filter = MovieSearchFilter(
  ///   primaryReleaseYear: 2024,
  ///   includeAdult: false,
  /// );
  /// final result = await repository.searchMovies(
  ///   'Batman',
  ///   page: 1,
  ///   filter: filter,
  /// );
  /// ```
  Future<Result<PagedResult<Movie>>> searchMovies(
    String query, {
    int page = 1,
    MovieSearchFilter? filter,
  });

  /// Obtiene el reparto principal (actores) de una película identificada
  /// por su [movieId].
  ///
  /// Retorna un [Result] que envuelve la lista de actores [Actor] que
  /// participaron en la producción.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final Result<List<Actor>> result =
  ///     await repository.getMovieCast(550); // Fight Club
  /// ```
  Future<Result<List<Actor>>> getMovieCast(int movieId);
}
