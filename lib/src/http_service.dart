import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'failures.dart';

enum HttpMethod { get, post, put, delete, patch }

abstract interface class HttpService {
  Future<T> request<T>(
    String path, {
    required HttpMethod method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });
}

class DioHttpService implements HttpService {
  final Dio _dio;
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

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────────────');
      debugPrint('│ REQUEST');
      debugPrint('├─────────────────────────────────────────────────');
      debugPrint('│ ${options.method} ${options.uri}');
      debugPrint('│ Headers: ${options.headers}');
      if (options.data != null) {
        debugPrint('│ Body: ${options.data}');
      }
      debugPrint('└─────────────────────────────────────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────────────');
      debugPrint('│ RESPONSE');
      debugPrint('├─────────────────────────────────────────────────');
      debugPrint(
        '│ ${response.requestOptions.method} ${response.requestOptions.uri}',
      );
      debugPrint('│ Status: ${response.statusCode}');
      debugPrint('│ Data: ${response.data}');
      debugPrint('└─────────────────────────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────────────');
      debugPrint('│ ERROR');
      debugPrint('├─────────────────────────────────────────────────');
      debugPrint('│ ${err.requestOptions.method} ${err.requestOptions.uri}');
      debugPrint('│ Status: ${err.response?.statusCode}');
      debugPrint('│ Error: ${err.message}');
      if (err.response?.data != null) {
        debugPrint('│ Data: ${err.response?.data}');
      }
      debugPrint('└─────────────────────────────────────────────────');
    }
    handler.next(err);
  }
}
