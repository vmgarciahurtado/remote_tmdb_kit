# remote_tmdb_kit

Un paquete de Dart/Flutter altamente cohesivo, desacoplado y listo para **pub.dev** que encapsula la integración con la API de películas de The Movie Database (TMDB).

Este paquete está diseñado bajo principios de arquitectura limpia, aislando por completo al cliente de detalles HTTP complejos (como cabeceras y códigos de estado) y exponiendo un control de flujo funcional basado en el patrón `Result`.

---

## Características

* **Aislamiento de Errores**: Mapea automáticamente excepciones de red crudas y códigos de respuesta HTTP a fallos tipados (`ConnectionFailure`, `ServerFailure`, etc.) con mensajes en español amigables para el usuario.
* **Flujo Funcional con Result**: Retorna `Success<T>` o `FailureResult<T>` en cada petición para simplificar y dar seguridad al control de estados en tu interfaz.
* **Cliente HTTP Desacoplable**: Viene configurado por defecto con `Dio`, pero la interfaz `HttpService` está abierta para que inyectes cualquier cliente HTTP de tu preferencia (ej. el paquete nativo `http`).
* **Resolución Automática de Imágenes**: Inyecta dinámicamente un `ImageUrlResolver` para convertir paths parciales de TMDB en URLs absolutas, incluyendo fallback para imágenes no encontradas.
* **100% Libre de Riverpod o Gestores de Estado**: Puedes consumirlo con Riverpod (ver sección de ejemplos), BLoC, Provider o setState puro.
* **Sin Dependencias de Mocking en Tests**: Cobertura de pruebas unitarias robusta construida con Fakes escritos a mano, asegurando rapidez y robustez.

---

## Estructura de Archivos del Paquete

La estructura interna (`lib/src/`) está organizada en archivos planos y cohesivos de mantenimiento sencillo:

* **`failures.dart`**: Jerarquía de excepciones de negocio.
* **`result.dart`**: Monada `Result` y manejadores seguros de llamadas a repositorios.
* **`http_service.dart`**: Abstracciones HTTP, cliente `Dio` por defecto e interceptor de logs en consola.
* **`models.dart`**: Entidades públicas limpias (`Movie` y `Actor`).
* **`dtos.dart`**: Modelos de mapeo JSON de TMDB internos (ocultos al exterior).
* **`image_url_resolver.dart`**: Formateador de URLs de imágenes.
* **`movie_repository.dart`**: Interfaz de repositorio e implementación concreta de red.

---

## Empezando

Agrega la dependencia en el archivo `pubspec.yaml` de tu aplicación de Flutter:

```yaml
dependencies:
  remote_tmdb_kit:
    path: ../remote_tmdb_kit # O la versión publicada en pub.dev
```

Ejecuta el comando para descargar dependencias:

```bash
flutter pub get
```

---

## Instrucciones de Uso

### 1. Inicialización Básica (Dio por defecto)

Usa el constructor `MovieRepository.create` y suministra tu `apiKey` de TMDB. No hay claves privadas en el código del paquete:

```dart
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

final repository = MovieRepository.create(
  apiKey: 'TU_API_KEY_DE_TMDB',
  language: 'es-ES', // Idioma de los datos devueltos
);
```

### 2. Consultar Información

Puedes consultar películas populares, en cartelera, realizar búsquedas u obtener los actores de una película. Maneja el resultado con seguridad mediante patrones funcionales:

```dart
void fetchPopularMovies() async {
  final Result<List<Movie>> result = await repository.getPopular(page: 1);

  switch (result) {
    case Success(data: final movies):
      print('Películas populares cargadas exitosamente:');
      for (final movie in movies) {
        print('- ${movie.title} (${movie.releaseDate})');
      }
      
    case FailureResult(failure: final failure):
      // El mensaje ya viene traducido y listo para pintar en pantalla
      print('Error al cargar datos: ${failure.userMessage}');
  }
}
```

---

## Cómo Cambiar de Cliente HTTP (Desacoplamiento)

Si prefieres usar la librería nativa `http` de Dart en lugar de `Dio`, puedes hacerlo sin tocar el código interno del paquete. 

Solo debes implementar la interfaz `HttpService` e inyectarla en `RemoteMovieRepositoryImpl`:

```dart
import 'package:http/http.dart' as http;
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

// 1. Implementa la interfaz con la librería que desees
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
    // ... Implementa la lógica de conversión HTTP y mapeo a fallos
  }
}

// 2. Inyéctalo manualmente al instanciar el repositorio
final myClient = HttpPackageClient();
final resolver = ImageUrlResolver(
  imageBaseUrl: 'https://image.tmdb.org/t/p/w500',
  actorImageBaseUrl: 'https://image.tmdb.org/t/p/w185',
  noImageUrl: 'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg',
);

final repository = RemoteMovieRepositoryImpl(myClient, resolver);
```

---

## Integración con Riverpod 3 (Recomendado en Aplicaciones)

En tu aplicación cliente, puedes inyectar el repositorio de forma limpia utilizando Riverpod:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

// Proveedor de la API Key
final tmdbApiKeyProvider = Provider<String>((ref) {
  return const String.fromEnvironment('TMDB_API_KEY');
});

// Proveedor del Repositorio
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final apiKey = ref.watch(tmdbApiKeyProvider);
  return MovieRepository.create(apiKey: apiKey);
});

// Proveedor para obtener películas en cartelera
final nowPlayingMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final repository = ref.watch(movieRepositoryProvider);
  final result = await repository.getNowPlaying(page: 1);
  return result.getOrThrow(); // Retorna la lista o lanza el Failure correspondiente
});
```

---

## Pruebas de Unidad

Puedes correr la suite de pruebas unitarias del paquete desde la raíz:

```bash
flutter test
```

---

## Versionamiento Semántico (SemVer)

Este paquete sigue la convención estricta de [Semantic Versioning (SemVer)](https://semver.org/):

* **Versiones de Parche (`1.0.x`)**: Cambios internos que no afectan la API pública (ej. corrección de bugs menores en el formateo de URLs, optimizaciones de código, documentación).
* **Versiones Menores (`1.x.0`)**: Nuevas características hacia atrás compatibles (ej. agregar un nuevo parámetro opcional o exponer un nuevo método del repositorio como películas similares).
* **Versiones Mayores (`x.0.0`)**: Cambios de diseño que rompen la compatibilidad con código anterior (ej. cambiar los nombres de las propiedades de las entidades `Movie` o cambiar la firma de retorno de los métodos).
