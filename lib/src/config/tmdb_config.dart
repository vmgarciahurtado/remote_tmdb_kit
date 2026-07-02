/// Firma de la función usada para emitir los logs HTTP del paquete.
typedef TmdbLogger = void Function(String message);

void _defaultLogger(String message) {
  // Salida por consola como valor por defecto; el consumidor puede
  // inyectar su propio logger a través de [TmdbConfig.logger].
  // ignore: avoid_print
  print(message);
}

/// Configuración necesaria para inicializar el cliente de la API de TMDB.
///
/// Agrupa en un único objeto inmutable los parámetros de conexión,
/// autenticación, idioma y resolución de imágenes que consume
/// `createTmdbMovieRepository`, evitando una lista extensa de parámetros
/// sueltos en la factoría.
///
/// Autenticación: debes proveer la [apiKey] (v3) **o** el [accessToken]
/// (token de lectura v4, recomendado por TMDB porque viaja como cabecera
/// `Authorization` y no queda expuesto en las URLs). Si provees ambos, se
/// usa el [accessToken].
///
/// ### Ejemplo de uso:
/// ```dart
/// const config = TmdbConfig(
///   accessToken: 'TU_ACCESS_TOKEN_V4',
///   enableLogging: true,
///   language: 'en-US',
/// );
/// ```
class TmdbConfig {
  /// Crea la configuración del cliente de TMDB.
  ///
  /// - [apiKey]: Clave de acceso v3 de la API de TMDB.
  /// - [accessToken]: Token de lectura v4 de la API de TMDB (recomendado).
  /// - [enableLogging]: Si es `true`, registra las llamadas HTTP vía [logger].
  /// - [baseUrl]: URL base de la API de TMDB (por defecto versión 3).
  /// - [language]: Idioma de los datos devueltos por la API.
  /// - [imageBaseUrl]: URL base para resolver imágenes de películas.
  /// - [actorImageBaseUrl]: URL base para resolver fotos de actores.
  /// - [connectTimeout]: Tiempo máximo para establecer la conexión.
  /// - [receiveTimeout]: Tiempo máximo para recibir la respuesta.
  /// - [logger]: Función que recibe cada línea de log (por defecto consola).
  ///
  /// Es obligatorio proveer [apiKey] o [accessToken].
  const TmdbConfig({
    this.apiKey,
    this.accessToken,
    this.enableLogging = false,
    this.baseUrl = 'https://api.themoviedb.org/3/',
    this.language = 'es-ES',
    this.imageBaseUrl = 'https://image.tmdb.org/t/p/w500',
    this.actorImageBaseUrl = 'https://image.tmdb.org/t/p/w185',
    this.connectTimeout = const Duration(seconds: 5),
    this.receiveTimeout = const Duration(seconds: 5),
    this.logger = _defaultLogger,
  }) : assert(
         apiKey != null || accessToken != null,
         'Debes proveer apiKey (v3) o accessToken (v4) para autenticarte '
         'con TMDB.',
       );

  /// Clave de acceso v3 de la API de TMDB.
  ///
  /// Viaja como parámetro de consulta `api_key`. Se ignora si también se
  /// provee [accessToken].
  final String? apiKey;

  /// Token de lectura v4 de la API de TMDB (recomendado).
  ///
  /// Viaja como cabecera `Authorization: Bearer <token>`, por lo que no
  /// queda expuesto en las URLs ni en los logs de acceso.
  final String? accessToken;

  /// Indica si se deben registrar las llamadas HTTP a través de [logger].
  final bool enableLogging;

  /// URL base de la API de TMDB.
  final String baseUrl;

  /// Idioma de los datos devueltos por la API (por defecto `es-ES`).
  final String language;

  /// URL base para obtener imágenes de películas (pósteres y fondos).
  final String imageBaseUrl;

  /// URL base para obtener fotos de perfil de actores.
  final String actorImageBaseUrl;

  /// Tiempo máximo para establecer la conexión con la API.
  final Duration connectTimeout;

  /// Tiempo máximo para recibir la respuesta de la API.
  final Duration receiveTimeout;

  /// Función que recibe cada línea de log HTTP cuando [enableLogging]
  /// es `true`.
  ///
  /// Por defecto imprime en consola; inyecta aquí tu propio logger si
  /// usas un sistema de registro estructurado.
  final TmdbLogger logger;

  /// Crea una copia de esta configuración reemplazando solo los valores
  /// indicados y conservando el resto.
  ///
  /// Útil para derivar variantes (por ejemplo, cambiar únicamente el idioma
  /// o activar el logging) sin reescribir todos los campos, manteniendo el
  /// objeto base inmutable.
  ///
  /// Nota: por la semántica de `copyWith`, no es posible limpiar (poner en
  /// `null`) la [apiKey] o el [accessToken]; crea un `TmdbConfig` nuevo si
  /// necesitas cambiar el mecanismo de autenticación.
  TmdbConfig copyWith({
    String? apiKey,
    String? accessToken,
    bool? enableLogging,
    String? baseUrl,
    String? language,
    String? imageBaseUrl,
    String? actorImageBaseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    TmdbLogger? logger,
  }) {
    return TmdbConfig(
      apiKey: apiKey ?? this.apiKey,
      accessToken: accessToken ?? this.accessToken,
      enableLogging: enableLogging ?? this.enableLogging,
      baseUrl: baseUrl ?? this.baseUrl,
      language: language ?? this.language,
      imageBaseUrl: imageBaseUrl ?? this.imageBaseUrl,
      actorImageBaseUrl: actorImageBaseUrl ?? this.actorImageBaseUrl,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      logger: logger ?? this.logger,
    );
  }
}
