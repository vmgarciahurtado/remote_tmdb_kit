/// Página de resultados devuelta por los endpoints paginados de TMDB.
///
/// Además de los elementos de la página actual ([results]), conserva los
/// metadatos de paginación que expone la API ([page], [totalPages] y
/// [totalResults]), necesarios para implementar scroll infinito o
/// controles de paginación sin adivinar cuándo detenerse.
///
/// ### Ejemplo de uso:
/// ```dart
/// final result = await repository.getPopular(page: page);
/// if (result case Success(data: final paged)) {
///   movies.addAll(paged.results);
///   if (paged.hasNextPage) {
///     page++;
///   }
/// }
/// ```
class PagedResult<T> {
  /// Crea una página inmutable de resultados.
  const PagedResult({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  /// Número de la página actual (empezando en 1).
  final int page;

  /// Elementos contenidos en la página actual.
  final List<T> results;

  /// Cantidad total de páginas disponibles en la API.
  final int totalPages;

  /// Cantidad total de resultados disponibles en la API.
  final int totalResults;

  /// Indica si existe una página posterior a la actual.
  bool get hasNextPage => page < totalPages;
}
