import '../errors/failures.dart';

/// Representa el resultado de una operación que puede tener éxito o fallar.
///
/// Es una clase sellada (sealed) con dos posibles subclases:
/// - [Success] que contiene el valor exitoso del tipo [T].
/// - [FailureResult] que contiene una instancia de [Failure].
///
/// ### Ejemplo de uso con `switch`:
/// ```dart
/// final Result<int> result = ...;
/// switch (result) {
///   case Success(data: final value):
///     print('Éxito: $value');
///   case FailureResult(failure: final error):
///     print('Error: ${error.userMessage}');
/// }
/// ```
sealed class Result<T> {
  const Result();
}

/// Representa un resultado exitoso que contiene datos de tipo [T].
class Success<T> extends Result<T> {
  /// Los datos retornados por la operación exitosa.
  final T data;

  const Success(this.data);
}

/// Representa un resultado fallido que contiene un error de tipo [Failure].
class FailureResult<T> extends Result<T> {
  /// El error que causó la falla de la operación.
  final Failure failure;

  const FailureResult(this.failure);
}

/// Extensión útil para extraer valores o propagar fallas en los resultados de operaciones.
extension ResultX<T> on Result<T> {
  /// Retorna el valor contenido si es un [Success], o lanza el [Failure] correspondiente si es un [FailureResult].
  ///
  /// Útil para propagar errores sin repetir bloques de coincidencia de patrones (pattern matching).
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// try {
  ///   final data = result.getOrThrow();
  /// } on Failure catch (e) {
  ///   // Manejar el error
  /// }
  /// ```
  T getOrThrow() => switch (this) {
    Success<T>(data: final T data) => data,
    FailureResult<T>(failure: final Failure failure) => throw failure,
  };
}
