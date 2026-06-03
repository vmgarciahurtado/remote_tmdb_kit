import 'package:dio/dio.dart';
import 'dtos.dart';
import 'http_service.dart';
import 'image_url_resolver.dart';
import 'models.dart';
import 'result.dart';

abstract interface class MovieRepository {
  Future<Result<List<Movie>>> getNowPlaying({int page = 1});
  Future<Result<List<Movie>>> getPopular({int page = 1});
  Future<Result<List<Movie>>> searchMovies(String query);
  Future<Result<List<Actor>>> getMovieCast(int movieId);

  /// Factory constructor to create a default configured instance of [MovieRepository].
  factory MovieRepository.create({
    required String apiKey,
    String baseUrl = 'https://api.themoviedb.org/3/',
    String imageBaseUrl = 'https://image.tmdb.org/t/p/w500',
    String actorImageBaseUrl = 'https://image.tmdb.org/t/p/w185',
    String noImageUrl = 'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg',
    String language = 'es-ES',
  }) {
    final dio = Dio();
    dio.options.baseUrl = baseUrl;
    dio.options.queryParameters = {
      'api_key': apiKey,
      'language': language,
    };
    dio.options.headers['Content-Type'] = 'application/json; charset=utf-8';
    dio.options.contentType = 'application/json';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 5);
    
    dio.interceptors.add(LoggingInterceptor());

    final httpService = DioHttpService(dio);
    final imageUrlResolver = ImageUrlResolver(
      imageBaseUrl: imageBaseUrl,
      actorImageBaseUrl: actorImageBaseUrl,
      noImageUrl: noImageUrl,
    );

    return RemoteMovieRepositoryImpl(httpService, imageUrlResolver);
  }
}

class RemoteMovieRepositoryImpl implements MovieRepository {
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
  Future<Result<List<Movie>>> searchMovies(String query) =>
      executeRepositoryCall(() async {
        final Map<String, dynamic> response = await _httpService
            .request<Map<String, dynamic>>(
              'search/movie',
              method: HttpMethod.get,
              queryParameters: <String, dynamic>{'query': query},
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
