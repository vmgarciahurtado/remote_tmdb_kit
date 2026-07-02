# Ejemplo de remote_tmdb_kit

App Flutter funcional que **consume el paquete [`remote_tmdb_kit`](../)** para explorar
películas de TMDB. Demuestra el objetivo del paquete: toda la capa de datos (cliente HTTP,
mapeo de DTOs, manejo de errores) vive dentro del paquete, y esta app solo aporta la
interfaz de usuario y el cableado de dependencias.

## Qué demuestra

* **Estrenos en cartelera** (`getNowPlaying`) en un carrusel superior.
* **Tendencias / populares** (`getPopular`) en un listado horizontal.
* **Búsqueda de películas** con *debounce* (`searchMovies`) desde la barra de búsqueda.
* **Detalle de película** con su reparto (`getMovieCast`).
* **Manejo de errores tipado**: los estados de error muestran `failure.userMessage`
  proveniente del paquete.

Todo el acceso a datos pasa por un único punto:
[`movie_repository_provider.dart`](lib/features/movies/presentation/providers/movie_repository_provider.dart),
que crea el repositorio del paquete con
`createTmdbMovieRepository(TmdbConfig(apiKey: Env.apiKey))`.

## Requisitos

* Flutter (SDK Dart `^3.11.5`).
* Una **API key de TMDB**. Puedes obtenerla gratis en
  [themoviedb.org](https://www.themoviedb.org/settings/api).

## Configuración

1. Copia el archivo de variables de entorno de ejemplo:

   ```bash
   cp .env.example .env
   ```

2. Edita `.env` y coloca tu clave:

   ```env
   API_KEY=tu_api_key_de_tmdb
   ```

3. Descarga las dependencias:

   ```bash
   flutter pub get
   ```

## Ejecución

```bash
flutter run
```

> La API key se carga en tiempo de ejecución desde `.env` mediante
> [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv).

## Cómo se consume el paquete

El ejemplo usa Riverpod para inyectar el repositorio del paquete y exponerlo a la UI:

```dart
// movie_repository_provider.dart
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return createTmdbMovieRepository(TmdbConfig(apiKey: Env.apiKey));
});

// popular_movies_provider.dart
final popularMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final repository = ref.watch(movieRepositoryProvider);
  final result = await repository.getPopular();
  return switch (result) {
    Success(data: final paged) => paged.results,
    FailureResult(failure: final failure) => throw failure,
  };
});
```

Los tipos `Movie`, `Actor`, `Result` y `Failure` que usan los widgets provienen
directamente de `package:remote_tmdb_kit/remote_tmdb_kit.dart`.

### ¿Y si no quieres usar TMDB?

`MovieRepository` es una interfaz: este ejemplo usa la implementación de TMDB
(`createTmdbMovieRepository`), pero podrías inyectar tu propia clase que implemente
`MovieRepository` (BD local, caché, JSON...) cambiando solo este provider; el
resto de la app no se entera. Mira el apartado «¿Tienes otra fuente de datos?»
del README del paquete.

## Estructura

```
lib/
├── core/
│   ├── constants/        # rutas y carga de la API key (Env)
│   └── theme/            # tema claro/oscuro
└── features/movies/presentation/
    ├── delegates/        # búsqueda (SearchDelegate)
    ├── pages/            # HomePage, MovieDetailPage
    ├── providers/        # providers de Riverpod que consumen el paquete
    └── widgets/          # tarjetas, carrusel, listas, etc.
```

> No hay carpeta `infrastructure/` ni `domain/`: esa lógica fue extraída al paquete
> `remote_tmdb_kit`.
