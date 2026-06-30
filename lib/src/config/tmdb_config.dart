/// Configuración necesaria para inicializar el cliente de la API de TMDB.
///
/// Agrupa en un único objeto inmutable los parámetros de conexión, idioma
/// y resolución de imágenes que consume [MovieRepository.create], evitando
/// una lista extensa de parámetros sueltos en el constructor de factoría.
///
/// ### Ejemplo de uso:
/// ```dart
/// const config = TmdbConfig(
///   apiKey: 'TU_API_KEY_DE_TMDB',
///   enableLogging: true,
///   language: 'en-US',
/// );
/// ```
class TmdbConfig {
  /// Crea la configuración del cliente de TMDB.
  ///
  /// - [apiKey]: Clave de acceso a la API de TMDB (requerida).
  /// - [enableLogging]: Si es `true`, registra en consola las llamadas HTTP.
  /// - [baseUrl]: URL base de la API de TMDB (por defecto versión 3).
  /// - [language]: Idioma de los datos devueltos por la API.
  /// - [imageBaseUrl]: URL base para resolver imágenes de películas.
  /// - [actorImageBaseUrl]: URL base para resolver fotos de actores.
  /// - [noImageUrl]: Imagen de fallback cuando un póster no está disponible.
  const TmdbConfig({
    required this.apiKey,
    this.enableLogging = false,
    this.baseUrl = 'https://api.themoviedb.org/3/',
    this.language = 'es-ES',
    this.imageBaseUrl = 'https://image.tmdb.org/t/p/w500',
    this.actorImageBaseUrl = 'https://image.tmdb.org/t/p/w185',
    this.noImageUrl =
        'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg',
  });

  /// Clave de acceso a la API de TMDB.
  final String apiKey;

  /// Indica si se deben registrar en consola las llamadas HTTP.
  final bool enableLogging;

  /// URL base de la API de TMDB.
  final String baseUrl;

  /// Idioma de los datos devueltos por la API (por defecto `es-ES`).
  final String language;

  /// URL base para obtener imágenes de películas (pósteres y fondos).
  final String imageBaseUrl;

  /// URL base para obtener fotos de perfil de actores.
  final String actorImageBaseUrl;

  /// URL de fallback que se retornará cuando no haya póster disponible.
  final String noImageUrl;

  /// Crea una copia de esta configuración reemplazando solo los valores
  /// indicados y conservando el resto.
  ///
  /// Útil para derivar variantes (por ejemplo, cambiar únicamente el idioma
  /// o activar el logging) sin reescribir todos los campos, manteniendo el
  /// objeto base inmutable.
  TmdbConfig copyWith({
    String? apiKey,
    bool? enableLogging,
    String? baseUrl,
    String? language,
    String? imageBaseUrl,
    String? actorImageBaseUrl,
    String? noImageUrl,
  }) {
    return TmdbConfig(
      apiKey: apiKey ?? this.apiKey,
      enableLogging: enableLogging ?? this.enableLogging,
      baseUrl: baseUrl ?? this.baseUrl,
      language: language ?? this.language,
      imageBaseUrl: imageBaseUrl ?? this.imageBaseUrl,
      actorImageBaseUrl: actorImageBaseUrl ?? this.actorImageBaseUrl,
      noImageUrl: noImageUrl ?? this.noImageUrl,
    );
  }
}
