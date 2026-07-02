import '../dtos/remote_actor_model.dart';
import '../dtos/remote_cast_response.dart';
import '../dtos/remote_movie_model.dart';
import '../dtos/remote_movie_response.dart';
import '../helpers/repository_helper.dart';
import '../mappers/remote_actor_mapper.dart';
import '../mappers/remote_movie_mapper.dart';
import '../models/actor.dart';
import '../models/movie.dart';
import '../models/movie_search_filter.dart';
import '../models/paged_result.dart';
import '../network/http_method.dart';
import '../network/http_service.dart';
import '../result/result.dart';
import '../services/image_url_resolver.dart';
import 'movie_repository.dart';

/// Implementación concreta de [MovieRepository] que consulta la API
/// remota de TMDB.
class RemoteMovieRepositoryImpl implements MovieRepository {
  /// Crea una instancia del repositorio a partir de un cliente HTTP y un
  /// resolutor de URLs de imágenes.
  const RemoteMovieRepositoryImpl(this._httpService, this._imageUrlResolver);

  final HttpService _httpService;
  final ImageUrlResolver _imageUrlResolver;

  @override
  Future<Result<PagedResult<Movie>>> getNowPlaying({int page = 1}) =>
      _fetchMoviePage('movie/now_playing', <String, dynamic>{'page': page});

  @override
  Future<Result<PagedResult<Movie>>> getPopular({int page = 1}) =>
      _fetchMoviePage('movie/popular', <String, dynamic>{'page': page});

  @override
  Future<Result<PagedResult<Movie>>> searchMovies(
    String query, {
    int page = 1,
    MovieSearchFilter? filter,
  }) => _fetchMoviePage('search/movie', <String, dynamic>{
    'query': query,
    'page': page,
    ...?filter?.toQueryParameters(),
  });

  @override
  Future<Result<List<Actor>>> getMovieCast(int movieId) =>
      executeRepositoryCall(() async {
        final Map<String, dynamic> response = await _httpService
            .request<Map<String, dynamic>>(
              'movie/$movieId/credits',
              method: HttpMethod.get,
            );
        final RemoteCastResponse data = RemoteCastResponse.fromJson(response);
        return List<Actor>.unmodifiable(
          data.cast.map(
            (RemoteActorModel a) =>
                RemoteActorMapper.toEntity(a, _imageUrlResolver),
          ),
        );
      });

  /// Consulta un endpoint paginado de películas y mapea la respuesta a un
  /// [PagedResult] de entidades de dominio.
  Future<Result<PagedResult<Movie>>> _fetchMoviePage(
    String path,
    Map<String, dynamic> queryParameters,
  ) => executeRepositoryCall(() async {
    final Map<String, dynamic> response = await _httpService
        .request<Map<String, dynamic>>(
          path,
          method: HttpMethod.get,
          queryParameters: queryParameters,
        );
    final RemoteMovieResponse data = RemoteMovieResponse.fromJson(response);
    return PagedResult<Movie>(
      page: data.page,
      results: List<Movie>.unmodifiable(
        data.results.map(
          (RemoteMovieModel m) =>
              RemoteMovieMapper.toEntity(m, _imageUrlResolver),
        ),
      ),
      totalPages: data.totalPages,
      totalResults: data.totalResults,
    );
  });
}
