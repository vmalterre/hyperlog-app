import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hyperlog/services/pilot_service.dart';
import 'package:hyperlog/services/api_exception.dart';
import 'package:hyperlog/services/error_service.dart';
import '../mocks/mock_services.dart';

void main() {
  late MockApiService mockApiService;
  late MockErrorReporter mockErrorReporter;
  late ErrorService testableErrorService;
  late PilotService pilotService;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockApiService = MockApiService();
    mockErrorReporter = MockErrorReporter();
    testableErrorService = createTestableErrorService(mockErrorReporter);

    pilotService = PilotService(
      api: mockApiService,
      errorService: testableErrorService,
    );
  });

  // Helper to create valid pilot JSON
  Map<String, dynamic> createPilotJson({
    String licenseNumber = 'UK-ATPL-12345',
    String status = 'active',
  }) {
    return {
      'licenseNumber': licenseNumber,
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'status': status,
      'createdAt': '2024-01-15T10:30:00.000Z',
      'updatedAt': '2024-06-20T14:45:00.000Z',
    };
  }

  group('PilotService', () {
    group('registerPilot', () {
      test('creates pilot and returns Pilot object', () async {
        when(() => mockApiService.post(any(), any())).thenAnswer((_) async => {
              'success': true,
              'data': createPilotJson(licenseNumber: 'UK-PPL-99999'),
            });

        final pilot = await pilotService.registerPilot(
          licenseNumber: 'UK-PPL-99999',
          name: 'Jane Pilot',
          email: 'jane@aviation.com',
        );

        expect(pilot.licenseNumber, 'UK-PPL-99999');
        expect(pilot.name, 'John Doe'); // From mock response
        expect(pilot.isActive, true);
      });

      test('calls correct API endpoint with pilot data', () async {
        when(() => mockApiService.post(any(), any())).thenAnswer((_) async => {
              'success': true,
              'data': createPilotJson(),
            });

        await pilotService.registerPilot(
          licenseNumber: 'UK-ATPL-12345',
          name: 'Test Pilot',
          email: 'test@example.com',
        );

        final captured = verify(
          () => mockApiService.post('/pilots', captureAny()),
        ).captured;

        final sentData = captured.first as Map<String, dynamic>;
        expect(sentData['licenseNumber'], 'UK-ATPL-12345');
        expect(sentData['name'], 'Test Pilot');
        expect(sentData['email'], 'test@example.com');
      });

      test('reports server errors to ErrorService', () async {
        final exception = ApiException(message: 'Server error', statusCode: 500);

        when(() => mockApiService.post(any(), any())).thenThrow(exception);
        when(() => mockErrorReporter.reportError(
              any(),
              any(),
              message: any(named: 'message'),
              metadata: any(named: 'metadata'),
            )).thenReturn(null);

        await expectLater(
          () => pilotService.registerPilot(
            licenseNumber: 'UK-12345',
            name: 'Test',
            email: 'test@test.com',
          ),
          throwsA(isA<ApiException>()),
        );

        verify(() => mockErrorReporter.reportError(
              exception,
              any(),
              message: 'Failed to register pilot',
              metadata: {'licenseNumber': 'UK-12345', 'email': 'test@test.com'},
            )).called(1);
      });

      test('does not report client errors (4xx) to ErrorService', () async {
        final exception = ApiException(
          message: 'License already registered',
          statusCode: 409,
        );

        when(() => mockApiService.post(any(), any())).thenThrow(exception);

        await expectLater(
          () => pilotService.registerPilot(
            licenseNumber: 'UK-12345',
            name: 'Test',
            email: 'test@test.com',
          ),
          throwsA(isA<ApiException>()),
        );

        verifyNever(() => mockErrorReporter.reportError(
              any(),
              any(),
              message: any(named: 'message'),
              metadata: any(named: 'metadata'),
            ));
      });

      test('rethrows exception after reporting', () async {
        final exception = ApiException(message: 'DB connection failed', statusCode: 503);

        when(() => mockApiService.post(any(), any())).thenThrow(exception);
        when(() => mockErrorReporter.reportError(
              any(),
              any(),
              message: any(named: 'message'),
              metadata: any(named: 'metadata'),
            )).thenReturn(null);

        expect(
          () => pilotService.registerPilot(
            licenseNumber: 'UK-12345',
            name: 'Test',
            email: 'test@test.com',
          ),
          throwsA(same(exception)),
        );
      });
    });

    group('getPilot', () {
      test('returns Pilot for valid license number', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': createPilotJson(licenseNumber: 'UK-ATPL-54321'),
            });

        final pilot = await pilotService.getPilot('UK-ATPL-54321');

        expect(pilot.licenseNumber, 'UK-ATPL-54321');
        expect(pilot.name, 'John Doe');
        expect(pilot.email, 'john.doe@example.com');
        expect(pilot.isActive, true);
      });

      test('calls correct API endpoint', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': createPilotJson(),
            });

        await pilotService.getPilot('UK-CPL-11111');

        verify(() => mockApiService.get('/pilots/UK-CPL-11111')).called(1);
      });

      test('parses suspended pilot status correctly', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': createPilotJson(status: 'suspended'),
            });

        final pilot = await pilotService.getPilot('UK-12345');

        expect(pilot.status, 'suspended');
        expect(pilot.isActive, false);
      });

      test('reports server errors to ErrorService', () async {
        final exception = ApiException(message: 'Server error', statusCode: 500);

        when(() => mockApiService.get(any())).thenThrow(exception);
        when(() => mockErrorReporter.reportError(
              any(),
              any(),
              message: any(named: 'message'),
              metadata: any(named: 'metadata'),
            )).thenReturn(null);

        await expectLater(
          () => pilotService.getPilot('UK-12345'),
          throwsA(isA<ApiException>()),
        );

        verify(() => mockErrorReporter.reportError(
              exception,
              any(),
              message: 'Failed to get pilot',
              metadata: {'licenseNumber': 'UK-12345'},
            )).called(1);
      });

      test('throws ApiException for 404 not found', () async {
        final exception = ApiException(message: 'Pilot not found', statusCode: 404);

        when(() => mockApiService.get(any())).thenThrow(exception);

        expect(
          () => pilotService.getPilot('UK-NONEXISTENT'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.isNotFound, 'isNotFound', true),
          ),
        );
      });
    });

    group('pilotExists', () {
      test('returns true when pilot exists', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': createPilotJson(),
            });

        final exists = await pilotService.pilotExists('UK-ATPL-12345');

        expect(exists, true);
      });

      test('returns false when pilot not found (404)', () async {
        when(() => mockApiService.get(any())).thenThrow(
          ApiException(message: 'Not found', statusCode: 404),
        );

        final exists = await pilotService.pilotExists('UK-NONEXISTENT');

        expect(exists, false);
      });

      test('rethrows non-404 errors', () async {
        final exception = ApiException(message: 'Server error', statusCode: 500);

        when(() => mockApiService.get(any())).thenThrow(exception);
        when(() => mockErrorReporter.reportError(
              any(),
              any(),
              message: any(named: 'message'),
              metadata: any(named: 'metadata'),
            )).thenReturn(null);

        expect(
          () => pilotService.pilotExists('UK-12345'),
          throwsA(isA<ApiException>()),
        );
      });

      test('rethrows network errors', () async {
        final exception = ApiException(
          message: 'Network error. Please check your connection.',
        );

        when(() => mockApiService.get(any())).thenThrow(exception);

        expect(
          () => pilotService.pilotExists('UK-12345'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.isNetworkError, 'isNetworkError', true),
          ),
        );
      });

      test('calls getPilot internally', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': createPilotJson(),
            });

        await pilotService.pilotExists('UK-CHECK-123');

        verify(() => mockApiService.get('/pilots/UK-CHECK-123')).called(1);
      });
    });
  });
}
