/// Modelo de dominio que representa a un actor o miembro del reparto de una película.
class Actor {
  /// Crea una instancia inmutable de [Actor].
  const Actor({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
  });

  /// Identificador único del actor en la base de datos de TMDB.
  final int id;

  /// Nombre real o artístico del actor.
  final String name;

  /// Nombre del personaje que interpreta el actor en la película.
  final String character;

  /// URL completa de la foto de perfil del actor.
  ///
  /// Puede ser `null` si TMDB no provee una imagen para este actor.
  final String? profilePath;
}
