/// Modelo de dominio que representa a un actor o miembro del reparto de
/// una película.
///
/// Implementa igualdad estructural: dos instancias con los mismos valores
/// son iguales, lo que facilita comparaciones en gestores de estado y tests.
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Actor &&
        other.id == id &&
        other.name == name &&
        other.character == character &&
        other.profilePath == profilePath;
  }

  @override
  int get hashCode => Object.hash(id, name, character, profilePath);

  @override
  String toString() => 'Actor(id: $id, name: $name)';
}
