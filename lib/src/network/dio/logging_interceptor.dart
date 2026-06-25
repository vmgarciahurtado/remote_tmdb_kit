import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor de `Dio` encargado de registrar logs detallados de red en
/// consola.
///
/// Solo realiza impresiones en consola si la aplicación se ejecuta en
/// modo de depuración (`kDebugMode`).
class LoggingInterceptor extends Interceptor {
  /// Crea una instancia del interceptor de logs.
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
