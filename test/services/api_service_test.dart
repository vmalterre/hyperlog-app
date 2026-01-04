import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:hyperlog/config/app_config.dart';
import 'package:hyperlog/services/api_service.dart';
import 'package:hyperlog/services/api_exception.dart';
import '../mocks/mock_services.dart';

void main() {
  late MockHttpClient mockClient;
  late ApiService apiService;

  setUpAll(() {
    registerFallbackValues();
    // Initialize AppConfig for tests (only runs once)
    AppConfig.initialize(environment: 'dev');
  });

  setUp(() {
    mockClient = MockHttpClient();
    apiService = ApiService(client: mockClient);
  });

  group('ApiService', () {
    group('get', () {
      test('returns data on successful 200 response', () async {
        final responseBody = jsonEncode({
          'success': true,
          'data': {'id': 'test-123', 'name': 'Test Item'},
        });

        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 200));

        final result = await apiService.get('/test');

        expect(result['success'], true);
        expect(result['data']['id'], 'test-123');
        expect(result['data']['name'], 'Test Item');
      });

      test('throws ApiException on 404 response', () async {
        final responseBody = jsonEncode({
          'success': false,
          'error': 'Not found',
        });

        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 404));

        expect(
          () => apiService.get('/test'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 404)
                .having((e) => e.isNotFound, 'isNotFound', true),
          ),
        );
      });

      test('throws ApiException on 500 server error', () async {
        final responseBody = jsonEncode({
          'success': false,
          'error': 'Internal server error',
        });

        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 500));

        expect(
          () => apiService.get('/test'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 500)
                .having((e) => e.isServerError, 'isServerError', true),
          ),
        );
      });

      test('throws ApiException with network error on SocketException', () async {
        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenThrow(const SocketException('No internet'));

        expect(
          () => apiService.get('/test'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.isNetworkError, 'isNetworkError', true)
                .having((e) => e.message, 'message',
                    'Network error. Please check your connection.'),
          ),
        );
      });

      test('throws ApiException on timeout', () async {
        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenThrow(TimeoutException('Timeout'));

        expect(
          () => apiService.get('/test'),
          throwsA(
            isA<ApiException>().having(
              (e) => e.message,
              'message',
              'Request timed out. Please try again.',
            ),
          ),
        );
      });

      test('throws ApiException on ClientException', () async {
        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenThrow(http.ClientException('Connection refused'));

        expect(
          () => apiService.get('/test'),
          throwsA(
            isA<ApiException>().having(
              (e) => e.message,
              'message',
              'Connection failed. Please try again.',
            ),
          ),
        );
      });

      test('throws ApiException on invalid JSON response', () async {
        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('not valid json', 200));

        expect(
          () => apiService.get('/test'),
          throwsA(
            isA<ApiException>().having(
              (e) => e.message,
              'message',
              'Invalid response from server',
            ),
          ),
        );
      });

      test('throws ApiException when success is false even on 200', () async {
        final responseBody = jsonEncode({
          'success': false,
          'error': 'Validation failed',
        });

        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 200));

        expect(
          () => apiService.get('/test'),
          throwsA(
            isA<ApiException>().having(
              (e) => e.message,
              'message',
              'Validation failed',
            ),
          ),
        );
      });

      test('uses message field when error is not present', () async {
        final responseBody = jsonEncode({
          'success': false,
          'message': 'Custom message',
        });

        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 400));

        expect(
          () => apiService.get('/test'),
          throwsA(
            isA<ApiException>().having(
              (e) => e.message,
              'message',
              'Custom message',
            ),
          ),
        );
      });
    });

    group('post', () {
      test('sends JSON body and returns data on success', () async {
        final responseBody = jsonEncode({
          'success': true,
          'data': {'id': 'created-123'},
        });

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(responseBody, 201));

        final result = await apiService.post('/test', {'name': 'New Item'});

        expect(result['success'], true);
        expect(result['data']['id'], 'created-123');

        // Verify the body was sent correctly
        final captured = verify(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: captureAny(named: 'body'),
            )).captured;

        expect(jsonDecode(captured.first)['name'], 'New Item');
      });

      test('throws ApiException on 400 validation error', () async {
        final responseBody = jsonEncode({
          'success': false,
          'error': 'Email already exists',
        });

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(responseBody, 400));

        expect(
          () => apiService.post('/test', {'email': 'test@example.com'}),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 400)
                .having((e) => e.isClientError, 'isClientError', true)
                .having((e) => e.message, 'message', 'Email already exists'),
          ),
        );
      });

      test('includes errorCode from response', () async {
        final responseBody = jsonEncode({
          'success': false,
          'error': 'DUPLICATE_EMAIL',
          'message': 'Email already registered',
        });

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(responseBody, 409));

        expect(
          () => apiService.post('/test', {}),
          throwsA(
            isA<ApiException>().having(
              (e) => e.errorCode,
              'errorCode',
              'DUPLICATE_EMAIL',
            ),
          ),
        );
      });
    });

    group('request headers', () {
      test('includes Content-Type and Accept headers', () async {
        final responseBody = jsonEncode({'success': true, 'data': {}});

        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 200));

        await apiService.get('/test');

        final captured = verify(() => mockClient.get(
              any(),
              headers: captureAny(named: 'headers'),
            )).captured;

        final headers = captured.first as Map<String, String>;
        expect(headers['Content-Type'], 'application/json');
        expect(headers['Accept'], 'application/json');
      });
    });
  });
}
