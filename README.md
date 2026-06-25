# remote_tmdb_kit

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Dart](https://img.shields.io/badge/Dart-3.12%2B-0175C2.svg)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D1.17-02569B.svg)](https://flutter.dev)
[![Tests](https://img.shields.io/badge/tests-44%20passing-success.svg)](test)

Idioma: Español

Un paquete Dart/Flutter altamente cohesivo, desacoplado y listo para producción que
encapsula la integración con la API de películas de **The Movie Database (TMDB)**.

Está diseñado bajo principios de arquitectura limpia: aísla por completo al cliente de
los detalles HTTP (cabeceras, códigos de estado, deserialización) y expone un control de
flujo funcional basado en el patrón `Result`.

> El cliente HTTP por defecto es [`dio`](https://pub.dev/packages/dio), pero la interfaz
> `HttpService` está abierta para inyectar cualquier otro cliente (por ejemplo `http`).

<details>
  <summary>Tabla de contenido</summary>

<!-- TOC -->
* [remote_tmdb_kit](#remote_tmdb_kit)
  * [Empezando](#empezando)
    * [Instalación](#instalación)
    * [Uso simple](#uso-simple)
  * [Ejemplos](#ejemplos)
    * [Películas populares](#películas-populares)
    * [Películas en cartelera](#películas-en-cartelera)
    * [Búsqueda con filtros avanzados](#búsqueda-con-filtros-avanzados)
    * [Reparto de una película](#reparto-de-una-película)
  * [API del repositorio](#api-del-repositorio)
  * [Manejo de errores](#manejo-de-errores)
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
  remote_tmdb_kit: ^2.0.0
```

O instálala desde la terminal:

```bash
flutter pub add remote_tmdb_kit
```

Luego descarga las dependencias:

```bash
flutter pub get
```

### Uso simple

Crea el repositorio con `MovieRepository.create`, pasando un objeto
`TmdbConfig` con tu `apiKey` de TMDB:

```dart
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

final repository = MovieRepository.create(
  const TmdbConfig(
    apiKey: 'TU_API_KEY_DE_TMDB',
    language: 'es-ES',     // Idioma de los datos devueltos (por defecto)
    enableLogging: false,  // Logs en consola (por defecto false)
  ),
);

final result = await repository.getPopular(page: 1);
```

## Ejemplos

### Películas populares

```dart
void fetchPopularMovies() async {
  final Result<List<Movie>> result = await repository.getPopular(page: 1);

  switch (result) {
    case Success(data: final movies):
      for (final movie in movies) {
        print('- ${movie.title} (${movie.releaseDate})');
      }
    case FailureResult(failure: final failure):
      // El mensaje ya viene traducido y listo para pintar en pantalla.
      print('Error: ${failure.userMessage}');
  }
}
```

### Películas en cartelera

```dart
final Result<List<Movie>> result = await repository.getNowPlaying(page: 1);
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

  final Result<List<Movie>> result = await repository.searchMovies(
    'Batman',
    page: 1,
    filter: filter,
  );

  if (result is Success<List<Movie>>) {
    final movies = result.data;
    // ... mostrar listado filtrado
  }
}
```

### Reparto de una película

```dart
final Result<List<Actor>> result = await repository.getMovieCast(550); // Fight Club

if (result is Success<List<Actor>>) {
  for (final actor in result.data) {
    print('${actor.name} como ${actor.character}');
  }
}
```

## API del repositorio

`MovieRepository` expone cuatro métodos. Todos retornan un `Result`:

```dart
Future<Result<List<Movie>>> getNowPlaying({int page = 1});
Future<Result<List<Movie>>> getPopular({int page = 1});
Future<Result<List<Movie>>> searchMovies(String query, {int page = 1, MovieSearchFilter? filter});
Future<Result<List<Actor>>> getMovieCast(int movieId);
```

El constructor de factoría `MovieRepository.create` recibe un objeto
`TmdbConfig` con los siguientes campos:

| Parámetro            | Tipo     | Por defecto                              | Descripción                                  |
|----------------------|----------|------------------------------------------|----------------------------------------------|
| `apiKey`             | `String` | — (requerido)                            | Clave de acceso a la API de TMDB.            |
| `enableLogging`      | `bool`   | `false`                                  | Activa los logs HTTP en consola.             |
| `baseUrl`            | `String` | `https://api.themoviedb.org/3/`          | URL base de la API.                          |
| `imageBaseUrl`       | `String` | `https://image.tmdb.org/t/p/w500`        | URL base para imágenes de películas.         |
| `actorImageBaseUrl`  | `String` | `https://image.tmdb.org/t/p/w185`        | URL base para fotos de actores.              |
| `noImageUrl`         | `String` | URL de fallback                          | Imagen usada cuando no hay póster.           |
| `language`           | `String` | `es-ES`                                  | Idioma de los datos devueltos.               |

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

¿Prefieres propagar el error con `try/catch`? Usa la extensión `getOrThrow`:

```dart
try {
  final movies = result.getOrThrow(); // retorna la lista o lanza el Failure
} on Failure catch (e) {
  print(e.userMessage);
}
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
  noImageUrl: 'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg',
);

final repository = RemoteMovieRepositoryImpl(HttpPackageClient(), resolver);
```

## ¿Tienes otra fuente de datos?

`MovieRepository` es una **interfaz abstracta**, y `MovieRepository.create`
(que consume TMDB) es solo la implementación por defecto. Si tu fuente de datos
no es TMDB —una base de datos local, una caché, un archivo JSON u otro
backend—, puedes implementar tú mismo el contrato sin tocar el código del
paquete:

```dart
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

/// Fuente de datos propia: aquí decides de dónde sale la información.
class MyCustomMovieRepository implements MovieRepository {
  @override
  Future<Result<List<Movie>>> getNowPlaying({int page = 1}) async {
    // Consulta tu fuente (BD, caché, JSON...) y devuelve un Result.
    return const Success(<Movie>[]);
  }

  @override
  Future<Result<List<Movie>>> getPopular({int page = 1}) async {
    return const Success(<Movie>[]);
  }

  @override
  Future<Result<List<Movie>>> searchMovies(
    String query, {
    int page = 1,
    MovieSearchFilter? filter,
  }) async {
    return const Success(<Movie>[]);
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

* **Aislamiento de errores**: mapea automáticamente excepciones de red y códigos HTTP
  crudos a fallos tipados (`ConnectionFailure`, `ServerFailure`, `NotFoundFailure`,
  `UnauthorizedFailure`, `UnexpectedFailure`) con mensajes en español listos para mostrar.
* **Flujo funcional con `Result`**: cada petición retorna `Success<T>` o `FailureResult<T>`,
  dando seguridad de tipos al manejar estados en la UI.
* **Filtros de búsqueda avanzados**: modelo inmutable `MovieSearchFilter` para refinar
  búsquedas (idioma, año, región, contenido para adultos).
* **Logger HTTP opcional**: registro detallado de peticiones, respuestas y errores en
  consola, desactivado por defecto (`enableLogging = false`).
* **Documentación en hover**: toda la API pública está documentada con Dartdoc e incluye
  ejemplos visibles desde el editor.
* **Cliente HTTP desacoplable**: viene con `dio` por defecto, pero `HttpService` permite
  inyectar cualquier cliente.
* **Resolución automática de imágenes**: `ImageUrlResolver` convierte rutas parciales de
  TMDB en URLs absolutas, con fallback para imágenes no disponibles.
* **Sin acoplamiento a gestores de estado**: úsalo con Riverpod, BLoC, Provider o
  `setState` puro.
* **Sin dependencias de mocking en tests**: cobertura construida con *fakes* escritos a mano.

## Estructura del paquete

La estructura interna (`lib/src/`) está dividida de forma modular por responsabilidad:

| Carpeta          | Responsabilidad                                                       |
|------------------|-----------------------------------------------------------------------|
| `errors/`        | Jerarquía de fallas de negocio (`failures.dart`).                     |
| `result/`        | Tipo `Result` (`Success` / `FailureResult`).                          |
| `network/`       | Abstracciones de red (`HttpService`, `HttpMethod`) + impl. con `dio`. |
| `models/`        | Entidades de dominio (`Movie`, `Actor`, `MovieSearchFilter`).         |
| `dtos/`          | Modelos de deserialización JSON de TMDB (internos).                   |
| `mappers/`       | Conversores de DTO a entidad.                                         |
| `services/`      | Resolución de URLs de imágenes (`ImageUrlResolver`).                  |
| `helpers/`       | Utilidades internas (`executeRepositoryCall`).                        |
| `repositories/`  | Interfaz `MovieRepository` e implementación concreta.                 |

## Pruebas

El paquete incluye una suite de pruebas unitarias construida con *fakes* (sin `mockito`
ni `mocktail`):

```bash
flutter test
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
