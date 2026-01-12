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
    String id = 'uuid-test-pilot',
    String licenseNumber = 'UK-ATPL-12345',
    String status = 'active',
    String email = 'john.doe@example.com',
  }) {
    return {
      'id': id,
      'pilotLicense': licenseNumber,
      'name': 'John Doe',
      'email': email,
      'status': status,
      'createdAt': '2024-01-15T10:30:00.000Z',
      'updatedAt': '2024-06-20T14:45:00.000Z',
    };
  }

  group('PilotService', () {
    group('registerPilot', () {
      test('creates pilot and returns Pilot object with id', () async {
        when(() => mockApiService.post(any(), any())).thenAnswer((_) async => {
              'success': true,
              'data': createPilotJson(id: 'uuid-new-pilot', licenseNumber: 'UK-PPL-99999'),
            });

        final pilot = await pilotService.registerPilot(
          licenseNumber: 'UK-PPL-99999',
          name: 'Jane Pilot',
          email: 'jane@aviation.com',
        );

        expect(pilot.id, 'uuid-new-pilot');
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
      test('returns Pilot with id for valid license number', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': createPilotJson(id: 'uuid-atpl-54321', licenseNumber: 'UK-ATPL-54321'),
            });

        final pilot = await pilotService.getPilot('UK-ATPL-54321');

        expect(pilot.id, 'uuid-atpl-54321');
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

    group('getPilotByEmail', () {
      test('returns Pilot for valid email', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': createPilotJson(
                id: 'uuid-email-lookup',
                email: 'pilot@example.com',
              ),
            });

        final pilot = await pilotService.getPilotByEmail('pilot@example.com');

        expect(pilot.id, 'uuid-email-lookup');
        expect(pilot.email, 'pilot@example.com');
      });

      test('calls correct API endpoint with encoded email', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': createPilotJson(),
            });

        await pilotService.getPilotByEmail('test+special@example.com');

        verify(() => mockApiService.get('/users/email/test%2Bspecial%40example.com')).called(1);
      });

      test('throws ApiException for 404 not found', () async {
        final exception = ApiException(message: 'User not found', statusCode: 404);

        when(() => mockApiService.get(any())).thenThrow(exception);

        expect(
          () => pilotService.getPilotByEmail('unknown@example.com'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.isNotFound, 'isNotFound', true),
          ),
        );
      });
    });

    group('getSavedPilotsByUserId', () {
      test('returns list of saved pilots', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': [
                {'name': 'First Officer 1', 'flightCount': 5},
                {'name': 'First Officer 2', 'flightCount': 3},
              ],
            });

        final pilots = await pilotService.getSavedPilotsByUserId('uuid-user-123');

        expect(pilots.length, 2);
        expect(pilots[0].name, 'First Officer 1');
        expect(pilots[0].flightCount, 5);
      });

      test('calls correct API endpoint', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': [],
            });

        await pilotService.getSavedPilotsByUserId('uuid-user-456');

        verify(() => mockApiService.get('/users/uuid-user-456/saved-pilots')).called(1);
      });

      test('returns empty list when no saved pilots', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': [],
            });

        final pilots = await pilotService.getSavedPilotsByUserId('uuid-empty');

        expect(pilots, isEmpty);
      });
    });

    group('createSavedPilotByUserId', () {
      test('creates saved pilot successfully', () async {
        when(() => mockApiService.post(any(), any())).thenAnswer((_) async => {
              'success': true,
              'data': {'name': 'New Crew Member', 'flightCount': 0},
            });

        await pilotService.createSavedPilotByUserId('uuid-user-789', 'New Crew Member');

        verify(() => mockApiService.post(
              '/users/uuid-user-789/saved-pilots',
              {'name': 'New Crew Member'},
            )).called(1);
      });
    });

    group('updateSavedPilotNameByUserId', () {
      test('updates pilot name and returns affected count', () async {
        when(() => mockApiService.put(any(), any())).thenAnswer((_) async => {
              'success': true,
              'data': {'updatedCount': 5},
            });

        final count = await pilotService.updateSavedPilotNameByUserId(
          'uuid-user-123',
          'Old Name',
          'New Name',
        );

        expect(count, 5);
        verify(() => mockApiService.put(
              '/users/uuid-user-123/saved-pilots/Old%20Name',
              {'name': 'New Name'},
            )).called(1);
      });
    });

    group('deleteSavedPilotByUserId', () {
      test('deletes saved pilot and returns deleted count', () async {
        when(() => mockApiService.delete(any())).thenAnswer((_) async => {
              'success': true,
              'data': {'deletedCount': 3},
            });

        final count = await pilotService.deleteSavedPilotByUserId('uuid-user-123', 'Crew Name');

        expect(count, 3);
        verify(() => mockApiService.delete('/users/uuid-user-123/saved-pilots/Crew%20Name')).called(1);
      });
    });

    group('getFlightCountForPilotByUserId', () {
      test('returns flight count for pilot', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': {'flightCount': 42},
            });

        final count = await pilotService.getFlightCountForPilotByUserId(
          'uuid-user-123',
          'Captain Smith',
        );

        expect(count, 42);
        verify(() => mockApiService.get(
              '/users/uuid-user-123/saved-pilots/Captain%20Smith/flight-count',
            )).called(1);
      });
    });
  });
}
