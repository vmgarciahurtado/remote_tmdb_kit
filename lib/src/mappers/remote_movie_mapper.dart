import '../dtos/remote_movie_model.dart';
import '../models/movie.dart';
import '../services/image_url_resolver.dart';

/// Mapeador encargado de transformar el DTO de película de red
/// [RemoteMovieModel] a la entidad de dominio limpia e inmutable [Movie].
class RemoteMovieMapper {
  const RemoteMovieMapper._();

  /// Convierte una instancia de [RemoteMovieModel] en [Movie],
  /// usando [resolver] para resolver las URLs completas de las imágenes.
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
        genreIds: List<int>.unmodifiable(model.genreIds),
        adult: model.adult,
        video: model.video,
        originalLanguage: model.originalLanguage,
      );
}
