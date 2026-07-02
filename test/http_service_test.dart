import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';
import 'package:remote_tmdb_kit/src/network/dio/dio_http_service.dart';
import 'package:remote_tmdb_kit/src/network/dio/logging_interceptor.dart';
import 'package:test/test.dart';

// Fake implementations for Interceptor Handlers using noSuchMethod fallback
class FakeRequestInterceptorHandler implements RequestInterceptorHandler {
  RequestOptions? nextOptions;

  @override
  void next(RequestOptions options) {
    nextOptions = options;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeResponseInterceptorHandler implements ResponseInterceptorHandler {
  Response<dynamic>? nextResponse;

  @override
  void next(Response<dynamic> response) {
    nextResponse = response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeErrorInterceptorHandler implements ErrorInterceptorHandler {
  DioException? nextError;

  @override
  void next(DioException err) {
    nextError = err;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// Fake HttpClientAdapter to mock raw Dio requests
class FakeHttpClientAdapter implements HttpClientAdapter {
  late ResponseBody responseBody;
  DioException? exceptionToThrow;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return responseBody;
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('LoggingInterceptor', () {
    late List<String> logLines;
    late LoggingInterceptor interceptor;

    setUp(() {
      logLines = <String>[];
      interceptor = LoggingInterceptor(logLines.add);
    });

    test('given an outgoing request without body '
        'when onRequest is called '
        'then the request is forwarded via handler.next', () {
      final RequestOptions options = RequestOptions(
        path: '/test',
        method: 'GET',
      );
      final FakeRequestInterceptorHandler handler =
          FakeRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      expect(handler.nextOptions, options);
      expect(logLines, isNotEmpty);
    });

    test('given an outgoing request with a body '
        'when onRequest is called '
        'then the body is logged and the request is forwarded', () {
      final RequestOptions options = RequestOptions(
        path: '/test',
        method: 'POST',
        data: <String, String>{'key': 'value'},
      );
      final FakeRequestInterceptorHandler handler =
          FakeRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      expect(handler.nextOptions, options);
      expect(logLines.join('\n'), contains('value'));
    });

    test('given a request with an api_key query parameter '
        'when onRequest is called '
        'then the api key is redacted from the logs', () {
      final RequestOptions options = RequestOptions(
        path: 'https://api.themoviedb.org/3/movie/popular',
        method: 'GET',
        queryParameters: <String, dynamic>{'api_key': 'super_secret_key'},
      );
      final FakeRequestInterceptorHandler handler =
          FakeRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      final String logged = logLines.join('\n');
      expect(logged, isNot(contains('super_secret_key')));
      expect(logged, contains('api_key=REDACTED'));
    });

    test('given a request with an Authorization header '
        'when onRequest is called '
        'then the bearer token is redacted from the logs', () {
      final RequestOptions options = RequestOptions(
        path: '/test',
        method: 'GET',
        headers: <String, dynamic>{'Authorization': 'Bearer secret_token'},
      );
      final FakeRequestInterceptorHandler handler =
          FakeRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      final String logged = logLines.join('\n');
      expect(logged, isNot(contains('secret_token')));
    });

    test('given an incoming response '
        'when onResponse is called '
        'then the response is forwarded via handler.next', () {
      final RequestOptions options = RequestOptions(path: '/test');
      final Response<dynamic> response = Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: <String, String>{'result': 'ok'},
      );
      final FakeResponseInterceptorHandler handler =
          FakeResponseInterceptorHandler();

      interceptor.onResponse(response, handler);

      expect(handler.nextResponse, response);
      expect(logLines.join('\n'), contains('200'));
    });

    test('given a request error without response data '
        'when onError is called '
        'then the error is forwarded via handler.next', () {
      final RequestOptions options = RequestOptions(path: '/test');
      final DioException error = DioException(
        requestOptions: options,
        response: Response<dynamic>(requestOptions: options, statusCode: 500),
      );
      final FakeErrorInterceptorHandler handler = FakeErrorInterceptorHandler();

      interceptor.onError(error, handler);

      expect(handler.nextError, error);
    });

    test('given a request error with response data '
        'when onError is called '
        'then the error data is logged and the error is forwarded', () {
      final RequestOptions options = RequestOptions(path: '/test');
      final DioException error = DioException(
        requestOptions: options,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: 500,
          data: <String, String>{'error': 'Internal Server Error'},
        ),
      );
      final FakeErrorInterceptorHandler handler = FakeErrorInterceptorHandler();

      interceptor.onError(error, handler);

      expect(handler.nextError, error);
      expect(logLines.join('\n'), contains('Internal Server Error'));
    });
  });

  group('DioHttpService', () {
    late Dio dio;
    late FakeHttpClientAdapter adapter;
    late DioHttpService service;

    setUp(() {
      dio = Dio();
      adapter = FakeHttpClientAdapter();
      dio.httpClientAdapter = adapter;
      service = DioHttpService(dio);
    });

    test('given a successful request '
        'when request is called '
        'then returns the expected response', () async {
      final Map<String, dynamic> responseMap = <String, dynamic>{
        'key': 'value',
      };
      adapter.responseBody = ResponseBody.fromString(
        jsonEncode(responseMap),
        200,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>[Headers.jsonContentType],
        },
      );

      final Map<String, dynamic> result = await service
          .request<Map<String, dynamic>>('/test', method: HttpMethod.get);

      expect(result, responseMap);
    });

    test('given a 401 response '
        'when request is called '
        'then throws UnauthorizedFailure', () async {
      adapter.responseBody = ResponseBody.fromString('', 401);

      expect(
        () => service.request<dynamic>('/test', method: HttpMethod.get),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test('given a 404 response '
        'when request is called '
        'then throws NotFoundFailure', () async {
      adapter.responseBody = ResponseBody.fromString('', 404);

      expect(
        () => service.request<dynamic>('/test', method: HttpMethod.get),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('given a 429 response '
        'when request is called '
        'then throws RateLimitFailure', () async {
      adapter.responseBody = ResponseBody.fromString('', 429);

      expect(
        () => service.request<dynamic>('/test', method: HttpMethod.get),
        throwsA(isA<RateLimitFailure>()),
      );
    });

    test('given a 500 response '
        'when request is called '
        'then throws ServerFailure with the typed status code', () async {
      adapter.responseBody = ResponseBody.fromString('', 500);

      expect(
        () => service.request<dynamic>('/test', method: HttpMethod.get),
        throwsA(
          isA<ServerFailure>().having(
            (ServerFailure f) => f.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });

    test('given a Connection Timeout error '
        'when request is called '
        'then throws ConnectionFailure preserving the cause', () async {
      adapter.exceptionToThrow = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        () => service.request<dynamic>('/test', method: HttpMethod.get),
        throwsA(
          isA<ConnectionFailure>().having(
            (ConnectionFailure f) => f.cause,
            'cause',
            isA<DioException>(),
          ),
        ),
      );
    });

    test('given an unknown exception '
        'when request is called '
        'then throws UnexpectedFailure', () async {
      adapter.exceptionToThrow = DioException(
        requestOptions: RequestOptions(path: '/test'),
        error: Exception('other'),
      );

      expect(
        () => service.request<dynamic>('/test', method: HttpMethod.get),
        throwsA(isA<UnexpectedFailure>()),
      );
    });
  });
}
