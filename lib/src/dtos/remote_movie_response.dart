// DTO interno del paquete (no exportado); sus miembros replican 1:1 el
// contrato JSON de TMDB y no forman parte de la API pública documentada.
// ignore_for_file: public_member_api_docs

import 'remote_movie_model.dart';

/// DTO de respuesta paginada para listas de películas
/// (ej. popular, cartelera, búsqueda).
class RemoteMovieResponse {
  const RemoteMovieResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory RemoteMovieResponse.fromJson(Map<String, dynamic> json) =>
      RemoteMovieResponse(
        page: (json['page'] as num).toInt(),
        results:
            (json['results'] as List<dynamic>?)
                ?.map(
                  (dynamic e) =>
                      RemoteMovieModel.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            <RemoteMovieModel>[],
        totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
        totalResults: (json['total_results'] as num?)?.toInt() ?? 0,
      );

  final int page;
  final List<RemoteMovieModel> results;
  final int totalPages;
  final int totalResults;
}
