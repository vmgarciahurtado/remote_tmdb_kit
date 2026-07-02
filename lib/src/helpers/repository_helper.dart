import '../errors/failures.dart';
import '../result/result.dart';

/// Envuelve la ejecución de una llamada asíncrona de repositorio y
/// captura cualquier excepción.
///
/// Si la llamada arroja una instancia conocida de [Failure], la retorna
/// directamente envuelta en un [FailureResult]. Cualquier otra excepción
/// desconocida se captura y se envuelve en un [UnexpectedFailure].
///
/// Este helper es de uso interno del repositorio para estandarizar el
/// retorno de [Result].
Future<Result<T>> executeRepositoryCall<T>(Future<T> Function() call) async {
  try {
    final T data = await call();
    return Success<T>(data);
  } on Failure catch (e) {
    return FailureResult<T>(e);
  } catch (e, stackTrace) {
    return FailureResult<T>(
      UnexpectedFailure(
        message: e.toString(),
        cause: e,
        stackTrace: stackTrace,
      ),
    );
  }
}
