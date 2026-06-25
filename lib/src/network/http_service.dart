import 'http_method.dart';

/// Interfaz abstracta para realizar solicitudes HTTP.
///
/// Permite desacoplar la implementación del cliente de red (por ejemplo,
/// `Dio` o `http`) del resto de la lógica de negocio y repositorios del
/// paquete.
abstract interface class HttpService {
  /// Realiza una solicitud HTTP asíncrona a la ruta especificada por [path].
  ///
  /// Requiere un [method] HTTP y opcionalmente permite adjuntar:
  /// - [data]: Datos del cuerpo de la solicitud.
  /// - [queryParameters]: Parámetros de consulta para la URL.
  /// - [headers]: Cabeceras HTTP personalizadas.
  ///
  /// Lanza un error de tipo `Failure` si la llamada falla.
  Future<T> request<T>(
    String path, {
    required HttpMethod method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });
}
