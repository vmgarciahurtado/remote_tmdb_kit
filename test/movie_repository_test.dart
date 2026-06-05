import 'package:flutter_test/flutter_test.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';
import 'package:remote_tmdb_kit/src/services/image_url_resolver.dart';

class FakeHttpService implements HttpService {
  late Object? response;
  bool shouldThrow = false;
  Exception? exception;

  String? lastPath;
  HttpMethod? lastMethod;
  Map<String, dynamic>? lastQueryParameters;

  @override
  Future<T> request<T>(
    String path, {
    required HttpMethod method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    lastPath = path;
    lastMethod = method;
    lastQueryParameters = queryParameters;

    if (shouldThrow) {
      if (exception != null) throw exception!;
      throw const UnexpectedFailure();
    }
    return response as T;
  }
}

void main() {
  late FakeHttpService fakeHttpService;
  late RemoteMovieRepositoryImpl repository;

  const String tImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  const String tNoImageUrl = 'https://img.com/fallback.jpg';
  const String tActorImageBaseUrl = 'https://image.tmdb.org/t/p/w185';

  setUp(() {
    fakeHttpService = FakeHttpService();
    repository = RemoteMovieRepositoryImpl(
      fakeHttpService,
      const ImageUrlResolver(
        imageBaseUrl: tImageBaseUrl,
        actorImageBaseUrl: tActorImageBaseUrl,
        noImageUrl: tNoImageUrl,
      ),
    );
  });

  group('RemoteMovieRepositoryImpl.getNowPlaying', () {
    test(
      'given a successful http request when getNowPlaying is called '
      'then returns success with movies',
      () async {
        fakeHttpService.response = _tMovieResponseJson();

        final Result<List<Movie>> result = await repository.getNowPlaying();

        expect(result, isA<Success<List<Movie>>>());
        final List<Movie> movies = (result as Success<List<Movie>>).data;
        expect(movies.length, 1);
        expect(movies.first.id, 1);
        expect(
          movies.first.posterPath,
          'https://image.tmdb.org/t/p/w500/poster.jpg',
        );
        expect(fakeHttpService.lastPath, 'movie/now_playing');
        expect(fakeHttpService.lastMethod, HttpMethod.get);
      },
    );

    test(
      'given http service throws ConnectionFailure when getNowPlaying is '
      'called then returns ConnectionFailure Result',
      () async {
        fakeHttpService.shouldThrow = true;
        fakeHttpService.exception = const ConnectionFailure();

        final Result<List<Movie>> result = await repository.getNowPlaying();

        expect(result, isA<FailureResult<List<Movie>>>());
        final Failure failure = (result as FailureResult<List<Movie>>).failure;
        expect(failure, isA<ConnectionFailure>());
      },
    );
  });

  group('RemoteMovieRepositoryImpl.getPopular', () {
    test(
      'given a successful http request when getPopular is called '
      'then returns success with movies',
      () async {
        fakeHttpService.response = _tMovieResponseJson();

        final Result<List<Movie>> result = await repository.getPopular();

        expect(result, isA<Success<List<Movie>>>());
        final List<Movie> movies = (result as Success<List<Movie>>).data;
        expect(movies.first.id, 1);
        expect(fakeHttpService.lastPath, 'movie/popular');
        expect(fakeHttpService.lastMethod, HttpMethod.get);
      },
    );
  });

  group('RemoteMovieRepositoryImpl.searchMovies', () {
    test(
      'given a successful http request when searchMovies is called '
      'then returns success with movies',
      () async {
        fakeHttpService.response = _tMovieResponseJson();

        final Result<List<Movie>> result = await repository.searchMovies('batman');

        expect(result, isA<Success<List<Movie>>>());
        final List<Movie> movies = (result as Success<List<Movie>>).data;
        expect(movies.first.title, 'Batman');
        expect(fakeHttpService.lastPath, 'search/movie');
        expect(fakeHttpService.lastMethod, HttpMethod.get);
        expect(fakeHttpService.lastQueryParameters, <String, dynamic>{
          'query': 'batman',
          'page': 1,
        });
      },
    );

    test(
      'given a filter when searchMovies is called '
      'then includes filter parameters in query parameters',
      () async {
        fakeHttpService.response = _tMovieResponseJson();

        final Result<List<Movie>> result = await repository.searchMovies(
          'batman',
          page: 2,
          filter: const MovieSearchFilter(
            includeAdult: false,
            primaryReleaseYear: 2024,
          ),
        );

        expect(result, isA<Success<List<Movie>>>());
        expect(fakeHttpService.lastQueryParameters, <String, dynamic>{
          'query': 'batman',
          'page': 2,
          'include_adult': false,
          'primary_release_year': 2024,
        });
      },
    );
  });

  group('RemoteMovieRepositoryImpl.getMovieCast', () {
    test(
      'given a successful http request when getMovieCast is called '
      'then returns success with cast list',
      () async {
        fakeHttpService.response = _tCastResponseJson();

        final Result<List<Actor>> result = await repository.getMovieCast(1);

        expect(result, isA<Success<List<Actor>>>());
        final List<Actor> actors = (result as Success<List<Actor>>).data;
        expect(actors.length, 1);
        expect(actors.first.name, 'Christian Bale');
        expect(
          actors.first.profilePath,
          'https://image.tmdb.org/t/p/w185/bale.jpg',
        );
        expect(fakeHttpService.lastPath, 'movie/1/credits');
        expect(fakeHttpService.lastMethod, HttpMethod.get);
      },
    );
  });

  group('MovieRepository.create', () {
    test('creates a MovieRepository instance with default logging to false', () {
      final repo = MovieRepository.create(apiKey: 'test_key');
      expect(repo, isA<MovieRepository>());
    });

    test('creates a MovieRepository instance with logging enabled', () {
      final repo = MovieRepository.create(apiKey: 'test_key', enableLogging: true);
      expect(repo, isA<MovieRepository>());
    });
  });
}

Map<String, dynamic> _tMovieResponseJson() => <String, dynamic>{
      'page': 1,
      'total_pages': 10,
      'total_results': 200,
      'results': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 1,
          'title': 'Batman',
          'original_title': 'Batman',
          'overview': 'Gotham hero',
          'poster_path': '/poster.jpg',
          'backdrop_path': '/backdrop.jpg',
          'release_date': '2022-03-04',
          'popularity': 98.5,
          'vote_average': 7.3,
          'vote_count': 5432,
          'genre_ids': <int>[28, 12],
          'adult': false,
          'video': false,
          'original_language': 'en',
        },
      ],
    };

Map<String, dynamic> _tCastResponseJson() => <String, dynamic>{
      'id': 1,
      'cast': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 10,
          'name': 'Christian Bale',
          'character': 'Bruce Wayne',
          'profile_path': '/bale.jpg',
        },
      ],
    };
