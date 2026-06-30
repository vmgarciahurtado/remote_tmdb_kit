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
