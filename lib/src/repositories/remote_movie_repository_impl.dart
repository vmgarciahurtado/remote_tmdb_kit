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
  Future<Result<List<Movie>>> getNowPlaying({int page = 1}) =>
      executeRepositoryCall(() async {
        final Map<String, dynamic> response = await _httpService
            .request<Map<String, dynamic>>(
              'movie/now_playing',
              method: HttpMethod.get,
              queryParameters: <String, dynamic>{'page': page},
            );
        final RemoteMovieResponse data = RemoteMovieResponse.fromJson(response);
        return data.results
            .map(
              (RemoteMovieModel m) =>
                  RemoteMovieMapper.toEntity(m, _imageUrlResolver),
            )
            .toList();
      });

  @override
  Future<Result<List<Movie>>> getPopular({int page = 1}) =>
      executeRepositoryCall(() async {
        final Map<String, dynamic> response = await _httpService
            .request<Map<String, dynamic>>(
              'movie/popular',
              method: HttpMethod.get,
              queryParameters: <String, dynamic>{'page': page},
            );
        final RemoteMovieResponse data = RemoteMovieResponse.fromJson(response);
        return data.results
            .map(
              (RemoteMovieModel m) =>
                  RemoteMovieMapper.toEntity(m, _imageUrlResolver),
            )
            .toList();
      });

  @override
  Future<Result<List<Movie>>> searchMovies(
    String query, {
    int page = 1,
    MovieSearchFilter? filter,
  }) => executeRepositoryCall(() async {
    final Map<String, dynamic> queryParams = <String, dynamic>{
      'query': query,
      'page': page,
      ...?filter?.toQueryParameters(),
    };
    final Map<String, dynamic> response = await _httpService
        .request<Map<String, dynamic>>(
          'search/movie',
          method: HttpMethod.get,
          queryParameters: queryParams,
        );
    final RemoteMovieResponse data = RemoteMovieResponse.fromJson(response);
    return data.results
        .map(
          (RemoteMovieModel m) =>
              RemoteMovieMapper.toEntity(m, _imageUrlResolver),
        )
        .toList();
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
        return data.cast
            .map(
              (RemoteActorModel a) =>
                  RemoteActorMapper.toEntity(a, _imageUrlResolver),
            )
            .toList();
      });
}
