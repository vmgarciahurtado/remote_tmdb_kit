import 'package:flutter_test/flutter_test.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

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
      'given UnexpectedFailure with a custom message when userMessage '
      'is accessed then returns the custom message',
      () {
        expect(
          const UnexpectedFailure('Algo salió mal').userMessage,
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
  });
}
