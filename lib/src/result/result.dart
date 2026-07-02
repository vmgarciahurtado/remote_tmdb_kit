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

  /// Crea un resultado exitoso que envuelve [data].
  const Success(this.data);
}

/// Representa un resultado fallido que contiene un error de tipo [Failure].
class FailureResult<T> extends Result<T> {
  /// El error que causó la falla de la operación.
  final Failure failure;

  /// Crea un resultado fallido que envuelve [failure].
  const FailureResult(this.failure);
}

/// Extensión con utilidades para consumir un [Result] sin repetir bloques
/// de coincidencia de patrones (pattern matching).
extension ResultX<T> on Result<T> {
  /// Indica si este resultado es un [Success].
  bool get isSuccess => this is Success<T>;

  /// Indica si este resultado es un [FailureResult].
  bool get isFailure => this is FailureResult<T>;

  /// Retorna los datos si es un [Success], o `null` si es un
  /// [FailureResult].
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final movies = result.dataOrNull ?? const <Movie>[];
  /// ```
  T? get dataOrNull => switch (this) {
    Success<T>(data: final T data) => data,
    FailureResult<T>() => null,
  };

  /// Retorna la falla si es un [FailureResult], o `null` si es un
  /// [Success].
  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    FailureResult<T>(failure: final Failure failure) => failure,
  };

  /// Retorna el valor contenido si es un [Success], o lanza el [Failure]
  /// correspondiente si es un [FailureResult].
  ///
  /// Útil para propagar errores sin repetir bloques de coincidencia de
  /// patrones (pattern matching).
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

  /// Reduce el resultado a un único valor manejando ambos casos.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final String label = result.fold(
  ///   onSuccess: (movies) => '${movies.length} películas',
  ///   onFailure: (failure) => failure.userMessage,
  /// );
  /// ```
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) => switch (this) {
    Success<T>(data: final T data) => onSuccess(data),
    FailureResult<T>(failure: final Failure failure) => onFailure(failure),
  };

  /// Transforma los datos de un [Success] con [transform], propagando la
  /// falla sin cambios si es un [FailureResult].
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final Result<List<String>> titles =
  ///     result.map((movies) => movies.map((m) => m.title).toList());
  /// ```
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
    Success<T>(data: final T data) => Success<R>(transform(data)),
    FailureResult<T>(failure: final Failure failure) => FailureResult<R>(
      failure,
    ),
  };
}
