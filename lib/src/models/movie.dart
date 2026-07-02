/// Modelo de dominio que representa una película detallada obtenida de TMDB.
///
/// Todas las propiedades son inmutables y contienen la información básica
/// de la película formateada y lista para mostrar en la interfaz de usuario.
///
/// Implementa igualdad estructural: dos instancias con los mismos valores
/// son iguales, lo que facilita comparaciones en gestores de estado y tests.
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

  /// URL completa de la imagen del póster de la película, o `null` si
  /// TMDB no provee un póster.
  ///
  /// La imagen de reemplazo (placeholder) es una decisión de interfaz que
  /// corresponde a la aplicación consumidora.
  final String? posterPath;

  /// URL completa de la imagen de fondo (backdrop) de la película, o
  /// `null` si TMDB no provee un fondo.
  final String? backdropPath;

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

  /// Lista inmutable de identificadores de géneros asociados a la película.
  final List<int> genreIds;

  /// Indica si la película está clasificada como contenido para adultos.
  final bool adult;

  /// Indica si la película tiene un video promocional (tráiler) asociado.
  final bool video;

  /// Código de idioma original en el que se grabó la película (ej. 'en', 'es').
  final String originalLanguage;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Movie &&
        other.id == id &&
        other.title == title &&
        other.originalTitle == originalTitle &&
        other.overview == overview &&
        other.posterPath == posterPath &&
        other.backdropPath == backdropPath &&
        other.releaseDate == releaseDate &&
        other.popularity == popularity &&
        other.voteAverage == voteAverage &&
        other.voteCount == voteCount &&
        _listEquals(other.genreIds, genreIds) &&
        other.adult == adult &&
        other.video == video &&
        other.originalLanguage == originalLanguage;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    originalTitle,
    overview,
    posterPath,
    backdropPath,
    releaseDate,
    popularity,
    voteAverage,
    voteCount,
    Object.hashAll(genreIds),
    adult,
    video,
    originalLanguage,
  );

  @override
  String toString() => 'Movie(id: $id, title: $title)';
}

bool _listEquals(List<int> a, List<int> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
