/// Servicio encargado de resolver y construir las URLs absolutas de las
/// imágenes de TMDB.
///
/// Como TMDB retorna rutas relativas en sus respuestas de JSON, esta clase
/// se encarga de concatenarlas con el URL base configurado. Cuando la ruta
/// no existe retorna `null`: la imagen de reemplazo (placeholder) es una
/// decisión de interfaz que corresponde a la aplicación consumidora.
class ImageUrlResolver {
  /// Crea una instancia del resolutor de URLs de imágenes.
  const ImageUrlResolver({
    required this.imageBaseUrl,
    required this.actorImageBaseUrl,
  });

  /// URL base para obtener imágenes de películas (pósteres y fondos).
  final String imageBaseUrl;

  /// URL base para obtener fotos de perfil de actores.
  final String actorImageBaseUrl;

  /// Resuelve la URL completa para un póster o fondo de película.
  ///
  /// Si [path] es `null` o está vacío, retorna `null`.
  String? movieImage(String? path) =>
      (path == null || path.isEmpty) ? null : '$imageBaseUrl$path';

  /// Resuelve la URL completa para el perfil de un actor.
  ///
  /// Si [path] es `null` o está vacío, retorna `null`.
  String? actorImage(String? path) =>
      (path == null || path.isEmpty) ? null : '$actorImageBaseUrl$path';
}
