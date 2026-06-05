/// Representa un error o excepción que ocurre al interactuar con el cliente de TMDB.
///
/// Todas las fallas del repositorio extienden de esta clase base.
sealed class Failure implements Exception {
  const Failure();

  /// Mensaje descriptivo del error amigable para el usuario final.
  String get userMessage;
}

/// Representa un error de conexión a internet o tiempo de espera agotado.
///
/// ### Ejemplo de uso:
/// ```dart
/// const failure = ConnectionFailure();
/// print(failure.userMessage); // Sin conexión a internet
/// ```
class ConnectionFailure extends Failure {
  final String message;

  const ConnectionFailure([this.message = 'Sin conexión a internet']);

  @override
  String get userMessage => message;
}

/// Representa un error interno del servidor de la API de TMDB (códigos HTTP 5xx o respuestas inesperadas).
///
/// ### Ejemplo de uso:
/// ```dart
/// const failure = ServerFailure('Error del servidor: 503');
/// ```
class ServerFailure extends Failure {
  final String message;

  const ServerFailure([
    this.message = 'Error del servidor. Intenta de nuevo más tarde.',
  ]);

  @override
  String get userMessage => message;
}

/// Representa un error cuando un recurso (por ejemplo, una película o actor) no se encuentra (código HTTP 404).
///
/// ### Ejemplo de uso:
/// ```dart
/// const failure = NotFoundFailure();
/// ```
class NotFoundFailure extends Failure {
  final String message;

  const NotFoundFailure([this.message = 'Recurso no encontrado']);

  @override
  String get userMessage => message;
}

/// Representa un error de autenticación o clave de API inválida/expirada (código HTTP 401).
///
/// ### Ejemplo de uso:
/// ```dart
/// const failure = UnauthorizedFailure();
/// ```
class UnauthorizedFailure extends Failure {
  final String message;

  const UnauthorizedFailure([this.message = 'Sesión expirada']);

  @override
  String get userMessage => message;
}

/// Representa cualquier otro error inesperado o de análisis (parsing) que no encaja en las demás categorías.
///
/// ### Ejemplo de uso:
/// ```dart
/// final failure = UnexpectedFailure('Excepción de formato');
/// ```
class UnexpectedFailure extends Failure {
  final String message;

  const UnexpectedFailure([this.message = 'Error inesperado']);

  @override
  String get userMessage => message;
}
