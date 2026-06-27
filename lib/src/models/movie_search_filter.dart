/// Representa un conjunto de criterios de filtrado avanzados para buscar
/// películas.
///
/// Permite acotar las búsquedas utilizando parámetros específicos soportados
/// por el endpoint `search/movie` de la API de TMDB.
///
/// ### Ejemplo de uso:
/// ```dart
/// final filter = MovieSearchFilter(
///   includeAdult: false,
///   primaryReleaseYear: 2024,
///   language: 'es-ES',
///   region: 'MX',
///   year: 2024,
/// );
/// ```
class MovieSearchFilter {
  /// Crea un objeto inmutable de filtros para la búsqueda de películas.
  const MovieSearchFilter({
    this.includeAdult,
    this.language,
    this.primaryReleaseYear,
    this.region,
    this.year,
  });

  /// Si es `true`, la búsqueda incluirá películas clasificadas para adultos.
  final bool? includeAdult;

  /// Código de idioma específico para anular el configurado por defecto
  /// (ej. 'en-US').
  final String? language;

  /// Filtra los resultados para mostrar películas cuyo año de lanzamiento
  /// principal coincide.
  final int? primaryReleaseYear;

  /// Código de país ISO 3166-1 para especificar una región de búsqueda
  /// (ej. 'US', 'ES').
  final String? region;

  /// Filtra los resultados para mostrar películas cuyo año de lanzamiento
  /// coincide.
  final int? year;

  /// Convierte los filtros configurados en un mapa de parámetros de
  /// consulta (`queryParameters`).
  ///
  /// Solo se incluyen en el mapa los campos que no sean nulos.
  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if (includeAdult != null) 'include_adult': includeAdult,
      if (language != null) 'language': language,
      if (primaryReleaseYear != null)
        'primary_release_year': primaryReleaseYear,
      if (region != null) 'region': region,
      if (year != null) 'year': year,
    };
  }

  /// Crea una copia de este objeto con algunos de sus valores modificados.
  MovieSearchFilter copyWith({
    bool? includeAdult,
    String? language,
    int? primaryReleaseYear,
    String? region,
    int? year,
  }) {
    return MovieSearchFilter(
      includeAdult: includeAdult ?? this.includeAdult,
      language: language ?? this.language,
      primaryReleaseYear: primaryReleaseYear ?? this.primaryReleaseYear,
      region: region ?? this.region,
      year: year ?? this.year,
    );
  }
}

/// Constructor fluido (patrón Builder) para crear instancias de
/// [MovieSearchFilter] de forma incremental.
///
/// Es útil cuando los criterios de búsqueda se arman paso a paso —por
/// ejemplo, desde los controles de una interfaz— agregando solo los filtros
/// que se necesiten antes de llamar a [build]. Cada método retorna el propio
/// builder para permitir el encadenamiento.
///
/// ### Ejemplo de uso:
/// ```dart
/// final filter = MovieSearchFilterBuilder()
///     .year(2024)
///     .region('MX')
///     .includeAdult(false)
///     .build();
/// ```
class MovieSearchFilterBuilder {
  bool? _includeAdult;
  String? _language;
  int? _primaryReleaseYear;
  String? _region;
  int? _year;

  /// Define si la búsqueda incluirá contenido para adultos.
  MovieSearchFilterBuilder includeAdult(bool value) {
    _includeAdult = value;
    return this;
  }

  /// Define el código de idioma de la búsqueda (ej. 'en-US').
  MovieSearchFilterBuilder language(String value) {
    _language = value;
    return this;
  }

  /// Define el año de lanzamiento principal por el que filtrar.
  MovieSearchFilterBuilder primaryReleaseYear(int value) {
    _primaryReleaseYear = value;
    return this;
  }

  /// Define el código de región ISO 3166-1 (ej. 'US', 'ES').
  MovieSearchFilterBuilder region(String value) {
    _region = value;
    return this;
  }

  /// Define el año de lanzamiento por el que filtrar.
  MovieSearchFilterBuilder year(int value) {
    _year = value;
    return this;
  }

  /// Construye el [MovieSearchFilter] inmutable con los criterios definidos.
  MovieSearchFilter build() {
    return MovieSearchFilter(
      includeAdult: _includeAdult,
      language: _language,
      primaryReleaseYear: _primaryReleaseYear,
      region: _region,
      year: _year,
    );
  }
}
