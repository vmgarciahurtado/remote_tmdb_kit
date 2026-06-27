import 'package:flutter_test/flutter_test.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';
import 'package:remote_tmdb_kit/src/dtos/remote_actor_model.dart';
import 'package:remote_tmdb_kit/src/dtos/remote_cast_response.dart';
import 'package:remote_tmdb_kit/src/dtos/remote_movie_model.dart';
import 'package:remote_tmdb_kit/src/dtos/remote_movie_response.dart';

void main() {
  group('RemoteMovieModel.fromJson', () {
    test(
      'given a valid JSON map when fromJson is called '
      'then all fields are parsed correctly',
      () {
        final Map<String, Object> json = <String, Object>{
          'id': 1,
          'title': 'Batman',
          'original_title': 'Batman',
          'overview': 'A hero in Gotham',
          'poster_path': '/batman.jpg',
          'backdrop_path': '/gotham.jpg',
          'release_date': '2022-03-04',
          'popularity': 98.5,
          'vote_average': 7.3,
          'vote_count': 5432,
          'genre_ids': <int>[28, 12],
          'adult': false,
          'video': false,
          'original_language': 'en',
        };

        final RemoteMovieModel model = RemoteMovieModel.fromJson(json);

        expect(model.id, 1);
        expect(model.title, 'Batman');
        expect(model.posterPath, '/batman.jpg');
        expect(model.genreIds, <int>[28, 12]);
      },
    );
  });

  group('RemoteMovieResponse.fromJson', () {
    test(
      'given a valid JSON map when fromJson is called '
      'then results and pagination fields are parsed correctly',
      () {
        final Map<String, Object> json = <String, Object>{
          'page': 1,
          'total_pages': 10,
          'total_results': 200,
          'results': <Map<String, Object>>[
            <String, Object>{
              'id': 1,
              'title': 'Batman',
              'original_title': 'Batman',
              'overview': '',
              'poster_path': '/batman.jpg',
              'backdrop_path': '/gotham.jpg',
              'release_date': '2022-03-04',
              'popularity': 98.5,
              'vote_average': 7.3,
              'vote_count': 5432,
              'genre_ids': <int>[],
              'adult': false,
              'video': false,
              'original_language': 'en',
            },
          ],
        };

        final RemoteMovieResponse response = RemoteMovieResponse.fromJson(json);

        expect(response.page, 1);
        expect(response.totalPages, 10);
        expect(response.results.length, 1);
        expect(response.results.first.id, 1);
      },
    );
  });

  group('RemoteActorModel.fromJson', () {
    test(
      'given a valid JSON map when fromJson is called '
      'then all fields including nullable profilePath are parsed correctly',
      () {
        final Map<String, Object> json = <String, Object>{
          'id': 10,
          'name': 'Christian Bale',
          'character': 'Bruce Wayne',
          'profile_path': '/bale.jpg',
        };

        final RemoteActorModel model = RemoteActorModel.fromJson(json);

        expect(model.id, 10);
        expect(model.name, 'Christian Bale');
        expect(model.profilePath, '/bale.jpg');
      },
    );
  });

  group('RemoteCastResponse.fromJson', () {
    test(
      'given a valid JSON map when fromJson is called '
      'then the id and cast list are parsed correctly',
      () {
        final Map<String, Object> json = <String, Object>{
          'id': 99,
          'cast': <Map<String, Object?>>[
            <String, Object?>{
              'id': 10,
              'name': 'Christian Bale',
              'character': 'Bruce Wayne',
              'profile_path': null,
            },
          ],
        };

        final RemoteCastResponse response = RemoteCastResponse.fromJson(json);

        expect(response.id, 99);
        expect(response.cast.length, 1);
        expect(response.cast.first.name, 'Christian Bale');
      },
    );
  });

  group('MovieSearchFilter', () {
    test('toQueryParameters returns only non-null values', () {
      const MovieSearchFilter filter = MovieSearchFilter(
        includeAdult: false,
        primaryReleaseYear: 2024,
      );
      final Map<String, dynamic> queryParams = filter.toQueryParameters();
      expect(queryParams, <String, dynamic>{
        'include_adult': false,
        'primary_release_year': 2024,
      });
      expect(queryParams.containsKey('language'), isFalse);
    });

    test('copyWith copies parameters correctly', () {
      const MovieSearchFilter filter = MovieSearchFilter(includeAdult: false);
      final MovieSearchFilter updated = filter.copyWith(
        primaryReleaseYear: 2024,
      );
      expect(updated.includeAdult, isFalse);
      expect(updated.primaryReleaseYear, 2024);
    });
  });

  group('MovieSearchFilterBuilder', () {
    test('build returns a filter with all the configured criteria', () {
      final MovieSearchFilter filter = MovieSearchFilterBuilder()
          .year(2024)
          .region('MX')
          .includeAdult(false)
          .build();

      expect(filter.year, 2024);
      expect(filter.region, 'MX');
      expect(filter.includeAdult, isFalse);
      expect(filter.language, isNull);
      expect(filter.primaryReleaseYear, isNull);
    });

    test('build with no criteria returns an empty filter', () {
      final MovieSearchFilter filter = MovieSearchFilterBuilder().build();

      expect(filter.toQueryParameters(), isEmpty);
    });

    test('each setter returns the same builder to allow chaining', () {
      final MovieSearchFilterBuilder builder = MovieSearchFilterBuilder();

      expect(builder.language('en-US'), same(builder));
    });
  });
}
