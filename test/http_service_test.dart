import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';
import 'package:remote_tmdb_kit/src/network/http_service.dart';
import 'package:remote_tmdb_kit/src/network/dio/dio_http_service.dart';
import 'package:remote_tmdb_kit/src/network/dio/logging_interceptor.dart';
import 'package:remote_tmdb_kit/src/network/http_method.dart';

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
  Response? nextResponse;

  @override
  void next(Response response) {
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
    late LoggingInterceptor interceptor;

    setUp(() {
      interceptor = LoggingInterceptor();
    });

    test(
      'given an outgoing request without body '
      'when onRequest is called '
      'then the request is forwarded via handler.next',
      () {
        final RequestOptions options = RequestOptions(
          path: '/test',
          method: 'GET',
        );
        final FakeRequestInterceptorHandler handler =
            FakeRequestInterceptorHandler();

        interceptor.onRequest(options, handler);

        expect(handler.nextOptions, options);
      },
    );

    test(
      'given an outgoing request with a body '
      'when onRequest is called '
      'then the body is logged and the request is forwarded',
      () {
        final RequestOptions options = RequestOptions(
          path: '/test',
          method: 'POST',
          data: <String, String>{'key': 'value'},
        );
        final FakeRequestInterceptorHandler handler =
            FakeRequestInterceptorHandler();

        interceptor.onRequest(options, handler);

        expect(handler.nextOptions, options);
      },
    );

    test(
      'given an incoming response '
      'when onResponse is called '
      'then the response is forwarded via handler.next',
      () {
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
      },
    );

    test(
      'given a request error without response data '
      'when onError is called '
      'then the error is forwarded via handler.next',
      () {
        final RequestOptions options = RequestOptions(path: '/test');
        final DioException error = DioException(
          requestOptions: options,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: 500,
          ),
        );
        final FakeErrorInterceptorHandler handler =
            FakeErrorInterceptorHandler();

        interceptor.onError(error, handler);

        expect(handler.nextError, error);
      },
    );

    test(
      'given a request error with response data '
      'when onError is called '
      'then the error data is logged and the error is forwarded',
      () {
        final RequestOptions options = RequestOptions(path: '/test');
        final DioException error = DioException(
          requestOptions: options,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: 500,
            data: <String, String>{'error': 'Internal Server Error'},
          ),
        );
        final FakeErrorInterceptorHandler handler =
            FakeErrorInterceptorHandler();

        interceptor.onError(error, handler);

        expect(handler.nextError, error);
      },
    );
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

    test(
      'given a successful request '
      'when request is called '
      'then returns the expected response',
      () async {
        final Map<String, dynamic> responseMap = <String, dynamic>{'key': 'value'};
        adapter.responseBody = ResponseBody.fromString(
          jsonEncode(responseMap),
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>[Headers.jsonContentType],
          },
        );

        final Map<String, dynamic> result =
            await service.request<Map<String, dynamic>>(
          '/test',
          method: HttpMethod.get,
        );

        expect(result, responseMap);
      },
    );

    test(
      'given a 401 response '
      'when request is called '
      'then throws UnauthorizedFailure',
      () async {
        adapter.responseBody = ResponseBody.fromString('', 401);

        expect(
          () => service.request<dynamic>('/test', method: HttpMethod.get),
          throwsA(isA<UnauthorizedFailure>()),
        );
      },
    );

    test(
      'given a 404 response '
      'when request is called '
      'then throws NotFoundFailure',
      () async {
        adapter.responseBody = ResponseBody.fromString('', 404);

        expect(
          () => service.request<dynamic>('/test', method: HttpMethod.get),
          throwsA(isA<NotFoundFailure>()),
        );
      },
    );

    test(
      'given a 500 response '
      'when request is called '
      'then throws ServerFailure',
      () async {
        adapter.responseBody = ResponseBody.fromString('', 500);

        expect(
          () => service.request<dynamic>('/test', method: HttpMethod.get),
          throwsA(isA<ServerFailure>()),
        );
      },
    );

    test(
      'given a Connection Timeout error '
      'when request is called '
      'then throws ConnectionFailure',
      () async {
        adapter.exceptionToThrow = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );

        expect(
          () => service.request<dynamic>('/test', method: HttpMethod.get),
          throwsA(isA<ConnectionFailure>()),
        );
      },
    );

    test(
      'given an unknown exception '
      'when request is called '
      'then throws UnexpectedFailure',
      () async {
        adapter.exceptionToThrow = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.unknown,
          error: Exception('other'),
        );

        expect(
          () => service.request<dynamic>('/test', method: HttpMethod.get),
          throwsA(isA<UnexpectedFailure>()),
        );
      },
    );
  });
}
