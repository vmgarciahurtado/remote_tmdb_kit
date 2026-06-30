import 'remote_actor_model.dart';

/// DTO de respuesta para el reparto/créditos de una película en TMDB.
class RemoteCastResponse {
  const RemoteCastResponse({
    required this.id,
    required this.cast,
  });

  factory RemoteCastResponse.fromJson(Map<String, dynamic> json) =>
      RemoteCastResponse(
        id: (json['id'] as num).toInt(),
        cast:
            (json['cast'] as List<dynamic>?)
                ?.map(
                  (dynamic e) =>
                      RemoteActorModel.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            <RemoteActorModel>[],
      );

  final int id;
  final List<RemoteActorModel> cast;
}
