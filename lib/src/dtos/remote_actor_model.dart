/// DTO de deserialización para actores individuales desde la respuesta JSON de TMDB.
class RemoteActorModel {
  const RemoteActorModel({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
  });

  factory RemoteActorModel.fromJson(Map<String, dynamic> json) =>
      RemoteActorModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        character: json['character'] as String? ?? '',
        profilePath: json['profile_path'] as String?,
      );

  final int id;
  final String name;
  final String character;
  final String? profilePath;
}
