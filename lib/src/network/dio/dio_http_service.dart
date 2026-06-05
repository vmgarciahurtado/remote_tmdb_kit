import 'package:dio/dio.dart';
import '../../errors/failures.dart';
import '../http_method.dart';
import '../http_service.dart';

/// Implementación concreta de [HttpService] usando el paquete `Dio`.
///
/// Se encarga de mapear las excepciones propias de `DioException` a las fallas
/// del dominio de nuestra librería (`ConnectionFailure`, `ServerFailure`, etc.).
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
        throw const UnexpectedFailure('La respuesta del servidor está vacía.');
      }
      
      return response.data!;
    } on DioException catch (e) {
      throw _mapDioExceptionToFailure(e);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }

  Failure _mapDioExceptionToFailure(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const ConnectionFailure();
    }

    final int? statusCode = e.response?.statusCode;
    if (statusCode == null) {
      return const UnexpectedFailure();
    }

    return switch (statusCode) {
      401 => const UnauthorizedFailure(),
      404 => const NotFoundFailure(),
      _ => ServerFailure('Error del servidor: $statusCode'),
    };
  }
}
