/// Representa un error o excepción que ocurre al interactuar con el
/// cliente de TMDB.
///
/// Todas las fallas del repositorio extienden de esta clase base. Además
/// del mensaje amigable para el usuario, cada falla puede transportar el
/// error original ([cause]) y su traza de pila ([stackTrace]) para
/// facilitar el diagnóstico en producción sin perder contexto.
sealed class Failure implements Exception {
  /// Crea una falla con un [message] amigable y contexto opcional de
  /// depuración ([cause] y [stackTrace]).
  const Failure({required this.message, this.cause, this.stackTrace});

  /// Mensaje descriptivo del error amigable para el usuario final.
  final String message;

  /// Error original que provocó esta falla, si existe.
  ///
  /// Útil para registrar el detalle técnico en un sistema de logs sin
  /// exponerlo al usuario final.
  final Object? cause;

  /// Traza de pila capturada junto al error original, si existe.
  final StackTrace? stackTrace;

  /// Mensaje descriptivo del error amigable para el usuario final.
  ///
  /// Es un alias de [message].
  String get userMessage => message;

  @override
  String toString() {
    // runtimeType solo se usa con fines de depuración; en builds web
    // minificados el nombre puede aparecer ofuscado.
    // ignore: avoid_type_to_string
    final String type = runtimeType.toString();
    return cause == null
        ? '$type: $message'
        : '$type: $message (causa: $cause)';
  }
}

/// Representa un error de conexión a internet o tiempo de espera agotado.
///
/// ### Ejemplo de uso:
/// ```dart
/// const failure = ConnectionFailure();
/// print(failure.userMessage); // Sin conexión a internet
/// ```
class ConnectionFailure extends Failure {
  /// Crea una falla de conexión con un [message] opcional.
  const ConnectionFailure({
    super.message = 'Sin conexión a internet',
    super.cause,
    super.stackTrace,
  });
}

/// Representa un error interno del servidor de la API de TMDB
/// (códigos HTTP 5xx o respuestas inesperadas).
///
/// Expone el [statusCode] HTTP recibido (si existe) como campo tipado.
///
/// ### Ejemplo de uso:
/// ```dart
/// const failure = ServerFailure(statusCode: 503);
/// print(failure.statusCode); // 503
/// ```
class ServerFailure extends Failure {
  /// Crea una falla de servidor con un [message] y [statusCode] opcionales.
  const ServerFailure({
    super.message = 'Error del servidor. Intenta de nuevo más tarde.',
    this.statusCode,
    super.cause,
    super.stackTrace,
  });

  /// Código de estado HTTP devuelto por el servidor, si se conoce.
  final int? statusCode;
}

/// Representa un error cuando un recurso (por ejemplo, una película o
/// actor) no se encuentra (código HTTP 404).
///
/// ### Ejemplo de uso:
/// ```dart
/// const failure = NotFoundFailure();
/// ```
class NotFoundFailure extends Failure {
  /// Crea una falla de recurso no encontrado con un [message] opcional.
  const NotFoundFailure({
    super.message = 'Recurso no encontrado',
    super.cause,
    super.stackTrace,
  });
}

/// Representa un error de autenticación o clave de API inválida/expirada
/// (código HTTP 401).
///
/// ### Ejemplo de uso:
/// ```dart
/// const failure = UnauthorizedFailure();
/// ```
class UnauthorizedFailure extends Failure {
  /// Crea una falla de autenticación con un [message] opcional.
  const UnauthorizedFailure({
    super.message = 'Sesión expirada',
    super.cause,
    super.stackTrace,
  });
}

/// Representa el límite de peticiones alcanzado en la API de TMDB
/// (código HTTP 429).
///
/// TMDB aplica límites de velocidad por IP; al recibir esta falla lo
/// recomendable es esperar unos segundos antes de reintentar.
///
/// ### Ejemplo de uso:
/// ```dart
/// const failure = RateLimitFailure();
/// ```
class RateLimitFailure extends Failure {
  /// Crea una falla de límite de peticiones con un [message] opcional.
  const RateLimitFailure({
    super.message =
        'Demasiadas solicitudes. Intenta de nuevo en unos '
        'segundos.',
    super.cause,
    super.stackTrace,
  });
}

/// Representa cualquier otro error inesperado o de análisis (parsing)
/// que no encaja en las demás categorías.
///
/// ### Ejemplo de uso:
/// ```dart
/// final failure = UnexpectedFailure(message: 'Excepción de formato');
/// ```
class UnexpectedFailure extends Failure {
  /// Crea una falla inesperada con un [message] opcional.
  const UnexpectedFailure({
    super.message = 'Error inesperado',
    super.cause,
    super.stackTrace,
  });
}
