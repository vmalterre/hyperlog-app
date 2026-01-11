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

  // Helper to create valid flight JSON matching new structure
  Map<String, dynamic> createFlightJson({
    String id = 'flight-1',
    int crewCount = 1,
    int verificationCount = 0,
  }) {
    final crew = List.generate(crewCount, (i) => {
      'pilotUUID': 'uuid-$i',
      'pilotLicense': i == 0 ? 'UK-ATPL-12345' : 'UK-ATPL-$i',
      'roles': [
        {
          'role': i == 0 ? 'PIC' : 'SIC',
          'start': '2024-06-15T08:30:00.000Z',
          'end': '2024-06-15T16:00:00.000Z',
        }
      ],
      'landings': {'day': i == 0 ? 1 : 0, 'night': 0},
      'remarks': '',
      'joinedAt': '2024-06-15T08:30:00.000Z',
    });

    final verifications = List.generate(verificationCount, (i) => {
      'source': 'FlightRadar24',
      'verifiedAt': '2024-06-15T17:00:00.000Z',
      'verifiedBy': 'HyperLog Trust Engine',
      'matchData': 'FR24-$i',
    });

    return {
      'id': id,
      'creatorUUID': 'uuid-0',
      'creatorLicense': 'UK-ATPL-12345',
      'flightDate': '2024-06-15',
      'dep': 'EGLL',
      'dest': 'KJFK',
      'blockOff': '2024-06-15T08:30:00.000Z',
      'blockOn': '2024-06-15T16:00:00.000Z',
      'aircraftType': 'B777',
      'aircraftReg': 'G-VIIA',
      'flightTime': {'total': 450, 'night': 120, 'ifr': 450},
      'crew': crew,
      'verifications': verifications,
      'endorsements': [],
      'createdAt': '2024-06-15T17:00:00.000Z',
      'updatedAt': '2024-06-15T17:00:00.000Z',
    };
  }

  // Helper to create a LogbookEntry for testing
  LogbookEntry createTestEntry({
    String id = '',
    String creatorUUID = 'test-uuid-12345',
    String creatorLicense = 'UK-ATPL-12345',
    String dep = 'EGLL',
    String dest = 'KJFK',
    String role = 'PIC',
  }) {
    final now = DateTime.now();
    final blockOff = DateTime.utc(2024, 6, 15, 8, 30);
    final blockOn = DateTime.utc(2024, 6, 15, 16, 0);

    return LogbookEntry(
      id: id,
      creatorUUID: creatorUUID,
      creatorLicense: creatorLicense,
      flightDate: DateTime.utc(2024, 6, 15),
      dep: dep,
      dest: dest,
      blockOff: blockOff,
      blockOn: blockOn,
      aircraftType: 'B777',
      aircraftReg: 'G-VIIA',
      flightTime: FlightTime(total: 450),
      crew: [
        CrewMember(
          pilotUUID: creatorUUID,
          pilotLicense: creatorLicense,
          roles: [
            RoleSegment(role: role, start: blockOff, end: blockOn),
          ],
          landings: Landings(day: 1),
          joinedAt: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }

  group('FlightService', () {
    group('getFlightsForPilot', () {
      test('returns list of LogbookEntryShort for valid pilot', () async {
        when(() => mockApiService.get(any())).thenAnswer((_) async => {
              'success': true,
              'data': [
                createFlightJson(id: 'flight-1', crewCount: 1),
                createFlightJson(id: 'flight-2', verificationCount: 1),
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
        expect(flight.creatorLicense, 'UK-ATPL-12345');
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
        final inputEntry = createTestEntry();

        when(() => mockApiService.post(any(), any())).thenAnswer((_) async => {
              'success': true,
              'data': createFlightJson(id: 'new-flight-id'),
            });

        final result = await flightService.createFlight(inputEntry);

        expect(result.id, 'new-flight-id');
        expect(result.creatorLicense, 'UK-ATPL-12345');
      });

      test('calls correct API endpoint with entry JSON', () async {
        final inputEntry = createTestEntry(
          creatorLicense: 'UK-12345',
          dep: 'LHR',
          dest: 'CDG',
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
      });

      test('reports server errors to ErrorService with flight metadata', () async {
        final inputEntry = createTestEntry(
          creatorLicense: 'UK-ATPL-99999',
          dep: 'EGCC',
          dest: 'LEMD',
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
                'creatorLicense': 'UK-ATPL-99999',
                'dep': 'EGCC',
                'dest': 'LEMD',
              },
            )).called(1);
      });
    });
  });
}
