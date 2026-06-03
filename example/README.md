# remote_tmdb_kit Example

Este directorio contiene un ejemplo básico de uso del paquete `remote_tmdb_kit` en Dart puro.

## Ejemplo de Uso

Aquí tienes un ejemplo de cómo instanciar el cliente y consultar películas populares usando el patrón `Result` expuesto por el paquete:

```dart
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

void main() async {
  // 1. Inicializa el repositorio con tu API Key de TMDB
  final repository = MovieRepository.create(
    apiKey: '9b31efe96a35c640012f380f12ee2b86', // Reemplaza con tu clave
    language: 'es-ES', // Opcional (por defecto es 'es-ES')
  );

  // 2. Consulta las películas populares (página 1)
  final Result<List<Movie>> result = await repository.getPopular(page: 1);

  // 3. Maneja los resultados de forma funcional tipada
  switch (result) {
    case Success(data: final movies):
      print('¡Éxito! Se cargaron ${movies.length} películas populares:');
      for (final movie in movies) {
        print('  - ${movie.title} (Puntuación: ${movie.voteAverage})');
      }
      
    case FailureResult(failure: final failure):
      print('Ocurrió un error al consultar la API:');
      print('  - Mensaje amigable: ${failure.userMessage}');
      print('  - Excepción detallada: ${failure.toString()}');
  }
}
```

## Flexibilidad de Cliente (Desacoplamiento)

Si en el futuro deseas cambiar el cliente HTTP por defecto (`Dio`) por otra librería como el paquete nativo `http`, solo necesitas implementar la interfaz `HttpService` y pasarla al constructor `RemoteMovieRepositoryImpl`:

```dart
// 1. Implementa la interfaz del paquete
class MyCustomHttpClient implements HttpService {
  @override
  Future<T> request<T>(
    String path, {
    required HttpMethod method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    // Tu lógica personalizada usando http.Client u otra librería
  }
}

// 2. Inyéctalo manualmente en el repositorio
final customClient = MyCustomHttpClient();
final resolver = ImageUrlResolver(
  imageBaseUrl: 'https://image.tmdb.org/t/p/w500',
  actorImageBaseUrl: 'https://image.tmdb.org/t/p/w185',
  noImageUrl: 'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg',
);

final repository = RemoteMovieRepositoryImpl(customClient, resolver);
```
