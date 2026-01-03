import 'package:flutter_test/flutter_test.dart';
import 'package:hyperlog/services/api_exception.dart';

void main() {
  group('ApiException', () {
    group('isNetworkError', () {
      test('returns true when statusCode is null', () {
        final exception = ApiException(message: 'Network error');
        expect(exception.isNetworkError, true);
      });

      test('returns false when statusCode is set', () {
        final exception = ApiException(message: 'Server error', statusCode: 500);
        expect(exception.isNetworkError, false);
      });

      test('returns false for 0 status code', () {
        final exception = ApiException(message: 'Error', statusCode: 0);
        expect(exception.isNetworkError, false);
      });
    });

    group('isClientError', () {
      test('returns true for 400 Bad Request', () {
        final exception = ApiException(message: 'Bad request', statusCode: 400);
        expect(exception.isClientError, true);
      });

      test('returns true for 401 Unauthorized', () {
        final exception = ApiException(message: 'Unauthorized', statusCode: 401);
        expect(exception.isClientError, true);
      });

      test('returns true for 403 Forbidden', () {
        final exception = ApiException(message: 'Forbidden', statusCode: 403);
        expect(exception.isClientError, true);
      });

      test('returns true for 404 Not Found', () {
        final exception = ApiException(message: 'Not found', statusCode: 404);
        expect(exception.isClientError, true);
      });

      test('returns true for 499 (edge case)', () {
        final exception = ApiException(message: 'Error', statusCode: 499);
        expect(exception.isClientError, true);
      });

      test('returns false for 200 OK', () {
        final exception = ApiException(message: 'OK', statusCode: 200);
        expect(exception.isClientError, false);
      });

      test('returns false for 500 Server Error', () {
        final exception = ApiException(message: 'Server error', statusCode: 500);
        expect(exception.isClientError, false);
      });

      test('returns false for null statusCode', () {
        final exception = ApiException(message: 'Network error');
        expect(exception.isClientError, false);
      });
    });

    group('isServerError', () {
      test('returns true for 500 Internal Server Error', () {
        final exception = ApiException(message: 'Server error', statusCode: 500);
        expect(exception.isServerError, true);
      });

      test('returns true for 502 Bad Gateway', () {
        final exception = ApiException(message: 'Bad gateway', statusCode: 502);
        expect(exception.isServerError, true);
      });

      test('returns true for 503 Service Unavailable', () {
        final exception = ApiException(message: 'Service unavailable', statusCode: 503);
        expect(exception.isServerError, true);
      });

      test('returns true for 599 (edge case)', () {
        final exception = ApiException(message: 'Error', statusCode: 599);
        expect(exception.isServerError, true);
      });

      test('returns false for 404 Not Found', () {
        final exception = ApiException(message: 'Not found', statusCode: 404);
        expect(exception.isServerError, false);
      });

      test('returns false for null statusCode', () {
        final exception = ApiException(message: 'Network error');
        expect(exception.isServerError, false);
      });
    });

    group('isNotFound', () {
      test('returns true for 404', () {
        final exception = ApiException(message: 'Not found', statusCode: 404);
        expect(exception.isNotFound, true);
      });

      test('returns false for 400', () {
        final exception = ApiException(message: 'Bad request', statusCode: 400);
        expect(exception.isNotFound, false);
      });

      test('returns false for 500', () {
        final exception = ApiException(message: 'Server error', statusCode: 500);
        expect(exception.isNotFound, false);
      });

      test('returns false for null statusCode', () {
        final exception = ApiException(message: 'Network error');
        expect(exception.isNotFound, false);
      });
    });

    group('toString', () {
      test('returns the message', () {
        final exception = ApiException(message: 'Custom error message');
        expect(exception.toString(), 'Custom error message');
      });

      test('returns message regardless of statusCode', () {
        final exception = ApiException(
          message: 'Error with code',
          statusCode: 500,
        );
        expect(exception.toString(), 'Error with code');
      });
    });

    group('errorCode', () {
      test('can store custom error code', () {
        final exception = ApiException(
          message: 'Error',
          statusCode: 400,
          errorCode: 'VALIDATION_FAILED',
        );
        expect(exception.errorCode, 'VALIDATION_FAILED');
      });

      test('errorCode is null by default', () {
        final exception = ApiException(message: 'Error');
        expect(exception.errorCode, null);
      });
    });
  });
}
