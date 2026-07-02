import 'package:dio/dio.dart';
import '../../errors/failures.dart';
import '../http_method.dart';
import '../http_service.dart';

/// Implementación concreta de [HttpService] usando el paquete `Dio`.
///
/// Se encarga de mapear las excepciones propias de `DioException` a las
/// fallas del dominio de nuestra librería (`ConnectionFailure`,
/// `ServerFailure`, etc.), conservando el error original y su traza de
/// pila para facilitar la depuración.
class DioHttpService implements HttpService {
  final Dio _dio;

  /// Crea una instancia de [DioHttpService] inyectando un objeto [Dio].
  const DioHttpService(this._dio);

  @override
  Future<T> request<T>(
    String path, {
    required HttpMethod method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final Response<T> response = await _dio.request<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method.name.toUpperCase(),
          headers: headers,
        ),
      );

      if (response.data == null) {
        throw const UnexpectedFailure(
          message: 'La respuesta del servidor está vacía.',
        );
      }

      return response.data!;
    } on Failure {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _mapDioExceptionToFailure(e, stackTrace);
    } catch (e, stackTrace) {
      throw UnexpectedFailure(
        message: e.toString(),
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Failure _mapDioExceptionToFailure(DioException e, StackTrace stackTrace) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return ConnectionFailure(cause: e, stackTrace: stackTrace);
    }

    final int? statusCode = e.response?.statusCode;
    if (statusCode == null) {
      return UnexpectedFailure(cause: e, stackTrace: stackTrace);
    }

    return switch (statusCode) {
      401 => UnauthorizedFailure(cause: e, stackTrace: stackTrace),
      404 => NotFoundFailure(cause: e, stackTrace: stackTrace),
      429 => RateLimitFailure(cause: e, stackTrace: stackTrace),
      _ => ServerFailure(
        message: 'Error del servidor: $statusCode',
        statusCode: statusCode,
        cause: e,
        stackTrace: stackTrace,
      ),
    };
  }
}
