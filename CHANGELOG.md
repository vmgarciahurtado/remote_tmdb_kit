## 3.0.0

> **Breaking changes.** Interfaz pura + factoría separada, paginación tipada,
> imágenes nullables y paquete Dart puro (sin dependencia de Flutter).

- **BREAKING:** `MovieRepository.create(config)` se movió fuera de la interfaz
  a la factoría de nivel superior `createTmdbMovieRepository(config)`
  (composition root). La interfaz `MovieRepository` ya no depende de `dio` ni
  de ninguna pieza de infraestructura.
- **BREAKING:** los endpoints de listado (`getNowPlaying`, `getPopular` y
  `searchMovies`) ahora retornan `Result<PagedResult<Movie>>` con los
  metadatos de paginación de TMDB (`page`, `totalPages`, `totalResults`,
  `hasNextPage`), necesarios para scroll infinito.
- **BREAKING:** `Movie.posterPath` y `Movie.backdropPath` ahora son `String?`.
  Se eliminó `TmdbConfig.noImageUrl` (apuntaba a un dominio de terceros): la
  imagen de reemplazo es ahora una decisión de la app consumidora.
- **BREAKING:** las subclases de `Failure` usan parámetros nombrados
  (`UnexpectedFailure(message: '...')`) y transportan `cause`/`stackTrace`;
  `ServerFailure` expone `statusCode` tipado.
- **BREAKING:** el paquete es Dart puro: se eliminó la dependencia de Flutter
  (`flutter_test` → `test`, `flutter_lints` → `lints`). Compatible con apps
  Flutter, servidores y CLIs.
- Autenticación v4: `TmdbConfig.accessToken` envía el token de lectura como
  cabecera `Authorization: Bearer …` (recomendado por TMDB). `apiKey` (v3)
  sigue soportada; es obligatorio proveer una de las dos.
- Seguridad: el `LoggingInterceptor` redacta `api_key` y la cabecera
  `Authorization` en los logs; el destino de los logs es inyectable vía
  `TmdbConfig.logger`.
- Nueva falla `RateLimitFailure` para HTTP 429 (límite de peticiones de TMDB).
- Timeouts configurables: `TmdbConfig.connectTimeout` y
  `TmdbConfig.receiveTimeout` (por defecto 5 s).
- `ResultX` ahora incluye `isSuccess`, `isFailure`, `dataOrNull`,
  `failureOrNull`, `fold` y `map`, además de `getOrThrow`.
- `Movie` y `Actor` implementan igualdad estructural (`==`/`hashCode`) y
  `toString`; las listas retornadas (`genreIds`, resultados y reparto) son
  inmutables.
- Calidad: `analysis_options.yaml` ahora incluye `package:lints/recommended.yaml`
  y activa `public_member_api_docs`; análisis estático en cero avisos.

### Migración

```dart
// Antes (2.x)
final repository = MovieRepository.create(
  const TmdbConfig(apiKey: 'TU_API_KEY'),
);
final result = await repository.getPopular();
if (result is Success<List<Movie>>) {
  final movies = result.data;
}

// Ahora (3.0.0)
final repository = createTmdbMovieRepository(
  const TmdbConfig(apiKey: 'TU_API_KEY'), // o accessToken: 'TOKEN_V4'
);
final result = await repository.getPopular();
if (result case Success(data: final paged)) {
  final movies = paged.results; // PagedResult<Movie>
}
```

Además: maneja `posterPath`/`backdropPath` como `String?` (decide tu propio
placeholder) y usa parámetros nombrados al construir fallas
(`UnexpectedFailure(message: '...')`).

## 2.0.0

> **Breaking change.** `MovieRepository.create` ahora recibe un único objeto
> `TmdbConfig` en lugar de parámetros nombrados sueltos.

- **BREAKING:** `MovieRepository.create({required apiKey, ...})` cambió a
  `MovieRepository.create(TmdbConfig config)`. La configuración (apiKey,
  idioma, URLs de imágenes y logging) se agrupa en el value object `TmdbConfig`.
- Documentación: nuevo apartado «¿Tienes otra fuente de datos?» que muestra
  cómo implementar `MovieRepository` con una fuente de datos propia.
- Calidad: análisis estático en cero advertencias con reglas de lint estrictas.

### Migración

```dart
// Antes (1.x)
final repository = MovieRepository.create(
  apiKey: 'TU_API_KEY',
  enableLogging: true,
);

// Ahora (2.0.0)
final repository = MovieRepository.create(
  const TmdbConfig(apiKey: 'TU_API_KEY', enableLogging: true),
);
```

## 1.0.1

- Documentación: instrucciones de instalación vía pub.dev y README reorganizado.
- Ejemplo: app Flutter de demostración que consume el paquete, con la API key
  inyectada mediante un provider global de Riverpod.

## 1.0.0

- Initial version of remote_tmdb_kit.
