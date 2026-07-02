import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';
import 'package:remote_tmdb_kit/src/helpers/repository_helper.dart';
import 'package:test/test.dart';

void main() {
  group('executeRepositoryCall', () {
    test('given a successful call when executed '
        'then returns the value with no failure', () async {
      Future<String> call() async => 'data';

      final Result<String> result = await executeRepositoryCall(call);

      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, 'data');
    });

    test('given an UnauthorizedFailure when executed '
        'then returns UnauthorizedFailure directly', () async {
      Future<String> call() async => throw const UnauthorizedFailure();

      final Result<String> result = await executeRepositoryCall(call);

      expect(result, isA<FailureResult<String>>());
      expect(
        (result as FailureResult<String>).failure,
        isA<UnauthorizedFailure>(),
      );
    });

    test('given a NotFoundFailure when executed '
        'then returns NotFoundFailure directly', () async {
      Future<String> call() async => throw const NotFoundFailure();

      final Result<String> result = await executeRepositoryCall(call);

      expect(result, isA<FailureResult<String>>());
      expect((result as FailureResult<String>).failure, isA<NotFoundFailure>());
    });

    test('given a ServerFailure when executed '
        'then returns ServerFailure directly', () async {
      Future<String> call() async => throw const ServerFailure();

      final Result<String> result = await executeRepositoryCall(call);

      expect(result, isA<FailureResult<String>>());
      expect((result as FailureResult<String>).failure, isA<ServerFailure>());
    });

    test('given a ConnectionFailure when executed '
        'then returns ConnectionFailure directly', () async {
      Future<String> call() async => throw const ConnectionFailure();

      final Result<String> result = await executeRepositoryCall(call);

      expect(result, isA<FailureResult<String>>());
      expect(
        (result as FailureResult<String>).failure,
        isA<ConnectionFailure>(),
      );
    });

    test('given an unknown exception when executed '
        'then returns UnexpectedFailure preserving the cause', () async {
      final Exception original = Exception('unexpected');
      Future<String> call() async => throw original;

      final Result<String> result = await executeRepositoryCall(call);

      expect(result, isA<FailureResult<String>>());
      final Failure failure = (result as FailureResult<String>).failure;
      expect(failure, isA<UnexpectedFailure>());
      expect(failure.cause, same(original));
      expect(failure.stackTrace, isNotNull);
    });
  });

  group('ResultX.getOrThrow', () {
    test('given a Success when getOrThrow is called then returns the data', () {
      const Result<String> result = Success<String>('hello');
      expect(result.getOrThrow(), 'hello');
    });

    test(
      'given a FailureResult when getOrThrow is called then throws the failure',
      () {
        const Result<String> result = FailureResult<String>(
          ConnectionFailure(),
        );
        expect(() => result.getOrThrow(), throwsA(isA<ConnectionFailure>()));
      },
    );
  });

  group('ResultX helpers', () {
    const Result<int> success = Success<int>(42);
    const Result<int> failure = FailureResult<int>(NotFoundFailure());

    test('isSuccess / isFailure reflect the variant', () {
      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
      expect(failure.isSuccess, isFalse);
      expect(failure.isFailure, isTrue);
    });

    test('dataOrNull returns the data on Success and null on failure', () {
      expect(success.dataOrNull, 42);
      expect(failure.dataOrNull, isNull);
    });

    test('failureOrNull returns the failure and null on Success', () {
      expect(success.failureOrNull, isNull);
      expect(failure.failureOrNull, isA<NotFoundFailure>());
    });

    test('fold reduces both variants to a single value', () {
      String describe(Result<int> result) => result.fold(
        onSuccess: (int data) => 'ok:$data',
        onFailure: (Failure f) => 'error:${f.userMessage}',
      );

      expect(describe(success), 'ok:42');
      expect(describe(failure), 'error:Recurso no encontrado');
    });

    test('map transforms the data and propagates the failure', () {
      final Result<String> mappedSuccess = success.map(
        (int data) => 'value-$data',
      );
      final Result<String> mappedFailure = failure.map(
        (int data) => 'value-$data',
      );

      expect(mappedSuccess.dataOrNull, 'value-42');
      expect(mappedFailure, isA<FailureResult<String>>());
      expect(mappedFailure.failureOrNull, isA<NotFoundFailure>());
    });
  });
}
