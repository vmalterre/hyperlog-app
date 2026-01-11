import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hyperlog/services/flight_service.dart';
import 'package:hyperlog/services/api_exception.dart';
import 'package:hyperlog/services/error_service.dart';
import 'package:hyperlog/models/logbook_entry.dart';
import 'package:hyperlog/widgets/trust_badge.dart';
import '../mocks/mock_services.dart';

void main() {
  late MockApiService mockApiService;
  late MockErrorReporter mockErrorReporter;
  late ErrorService testableErrorService;
  late FlightService flightService;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockApiService = MockApiService();
    mockErrorReporter = MockErrorReporter();
    testableErrorService = createTestableErrorService(mockErrorReporter);

    flightService = FlightService(
      api: mockApiService,
      errorService: testableErrorService,
    );
  });

  // Helper to create valid flight JSON
  Map<String, dynamic> createFlightJson({
    String id = 'flight-1',
    String trustLevel = 'LOGGED',
  }) {
    return {
      'id': id,
      'pilotLicense': 'UK-ATPL-12345',
      'flightDate': '2024-06-15T00:00:00.000Z',
      'dep': 'EGLL',
      'dest': 'KJFK',
      'blockOff': '2024-06-15T08:30:00.000Z',
      'blockOn': '2024-06-15T16:00:00.000Z',
      'aircraftType': 'B777',
      'aircraftReg': 'G-VIIA',
      'flightTime': {'total': 450, 'night': 120, 'ifr': 450},
      'landings': {'day': 1, 'night': 0},
      'role': 'PIC',
      'trustLevel': trustLevel,
      'createdAt': '2024-06-15T17:00:00.000Z',
      'updatedAt': '2024-06-15T17:00:00.000Z',
    };
  }

  group('FlightService', () {
    group('getFlightsForPilot', () {
      test('returns list of LogbookEntryShort for valid pilot', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': [
                createFlightJson(id: 'flight-1'),
                createFlightJson(id: 'flight-2', trustLevel: 'TRACKED'),
              ],
            });

        final flights = await flightService.getFlightsForPilot('UK-ATPL-12345');

        expect(flights.length, 2);
        expect(flights[0].id, 'flight-1');
        expect(flights[0].depIata, 'EGLL');
        expect(flights[0].desIata, 'KJFK');
        expect(flights[0].trustLevel, TrustLevel.logged);
        expect(flights[1].id, 'flight-2');
        expect(flights[1].trustLevel, TrustLevel.tracked);
      });

      test('returns empty list when no flights exist', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': [],
            });

        final flights = await flightService.getFlightsForPilot('UK-12345');

        expect(flights, isEmpty);
      });

      test('calls correct API endpoint', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': [],
            });

        await flightService.getFlightsForPilot('UK-ATPL-99999');

        verify(() => mockApiService.get('/pilots/UK-ATPL-99999/flights'))
            .called(1);
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
          () => flightService.getFlightsForPilot('UK-12345'),
          throwsA(isA<ApiException>()),
        );

        verify(() => mockErrorReporter.reportError(
              exception,
              any(),
              message: 'Failed to fetch flights',
              metadata: {'licenseNumber': 'UK-12345'},
            )).called(1);
      });

      test('does not report client errors (4xx) to ErrorService', () async {
        final exception = ApiException(message: 'Not found', statusCode: 404);

        when(() => mockApiService.get(any())).thenThrow(exception);

        await expectLater(
          () => flightService.getFlightsForPilot('UK-12345'),
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
        final exception = ApiException(message: 'Server error', statusCode: 500);

        when(() => mockApiService.get(any())).thenThrow(exception);
        when(() => mockErrorReporter.reportError(
              any(),
              any(),
              message: any(named: 'message'),
              metadata: any(named: 'metadata'),
            )).thenReturn(null);

        expect(
          () => flightService.getFlightsForPilot('UK-12345'),
          throwsA(same(exception)),
        );
      });
    });

    group('getFlight', () {
      test('returns LogbookEntry for valid flight ID', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': createFlightJson(id: 'flight-123'),
            });

        final flight = await flightService.getFlight('flight-123');

        expect(flight.id, 'flight-123');
        expect(flight.pilotLicense, 'UK-ATPL-12345');
        expect(flight.dep, 'EGLL');
        expect(flight.dest, 'KJFK');
        expect(flight.aircraftReg, 'G-VIIA');
        expect(flight.flightTime.total, 450);
      });

      test('calls correct API endpoint', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': createFlightJson(),
            });

        await flightService.getFlight('abc-123');

        verify(() => mockApiService.get('/flights/abc-123')).called(1);
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
          () => flightService.getFlight('flight-123'),
          throwsA(isA<ApiException>()),
        );

        verify(() => mockErrorReporter.reportError(
              exception,
              any(),
              message: 'Failed to fetch flight',
              metadata: {'flightId': 'flight-123'},
            )).called(1);
      });
    });

    group('createFlight', () {
      test('creates flight and returns LogbookEntry', () async {
        final inputEntry = LogbookEntry(
          id: '',
          pilotUUID: 'test-uuid-12345',
          pilotLicense: 'UK-ATPL-12345',
          flightDate: DateTime.utc(2024, 6, 15),
          dep: 'EGLL',
          dest: 'KJFK',
          blockOff: DateTime.utc(2024, 6, 15, 8, 30),
          blockOn: DateTime.utc(2024, 6, 15, 16, 0),
          aircraftType: 'B777',
          aircraftReg: 'G-VIIA',
          flightTime: FlightTime(total: 450),
          landings: Landings(day: 1),
          role: 'PIC',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockApiService.post(any(), any())).thenAnswer((_) async => {
              'success': true,
              'data': createFlightJson(id: 'new-flight-id'),
            });

        final result = await flightService.createFlight(inputEntry);

        expect(result.id, 'new-flight-id');
        expect(result.pilotLicense, 'UK-ATPL-12345');
      });

      test('calls correct API endpoint with entry JSON', () async {
        final inputEntry = LogbookEntry(
          id: '',
          pilotUUID: 'test-uuid-001',
          pilotLicense: 'UK-12345',
          flightDate: DateTime.utc(2024, 1, 1),
          dep: 'LHR',
          dest: 'CDG',
          blockOff: DateTime.utc(2024, 1, 1, 8, 0),
          blockOn: DateTime.utc(2024, 1, 1, 9, 30),
          aircraftType: 'A320',
          aircraftReg: 'G-TEST',
          flightTime: FlightTime(total: 90),
          landings: Landings(day: 1),
          role: 'FO',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockApiService.post(any(), any())).thenAnswer((_) async => {
              'success': true,
              'data': createFlightJson(),
            });

        await flightService.createFlight(inputEntry);

        final captured = verify(
          () => mockApiService.post('/flights', captureAny()),
        ).captured;

        final sentData = captured.first as Map<String, dynamic>;
        expect(sentData['pilotLicense'], 'UK-12345');
        expect(sentData['dep'], 'LHR');
        expect(sentData['dest'], 'CDG');
        expect(sentData['aircraftReg'], 'G-TEST');
      });

      test('reports server errors to ErrorService with flight metadata', () async {
        final inputEntry = LogbookEntry(
          id: '',
          pilotUUID: 'test-uuid-99999',
          pilotLicense: 'UK-ATPL-99999',
          flightDate: DateTime.now(),
          dep: 'EGCC',
          dest: 'LEMD',
          blockOff: DateTime.now(),
          blockOn: DateTime.now(),
          aircraftType: 'A320',
          aircraftReg: 'G-EZAB',
          flightTime: FlightTime(total: 120),
          landings: Landings(day: 1),
          role: 'PIC',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final exception = ApiException(message: 'Server error', statusCode: 500);

        when(() => mockApiService.post(any(), any())).thenThrow(exception);
        when(() => mockErrorReporter.reportError(
              any(),
              any(),
              message: any(named: 'message'),
              metadata: any(named: 'metadata'),
            )).thenReturn(null);

        await expectLater(
          () => flightService.createFlight(inputEntry),
          throwsA(isA<ApiException>()),
        );

        verify(() => mockErrorReporter.reportError(
              exception,
              any(),
              message: 'Failed to create flight',
              metadata: {
                'pilotLicense': 'UK-ATPL-99999',
                'dep': 'EGCC',
                'dest': 'LEMD',
              },
            )).called(1);
      });
    });
  });
}
