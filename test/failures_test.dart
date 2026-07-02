import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';
import 'package:test/test.dart';

void main() {
  group('Failure.userMessage', () {
    test(
      'given ConnectionFailure when userMessage is accessed '
      'then returns the no-connection message',
      () {
        expect(
          const ConnectionFailure().userMessage,
          'Sin conexión a internet',
        );
      },
    );

    test(
      'given UnauthorizedFailure when userMessage is accessed '
      'then returns the expired-session message',
      () {
        expect(const UnauthorizedFailure().userMessage, 'Sesión expirada');
      },
    );

    test(
      'given NotFoundFailure when userMessage is accessed '
      'then returns the not-found message',
      () {
        expect(const NotFoundFailure().userMessage, 'Recurso no encontrado');
      },
    );

    test(
      'given ServerFailure when userMessage is accessed '
      'then returns the server-error message',
      () {
        expect(
          const ServerFailure().userMessage,
          'Error del servidor. Intenta de nuevo más tarde.',
        );
      },
    );

    test(
      'given RateLimitFailure when userMessage is accessed '
      'then returns the rate-limit message',
      () {
        expect(
          const RateLimitFailure().userMessage,
          'Demasiadas solicitudes. Intenta de nuevo en unos segundos.',
        );
      },
    );

    test(
      'given UnexpectedFailure with a custom message when userMessage '
      'is accessed then returns the custom message',
      () {
        expect(
          const UnexpectedFailure(message: 'Algo salió mal').userMessage,
          'Algo salió mal',
        );
      },
    );

    test(
      'given UnexpectedFailure without a message when userMessage '
      'is accessed then returns the generic fallback message',
      () {
        expect(const UnexpectedFailure().userMessage, 'Error inesperado');
      },
    );

    test('userMessage is an alias of message', () {
      const ConnectionFailure failure = ConnectionFailure(message: 'custom');
      expect(failure.userMessage, failure.message);
    });
  });

  group('Failure debugging context', () {
    test('given a cause and stack trace when constructed '
        'then both are preserved', () {
      final Exception cause = Exception('socket closed');
      final StackTrace stackTrace = StackTrace.current;

      final ConnectionFailure failure = ConnectionFailure(
        cause: cause,
        stackTrace: stackTrace,
      );

      expect(failure.cause, same(cause));
      expect(failure.stackTrace, same(stackTrace));
    });

    test('given a ServerFailure with a status code when statusCode is '
        'accessed then returns the typed code', () {
      const ServerFailure failure = ServerFailure(statusCode: 503);
      expect(failure.statusCode, 503);
    });

    test('toString includes the message and the cause when present', () {
      final Exception cause = Exception('boom');
      final UnexpectedFailure failure = UnexpectedFailure(cause: cause);

      expect(failure.toString(), contains('Error inesperado'));
      expect(failure.toString(), contains('boom'));
      expect(const NotFoundFailure().toString(), isNot(contains('causa')));
    });
  });
}
