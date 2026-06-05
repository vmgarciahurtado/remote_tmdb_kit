import '../dtos/remote_actor_model.dart';
import '../models/actor.dart';
import '../services/image_url_resolver.dart';

/// Mapeador encargado de transformar el DTO de actor de red [RemoteActorModel]
/// a la entidad de dominio limpia [Actor].
class RemoteActorMapper {
  const RemoteActorMapper._();

  /// Convierte una instancia de [RemoteActorModel] en [Actor],
  /// usando [resolver] para resolver la URL completa de la imagen del actor.
  static Actor toEntity(RemoteActorModel model, ImageUrlResolver resolver) =>
      Actor(
        id: model.id,
        name: model.name,
        character: model.character,
        profilePath: resolver.actorImage(model.profilePath),
      );
}
