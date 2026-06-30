/// Modelo de dominio que representa una película detallada obtenida de TMDB.
///
/// Todas las propiedades son inmutables y contienen la información básica
/// de la película formateada y lista para mostrar en la interfaz de usuario.
class Movie {
  /// Crea una instancia inmutable de [Movie].
  const Movie({
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

  /// Identificador único de la película en la base de datos de TMDB.
  final int id;

  /// Título traducido de la película.
  final String title;

  /// Título original de la película en su idioma original.
  final String originalTitle;

  /// Breve sinopsis o resumen de la trama de la película.
  final String overview;

  /// URL completa de la imagen del póster de la película.
  ///
  /// Si la película no tiene póster asignado, contendrá la URL de fallback
  /// configurada.
  final String posterPath;

  /// URL completa de la imagen de fondo (backdrop) de la película.
  ///
  /// Si la película no tiene fondo asignado, contendrá la URL de fallback
  /// configurada.
  final String backdropPath;

  /// Fecha de lanzamiento de la película (usualmente en formato `AAAA-MM-DD`).
  final String releaseDate;

  /// Puntuación de popularidad calculada por TMDB.
  final double popularity;

  /// Promedio de calificaciones recibidas por la película
  /// (rango de 0.0 a 10.0).
  final double voteAverage;

  /// Cantidad total de votos registrados para calcular el promedio de
  /// calificaciones.
  final int voteCount;

  /// Lista de identificadores de géneros asociados a la película.
  final List<int> genreIds;

  /// Indica si la película está clasificada como contenido para adultos.
  final bool adult;

  /// Indica si la película tiene un video promocional (tráiler) asociado.
  final bool video;

  /// Código de idioma original en el que se grabó la película (ej. 'en', 'es').
  final String originalLanguage;
}
