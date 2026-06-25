/// Servicio encargado de resolver y construir las URLs absolutas de las
/// imágenes de TMDB.
///
/// Como TMDB retorna rutas relativas en sus respuestas de JSON, esta clase
/// se encarga de concatenarlas con el URL base configurado, o de proveer
/// una URL de fallback por defecto cuando no hay imagen disponible.
class ImageUrlResolver {
  /// Crea una instancia del resolutor de URLs de imágenes.
  const ImageUrlResolver({
    required this.imageBaseUrl,
    required this.actorImageBaseUrl,
    required this.noImageUrl,
  });

  /// URL base para obtener imágenes de películas (pósteres y fondos).
  final String imageBaseUrl;

  /// URL base para obtener fotos de perfil de actores.
  final String actorImageBaseUrl;

  /// URL de fallback que se retornará cuando una película no disponga de
  /// póster o fondo.
  final String noImageUrl;

  /// Resuelve la URL completa para un póster o fondo de película.
  ///
  /// Si el parámetro [path] está vacío o no es válido, retorna la URL
  /// [noImageUrl].
  String movieImage(String path) =>
      path.isNotEmpty ? '$imageBaseUrl$path' : noImageUrl;

  /// Resuelve la URL completa para el perfil de un actor.
  ///
  /// Si el parámetro [path] es nulo, retorna `null`.
  String? actorImage(String? path) =>
      path != null ? '$actorImageBaseUrl$path' : null;
}
