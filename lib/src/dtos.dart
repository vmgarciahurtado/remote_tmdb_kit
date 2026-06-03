import 'image_url_resolver.dart';
import 'models.dart';

class RemoteMovieModel {
  const RemoteMovieModel({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.popularity,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
    required this.adult,
    required this.video,
    required this.originalLanguage,
  });

  factory RemoteMovieModel.fromJson(Map<String, dynamic> json) =>
      RemoteMovieModel(
        id: (json['id'] as num).toInt(),
        title: json['title'] as String,
        originalTitle: json['original_title'] as String,
        overview: json['overview'] as String,
        posterPath: json['poster_path'] as String? ?? '',
        backdropPath: json['backdrop_path'] as String? ?? '',
        releaseDate: json['release_date'] as String? ?? '',
        popularity: (json['popularity'] as num).toDouble(),
        voteAverage: (json['vote_average'] as num).toDouble(),
        voteCount: (json['vote_count'] as num).toInt(),
        genreIds:
            (json['genre_ids'] as List<dynamic>?)
                ?.map((dynamic e) => (e as num).toInt())
                .toList() ??
            <int>[],
        adult: json['adult'] as bool? ?? false,
        video: json['video'] as bool? ?? false,
        originalLanguage: json['original_language'] as String? ?? '',
      );

  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double popularity;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;
  final bool adult;
  final bool video;
  final String originalLanguage;
}

class RemoteActorModel {
  const RemoteActorModel({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
  });

  factory RemoteActorModel.fromJson(Map<String, dynamic> json) =>
      RemoteActorModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        character: json['character'] as String? ?? '',
        profilePath: json['profile_path'] as String?,
      );

  final int id;
  final String name;
  final String character;
  final String? profilePath;
}

class RemoteMovieResponse {
  const RemoteMovieResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory RemoteMovieResponse.fromJson(Map<String, dynamic> json) =>
      RemoteMovieResponse(
        page: (json['page'] as num).toInt(),
        results: (json['results'] as List<dynamic>)
            .map(
              (dynamic e) =>
                  RemoteMovieModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        totalPages: (json['total_pages'] as num).toInt(),
        totalResults: (json['total_results'] as num).toInt(),
      );

  final int page;
  final List<RemoteMovieModel> results;
  final int totalPages;
  final int totalResults;
}

class RemoteCastResponse {
  const RemoteCastResponse({
    required this.id,
    required this.cast,
  });

  factory RemoteCastResponse.fromJson(Map<String, dynamic> json) =>
      RemoteCastResponse(
        id: (json['id'] as num).toInt(),
        cast: (json['cast'] as List<dynamic>)
            .map(
              (dynamic e) =>
                  RemoteActorModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );

  final int id;
  final List<RemoteActorModel> cast;
}

class RemoteMovieMapper {
  const RemoteMovieMapper._();

  static Movie toEntity(RemoteMovieModel model, ImageUrlResolver resolver) =>
      Movie(
        id: model.id,
        title: model.title,
        originalTitle: model.originalTitle,
        overview: model.overview,
        posterPath: resolver.movieImage(model.posterPath),
        backdropPath: resolver.movieImage(model.backdropPath),
        releaseDate: model.releaseDate,
        popularity: model.popularity,
        voteAverage: model.voteAverage,
        voteCount: model.voteCount,
        genreIds: model.genreIds,
        adult: model.adult,
        video: model.video,
        originalLanguage: model.originalLanguage,
      );
}

class RemoteActorMapper {
  const RemoteActorMapper._();

  static Actor toEntity(RemoteActorModel model, ImageUrlResolver resolver) =>
      Actor(
        id: model.id,
        name: model.name,
        character: model.character,
        profilePath: resolver.actorImage(model.profilePath),
      );
}
