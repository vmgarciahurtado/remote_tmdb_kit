import 'package:flutter_test/flutter_test.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';
import 'package:remote_tmdb_kit/src/dtos/remote_movie_model.dart';
import 'package:remote_tmdb_kit/src/dtos/remote_actor_model.dart';
import 'package:remote_tmdb_kit/src/mappers/remote_movie_mapper.dart';
import 'package:remote_tmdb_kit/src/mappers/remote_actor_mapper.dart';
import 'package:remote_tmdb_kit/src/services/image_url_resolver.dart';

void main() {
  group('RemoteMovieMapper.toEntity', () {
    const String tImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
    const String tNoImageUrl = 'https://image.tmdb.org/t/p/w500/fallback.jpg';
    const ImageUrlResolver tResolver = ImageUrlResolver(
      imageBaseUrl: tImageBaseUrl,
      actorImageBaseUrl: '',
      noImageUrl: tNoImageUrl,
    );

    test(
      'given a model with a non-empty poster path when toEntity is called '
      'then the poster URL is prefixed with the image base URL',
      () {
        final RemoteMovieModel model = _tMovieModel();

        final Movie entity = RemoteMovieMapper.toEntity(model, tResolver);

        expect(entity.posterPath, 'https://image.tmdb.org/t/p/w500/poster.jpg');
      },
    );

    test(
      'given a model with an empty poster path when toEntity is called '
      'then the fallback image URL is used',
      () {
        final RemoteMovieModel model = _tMovieModel(posterPath: '');

        final Movie entity = RemoteMovieMapper.toEntity(model, tResolver);

        expect(entity.posterPath, tNoImageUrl);
      },
    );

    test(
      'given a model with an empty backdrop path when toEntity is called '
      'then the fallback image URL is used for the backdrop',
      () {
        final RemoteMovieModel model = _tMovieModel(backdropPath: '');

        final Movie entity = RemoteMovieMapper.toEntity(model, tResolver);

        expect(entity.backdropPath, tNoImageUrl);
      },
    );
  });

  group('RemoteActorMapper.toEntity', () {
    const String tActorImageBaseUrl = 'https://image.tmdb.org/t/p/w185';
    const ImageUrlResolver tResolver = ImageUrlResolver(
      imageBaseUrl: '',
      actorImageBaseUrl: tActorImageBaseUrl,
      noImageUrl: '',
    );

    test(
      'given an actor with a profile path when toEntity is called '
      'then the profile URL is prefixed with the actor image base URL',
      () {
        const RemoteActorModel model = RemoteActorModel(
          id: 1,
          name: 'John Doe',
          character: 'Hero',
          profilePath: '/profile.jpg',
        );

        final Actor entity = RemoteActorMapper.toEntity(model, tResolver);

        expect(
          entity.profilePath,
          'https://image.tmdb.org/t/p/w185/profile.jpg',
        );
      },
    );

    test(
      'given an actor without a profile path when toEntity is called '
      'then profilePath is null in the entity',
      () {
        const RemoteActorModel model = RemoteActorModel(
          id: 1,
          name: 'John Doe',
          character: 'Hero',
          profilePath: null,
        );

        final Actor entity = RemoteActorMapper.toEntity(model, tResolver);

        expect(entity.profilePath, isNull);
      },
    );
  });
}

RemoteMovieModel _tMovieModel({
  String posterPath = '/poster.jpg',
  String backdropPath = '/backdrop.jpg',
}) =>
    RemoteMovieModel(
      id: 1,
      title: 'Test Movie',
      originalTitle: 'Test Movie',
      overview: 'Overview',
      posterPath: posterPath,
      backdropPath: backdropPath,
      releaseDate: '2024-01-01',
      popularity: 100.0,
      voteAverage: 7.5,
      voteCount: 1000,
      genreIds: const <int>[28],
      adult: false,
      video: false,
      originalLanguage: 'en',
    );
