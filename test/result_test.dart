import 'package:flutter_test/flutter_test.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

void main() {
  group('executeRepositoryCall', () {
    test(
      'given a successful call when executed '
      'then returns the value with no failure',
      () async {
        Future<String> call() async => 'data';

        final Result<String> result = await executeRepositoryCall(call);

        expect(result, isA<Success<String>>());
        expect((result as Success<String>).data, 'data');
      },
    );

    test(
      'given an UnauthorizedFailure when executed '
      'then returns UnauthorizedFailure directly',
      () async {
        Future<String> call() async => throw const UnauthorizedFailure();

        final Result<String> result = await executeRepositoryCall(call);

        expect(result, isA<FailureResult<String>>());
        expect(
          (result as FailureResult<String>).failure,
          isA<UnauthorizedFailure>(),
        );
      },
    );

    test(
      'given a NotFoundFailure when executed '
      'then returns NotFoundFailure directly',
      () async {
        Future<String> call() async => throw const NotFoundFailure();

        final Result<String> result = await executeRepositoryCall(call);

        expect(result, isA<FailureResult<String>>());
        expect(
          (result as FailureResult<String>).failure,
          isA<NotFoundFailure>(),
        );
      },
    );

    test(
      'given a ServerFailure when executed '
      'then returns ServerFailure directly',
      () async {
        Future<String> call() async => throw const ServerFailure();

        final Result<String> result = await executeRepositoryCall(call);

        expect(result, isA<FailureResult<String>>());
        expect((result as FailureResult<String>).failure, isA<ServerFailure>());
      },
    );

    test(
      'given a ConnectionFailure when executed '
      'then returns ConnectionFailure directly',
      () async {
        Future<String> call() async => throw const ConnectionFailure();

        final Result<String> result = await executeRepositoryCall(call);

        expect(result, isA<FailureResult<String>>());
        expect(
          (result as FailureResult<String>).failure,
          isA<ConnectionFailure>(),
        );
      },
    );

    test(
      'given an unknown exception when executed '
      'then returns UnexpectedFailure',
      () async {
        Future<String> call() async => throw Exception('unexpected');

        final Result<String> result = await executeRepositoryCall(call);

        expect(result, isA<FailureResult<String>>());
        expect(
          (result as FailureResult<String>).failure,
          isA<UnexpectedFailure>(),
        );
      },
    );
  });

  group('ResultX.getOrThrow', () {
    test('given a Success when getOrThrow is called then returns the data', () {
      const Result<String> result = Success<String>('hello');
      expect(result.getOrThrow(), 'hello');
    });

    test('given a FailureResult when getOrThrow is called then throws the failure', () {
      const Result<String> result = FailureResult<String>(ConnectionFailure());
      expect(() => result.getOrThrow(), throwsA(isA<ConnectionFailure>()));
    });
  });
}
