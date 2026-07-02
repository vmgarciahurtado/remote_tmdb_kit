import 'package:dio/dio.dart';

/// Interceptor de `Dio` encargado de registrar logs detallados de red.
///
/// Antes de emitir cada línea redacta las credenciales sensibles: el
/// parámetro de consulta `api_key` y la cabecera `Authorization` se
/// enmascaran para que la clave nunca quede expuesta en los logs.
///
/// Las líneas se emiten a través de la función [log] inyectada, de modo
/// que el paquete no depende de Flutter ni decide el destino de los logs.
class LoggingInterceptor extends Interceptor {
  /// Crea el interceptor con la función [log] que recibirá cada línea.
  LoggingInterceptor(this.log);

  /// Función destino de cada línea de log.
  final void Function(String message) log;

  // Sin caracteres que Uri.replace percent-encodee, para que la máscara
  // se lea tal cual en la URL registrada.
  static const String _mask = 'REDACTED';
  static const String _divider =
      '─────────────────────────────────────────────';

  Uri _redactUri(Uri uri) {
    if (!uri.queryParameters.containsKey('api_key')) {
      return uri;
    }
    return uri.replace(
      queryParameters: <String, String>{
        ...uri.queryParameters,
        'api_key': _mask,
      },
    );
  }

  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    return <String, dynamic>{
      for (final MapEntry<String, dynamic> entry in headers.entries)
        entry.key: entry.key.toLowerCase() == 'authorization'
            ? _mask
            : entry.value,
    };
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('┌$_divider');
    log('│ REQUEST');
    log('├$_divider');
    log('│ ${options.method} ${_redactUri(options.uri)}');
    log('│ Headers: ${_redactHeaders(options.headers)}');
    if (options.data != null) {
      log('│ Body: ${options.data}');
    }
    log('└$_divider');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    log('┌$_divider');
    log('│ RESPONSE');
    log('├$_divider');
    log(
      '│ ${response.requestOptions.method} '
      '${_redactUri(response.requestOptions.uri)}',
    );
    log('│ Status: ${response.statusCode}');
    log('│ Data: ${response.data}');
    log('└$_divider');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('┌$_divider');
    log('│ ERROR');
    log('├$_divider');
    log(
      '│ ${err.requestOptions.method} '
      '${_redactUri(err.requestOptions.uri)}',
    );
    log('│ Status: ${err.response?.statusCode}');
    log('│ Error: ${err.message}');
    if (err.response?.data != null) {
      log('│ Data: ${err.response?.data}');
    }
    log('└$_divider');
    handler.next(err);
  }
}
