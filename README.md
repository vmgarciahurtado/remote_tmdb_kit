# remote_tmdb_kit

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Dart](https://img.shields.io/badge/Dart-3.12%2B-0175C2.svg)](https://dart.dev)
[![Pure Dart](https://img.shields.io/badge/pure-Dart-success.svg)](https://dart.dev/server)

Idioma: Español

Un paquete **Dart puro** (sin dependencia de Flutter) altamente cohesivo, desacoplado y
listo para producción que encapsula la integración con la API de películas de
**The Movie Database (TMDB)**. Funciona igual en apps Flutter, servidores y CLIs.

Está diseñado bajo principios de arquitectura limpia: aísla por completo al cliente de
los detalles HTTP (cabeceras, códigos de estado, deserialización) y expone un control de
flujo funcional basado en el patrón `Result`, con paginación tipada vía `PagedResult`.

> El cliente HTTP por defecto es [`dio`](https://pub.dev/packages/dio), pero la interfaz
> `HttpService` está abierta para inyectar cualquier otro cliente (por ejemplo `http`).

<details>
  <summary>Tabla de contenido</summary>

<!-- TOC -->
* [remote_tmdb_kit](#remote_tmdb_kit)
  * [Empezando](#empezando)
    * [Instalación](#instalación)
    * [Autenticación](#autenticación)
    * [Uso simple](#uso-simple)
  * [Ejemplos](#ejemplos)
    * [Películas populares y paginación](#películas-populares-y-paginación)
    * [Películas en cartelera](#películas-en-cartelera)
    * [Búsqueda con filtros avanzados](#búsqueda-con-filtros-avanzados)
    * [Reparto de una película](#reparto-de-una-película)
  * [API del repositorio](#api-del-repositorio)
  * [Manejo de errores](#manejo-de-errores)
  * [Imágenes](#imágenes)
  * [Logging](#logging)
  * [Cambiar el cliente HTTP](#cambiar-el-cliente-http)
  * [¿Tienes otra fuente de datos?](#tienes-otra-fuente-de-datos)
  * [Características](#características)
  * [Estructura del paquete](#estructura-del-paquete)
  * [Pruebas](#pruebas)
  * [Versionamiento (SemVer)](#versionamiento-semver)
  * [Licencia](#licencia)
<!-- TOC -->
</details>

## Empezando

### Instalación

Agrega la dependencia en el `pubspec.yaml` de tu aplicación:

```yaml
dependencies:
  remote_tmdb_kit: ^3.0.0
```

O instálala desde la terminal:

```bash
dart pub add remote_tmdb_kit   # proyectos Dart
flutter pub add remote_tmdb_kit # proyectos Flutter
```

### Autenticación

TMDB soporta dos mecanismos y el paquete acepta ambos (debes proveer al menos uno):

* **`accessToken` (v4, recomendado)**: el *API Read Access Token*. Viaja como cabecera
  `Authorization: Bearer …`, por lo que nunca queda expuesto en las URLs ni en logs
  de acceso.
* **`apiKey` (v3)**: la clave clásica. Viaja como parámetro de consulta `api_key`.

### Uso simple

Crea el repositorio con la factoría `createTmdbMovieRepository`, pasando un objeto
`TmdbConfig`:

```dart
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

final repository = createTmdbMovieRepository(
  const TmdbConfig(
    accessToken: 'TU_ACCESS_TOKEN_V4', // o apiKey: 'TU_API_KEY_V3'
    language: 'es-ES',     // Idioma de los datos devueltos (por defecto)
    enableLogging: false,  // Logs HTTP (por defecto false)
  ),
);

final result = await repository.getPopular(page: 1);
```

## Ejemplos

### Películas populares y paginación

Los endpoints de listado retornan un `PagedResult<Movie>` con los metadatos de
paginación de TMDB, ideal para scroll infinito:

```dart
void fetchPopularMovies() async {
  final Result<PagedResult<Movie>> result = await repository.getPopular(page: 1);

  switch (result) {
    case Success(data: final paged):
      print('Página ${paged.page} de ${paged.totalPages} '
          '(${paged.totalResults} resultados)');
      for (final movie in paged.results) {
        print('- ${movie.title} (${movie.releaseDate})');
      }
      if (paged.hasNextPage) {
        // Solicita la siguiente página cuando el usuario llegue al final.
      }
    case FailureResult(failure: final failure):
      // El mensaje ya viene traducido y listo para pintar en pantalla.
      print('Error: ${failure.userMessage}');
  }
}
```

### Películas en cartelera

```dart
final Result<PagedResult<Movie>> result = await repository.getNowPlaying(page: 1);
```

### Búsqueda con filtros avanzados

Usa `MovieSearchFilter` para acotar la búsqueda:

```dart
void searchMovies() async {
  final filter = MovieSearchFilter(
    includeAdult: false,
    primaryReleaseYear: 2024,
    language: 'es-ES',
  );

  final result = await repository.searchMovies(
    'Batman',
    page: 1,
    filter: filter,
  );

  if (result case Success(data: final paged)) {
    final movies = paged.results;
    // ... mostrar listado filtrado
  }
}
```

También puedes construir el filtro de forma incremental con
`MovieSearchFilterBuilder` (patrón Builder), útil cuando los criterios se arman
paso a paso desde una interfaz:

```dart
final filter = MovieSearchFilterBuilder()
    .includeAdult(false)
    .primaryReleaseYear(2024)
    .language('es-ES')
    .build();

final result = await repository.searchMovies('Batman', filter: filter);
```

### Reparto de una película

```dart
final Result<List<Actor>> result = await repository.getMovieCast(550); // Fight Club

if (result case Success(data: final cast)) {
  for (final actor in cast) {
    print('${actor.name} como ${actor.character}');
  }
}
```

## API del repositorio

`MovieRepository` expone cuatro métodos. Todos retornan un `Result`:

```dart
Future<Result<PagedResult<Movie>>> getNowPlaying({int page = 1});
Future<Result<PagedResult<Movie>>> getPopular({int page = 1});
Future<Result<PagedResult<Movie>>> searchMovies(String query, {int page = 1, MovieSearchFilter? filter});
Future<Result<List<Actor>>> getMovieCast(int movieId);
```

La factoría `createTmdbMovieRepository` recibe un objeto `TmdbConfig` con los
siguientes campos:

| Parámetro           | Tipo         | Por defecto                       | Descripción                                            |
|---------------------|--------------|-----------------------------------|--------------------------------------------------------|
| `apiKey`            | `String?`    | `null`                            | Clave v3. Obligatoria si no hay `accessToken`.         |
| `accessToken`       | `String?`    | `null`                            | Token de lectura v4 (recomendado).                     |
| `enableLogging`     | `bool`       | `false`                           | Activa los logs HTTP vía `logger`.                     |
| `baseUrl`           | `String`     | `https://api.themoviedb.org/3/`   | URL base de la API.                                    |
| `language`          | `String`     | `es-ES`                           | Idioma de los datos devueltos.                         |
| `imageBaseUrl`      | `String`     | `https://image.tmdb.org/t/p/w500` | URL base para imágenes de películas.                   |
| `actorImageBaseUrl` | `String`     | `https://image.tmdb.org/t/p/w185` | URL base para fotos de actores.                        |
| `connectTimeout`    | `Duration`   | `5 s`                             | Tiempo máximo para establecer conexión.                |
| `receiveTimeout`    | `Duration`   | `5 s`                             | Tiempo máximo para recibir la respuesta.               |
| `logger`            | `TmdbLogger` | `print`                           | Destino de cada línea de log HTTP.                     |

## Manejo de errores

`Result<T>` es una clase sellada (`sealed`) con dos variantes: `Success<T>` y
`FailureResult<T>`. Esto obliga a manejar ambos casos en tiempo de compilación.

```dart
switch (result) {
  case Success(data: final value):
    // usar value
  case FailureResult(failure: final error):
    print(error.userMessage);
}
```

Las fallas tipadas disponibles son `ConnectionFailure`, `ServerFailure` (con
`statusCode`), `NotFoundFailure`, `UnauthorizedFailure`, `RateLimitFailure`
(HTTP 429) y `UnexpectedFailure`. Todas conservan el error original (`cause`)
y su traza (`stackTrace`) para depuración:

```dart
if (result case FailureResult(failure: final failure)) {
  miLogger.error(failure.message, failure.cause, failure.stackTrace);
}
```

¿Prefieres un estilo más funcional? La extensión `ResultX` incluye
`getOrThrow()`, `dataOrNull`, `failureOrNull`, `isSuccess`, `fold` y `map`:

```dart
final String label = result.fold(
  onSuccess: (paged) => '${paged.totalResults} películas',
  onFailure: (failure) => failure.userMessage,
);
```

## Imágenes

`posterPath`, `backdropPath` y `profilePath` llegan como URLs absolutas listas
para usar, o `null` cuando TMDB no provee la imagen. El placeholder es una
decisión de interfaz que queda en manos de tu app:

```dart
movie.posterPath != null
    ? Image.network(movie.posterPath!)
    : const Icon(Icons.movie); // tu fallback
```

## Logging

Con `enableLogging: true` el paquete registra peticiones, respuestas y errores.
Las credenciales se redactan automáticamente (`api_key=REDACTED` y cabecera
`Authorization` enmascarada). Por defecto imprime en consola; puedes inyectar
tu propio destino:

```dart
final config = TmdbConfig(
  accessToken: token,
  enableLogging: true,
  logger: (message) => miLogger.debug(message),
);
```

## Cambiar el cliente HTTP

Si prefieres el paquete nativo `http` (u otro cliente), implementa la interfaz
`HttpService` e inyéctala en `RemoteMovieRepositoryImpl`, sin tocar el código del paquete:

```dart
import 'package:http/http.dart' as http;
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

// 1. Implementa la interfaz con la librería que desees.
class HttpPackageClient implements HttpService {
  final http.Client client = http.Client();

  @override
  Future<T> request<T>(
    String path, {
    required HttpMethod method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    // ... conversión HTTP y mapeo de errores a Failure
  }
}

// 2. Inyéctalo manualmente al instanciar el repositorio.
final resolver = ImageUrlResolver(
  imageBaseUrl: 'https://image.tmdb.org/t/p/w500',
  actorImageBaseUrl: 'https://image.tmdb.org/t/p/w185',
);

final repository = RemoteMovieRepositoryImpl(HttpPackageClient(), resolver);
```

## ¿Tienes otra fuente de datos?

`MovieRepository` es una **interfaz abstracta pura** (no depende de `dio` ni de
ninguna otra pieza de infraestructura), y `createTmdbMovieRepository` (que
consume TMDB) es solo la implementación por defecto. Si tu fuente de datos
no es TMDB —una base de datos local, una caché, un archivo JSON u otro
backend—, puedes implementar tú mismo el contrato sin tocar el código del
paquete:

```dart
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

/// Fuente de datos propia: aquí decides de dónde sale la información.
class MyCustomMovieRepository implements MovieRepository {
  @override
  Future<Result<PagedResult<Movie>>> getNowPlaying({int page = 1}) async {
    // Consulta tu fuente (BD, caché, JSON...) y devuelve un Result.
    return const Success(
      PagedResult(page: 1, results: <Movie>[], totalPages: 1, totalResults: 0),
    );
  }

  @override
  Future<Result<PagedResult<Movie>>> getPopular({int page = 1}) async {
    return const Success(
      PagedResult(page: 1, results: <Movie>[], totalPages: 1, totalResults: 0),
    );
  }

  @override
  Future<Result<PagedResult<Movie>>> searchMovies(
    String query, {
    int page = 1,
    MovieSearchFilter? filter,
  }) async {
    return const Success(
      PagedResult(page: 1, results: <Movie>[], totalPages: 1, totalResults: 0),
    );
  }

  @override
  Future<Result<List<Actor>>> getMovieCast(int movieId) async {
    return const Success(<Actor>[]);
  }
}
```

Como tu app depende de la abstracción `MovieRepository` y no de la
implementación concreta, puedes intercambiar la fuente de datos sin cambiar el
resto del código (inversión de dependencias).

## Características

* **Dart puro**: sin dependencia de Flutter; úsalo en apps móviles, servidores o CLIs.
* **Aislamiento de errores**: mapea automáticamente excepciones de red y códigos HTTP
  crudos a fallos tipados (`ConnectionFailure`, `ServerFailure`, `NotFoundFailure`,
  `UnauthorizedFailure`, `RateLimitFailure`, `UnexpectedFailure`) con mensajes en
  español listos para mostrar, conservando `cause` y `stackTrace` para depurar.
* **Flujo funcional con `Result`**: cada petición retorna `Success<T>` o
  `FailureResult<T>`, con helpers `fold`, `map`, `dataOrNull` y `getOrThrow`.
* **Paginación tipada**: `PagedResult<Movie>` expone `page`, `totalPages`,
  `totalResults` y `hasNextPage` para scroll infinito sin adivinanzas.
* **Autenticación v3 y v4**: `api_key` clásica o Bearer token de solo lectura.
* **Filtros de búsqueda avanzados**: modelo inmutable `MovieSearchFilter` para refinar
  búsquedas (idioma, año, región, contenido para adultos).
* **Logger HTTP opcional y seguro**: registro detallado con credenciales redactadas
  y destino inyectable, desactivado por defecto.
* **Entidades con igualdad de valor**: `Movie` y `Actor` implementan `==`/`hashCode`,
  listas inmutables incluidas.
* **Documentación en hover**: toda la API pública está documentada con Dartdoc e incluye
  ejemplos visibles desde el editor.
* **Cliente HTTP desacoplable**: viene con `dio` por defecto, pero `HttpService` permite
  inyectar cualquier cliente.
* **Sin acoplamiento a gestores de estado**: úsalo con Riverpod, BLoC, Provider o
  `setState` puro.
* **Sin dependencias de mocking en tests**: cobertura construida con *fakes* escritos a mano.

## Estructura del paquete

La estructura interna (`lib/src/`) está dividida de forma modular por responsabilidad:

| Carpeta          | Responsabilidad                                                        |
|------------------|------------------------------------------------------------------------|
| `errors/`        | Jerarquía de fallas de negocio (`failures.dart`).                      |
| `result/`        | Tipo `Result` (`Success` / `FailureResult`) y extensión `ResultX`.     |
| `network/`       | Abstracciones de red (`HttpService`, `HttpMethod`) + impl. con `dio`.  |
| `models/`        | Entidades de dominio (`Movie`, `Actor`, `PagedResult`, filtros).       |
| `dtos/`          | Modelos de deserialización JSON de TMDB (internos).                    |
| `mappers/`       | Conversores de DTO a entidad.                                          |
| `services/`      | Resolución de URLs de imágenes (`ImageUrlResolver`).                   |
| `helpers/`       | Utilidades internas (`executeRepositoryCall`).                         |
| `repositories/`  | Interfaz pura `MovieRepository` e implementación concreta.             |
| `factory/`       | Composition root: `createTmdbMovieRepository`.                         |

## Pruebas

El paquete incluye una suite de pruebas unitarias construida con *fakes* (sin `mockito`
ni `mocktail`):

```bash
dart test
```

## Versionamiento (SemVer)

Este paquete sigue [Semantic Versioning](https://semver.org/):

* **Parche (`x.y.Z`)**: correcciones internas que no afectan la API pública
  (bugfixes, optimizaciones, documentación).
* **Menor (`x.Y.z`)**: nuevas funcionalidades retrocompatibles
  (un nuevo parámetro opcional o un nuevo método del repositorio).
* **Mayor (`X.y.z`)**: cambios que rompen compatibilidad
  (renombrar propiedades de `Movie` o cambiar firmas de retorno).

Consulta el historial completo de cambios en [CHANGELOG.md](CHANGELOG.md).

## Licencia

Distribuido bajo la licencia MIT. Consulta [LICENSE](LICENSE) para más detalles.
