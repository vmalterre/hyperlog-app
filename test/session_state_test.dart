import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hyperlog/session_state.dart';
import 'package:hyperlog/models/pilot.dart';
import 'package:hyperlog/services/api_exception.dart';
import 'mocks/mock_services.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockPilotService mockPilotService;
  late SessionState sessionState;

  // Helper to create valid pilot
  Pilot createTestPilot({
    String id = 'uuid-standard-pilot',
    String licenseNumber = 'STANDARD-PILOT-001',
    String name = 'Standard Pilot',
    String email = 'standard@hyperlog.aero',
  }) {
    return Pilot(
      id: id,
      licenseNumber: licenseNumber,
      name: name,
      email: email,
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  setUp(() {
    mockAuthService = MockAuthService();
    mockPilotService = MockPilotService();
    sessionState = SessionState(
      authService: mockAuthService,
      pilotService: mockPilotService,
    );
  });

  group('SessionState', () {
    group('initial state', () {
      test('isInitialized is false before initialize() is called', () {
        expect(sessionState.isInitialized, false);
      });

      test('isLoggedIn is false before initialize() is called', () {
        expect(sessionState.isLoggedIn, false);
      });

      test('currentPilot is null before initialize() is called', () {
        expect(sessionState.currentPilot, isNull);
      });

      test('pilotLicense is null before initialize() is called', () {
        expect(sessionState.pilotLicense, isNull);
      });

      test('userId is null before initialize() is called', () {
        expect(sessionState.userId, isNull);
      });

      test('error is null initially', () {
        expect(sessionState.error, isNull);
      });
    });

    group('initialize()', () {
      test('sets isInitialized to true when no user logged in', () async {
        when(() => mockAuthService.getCurrentUser()).thenReturn(null);

        await sessionState.initialize();

        expect(sessionState.isInitialized, true);
      });

      test('keeps isLoggedIn false when no user logged in', () async {
        when(() => mockAuthService.getCurrentUser()).thenReturn(null);

        await sessionState.initialize();

        expect(sessionState.isLoggedIn, false);
      });

      test('does not call pilotService when no user logged in', () async {
        when(() => mockAuthService.getCurrentUser()).thenReturn(null);

        await sessionState.initialize();

        verifyNever(() => mockPilotService.getPilotByEmail(any()));
      });

      test('only initializes once (idempotent)', () async {
        when(() => mockAuthService.getCurrentUser()).thenReturn(null);

        await sessionState.initialize();
        await sessionState.initialize();
        await sessionState.initialize();

        verify(() => mockAuthService.getCurrentUser()).called(1);
      });

      test('notifies listeners after initialization', () async {
        when(() => mockAuthService.getCurrentUser()).thenReturn(null);

        var notified = false;
        sessionState.addListener(() => notified = true);

        await sessionState.initialize();

        expect(notified, true);
      });
    });

    group('logIn()', () {
      test('sets isLoggedIn to true', () async {
        await sessionState.logIn(email: 'test@example.com');

        expect(sessionState.isLoggedIn, true);
      });

      test('clears any previous error', () async {
        // Simulate an error state
        sessionState = SessionState(
          authService: mockAuthService,
          pilotService: mockPilotService,
        );

        await sessionState.logIn(email: 'test@example.com');

        expect(sessionState.error, isNull);
      });

      test('loads pilot data by email', () async {
        final testPilot = createTestPilot();
        when(() => mockPilotService.getPilotByEmail('standard@hyperlog.aero'))
            .thenAnswer((_) async => testPilot);

        await sessionState.logIn(email: 'standard@hyperlog.aero');

        expect(sessionState.currentPilot, testPilot);
        expect(sessionState.userId, 'uuid-standard-pilot');
        expect(sessionState.pilotLicense, 'STANDARD-PILOT-001');
      });

      test('calls getPilotByEmail with provided email', () async {
        final testPilot = createTestPilot();
        when(() => mockPilotService.getPilotByEmail('STANDARD@HYPERLOG.AERO'))
            .thenAnswer((_) async => testPilot);

        await sessionState.logIn(email: 'STANDARD@HYPERLOG.AERO');

        verify(() => mockPilotService.getPilotByEmail('STANDARD@HYPERLOG.AERO')).called(1);
        expect(sessionState.currentPilot, testPilot);
      });

      test('currentPilot is null when pilot lookup fails', () async {
        when(() => mockPilotService.getPilotByEmail(any()))
            .thenThrow(ApiException(message: 'Not found', statusCode: 404));

        await sessionState.logIn(email: 'unknown@example.com');

        expect(sessionState.isLoggedIn, true); // Still logged in
        expect(sessionState.currentPilot, isNull); // But no pilot data
        expect(sessionState.userId, isNull);
      });

      test('notifies listeners after login', () async {
        var notified = false;
        sessionState.addListener(() => notified = true);

        await sessionState.logIn(email: 'test@example.com');

        expect(notified, true);
      });
    });

    group('logOut()', () {
      setUp(() async {
        // Set up logged-in state
        final testPilot = createTestPilot();
        when(() => mockPilotService.getPilotByEmail('standard@hyperlog.aero'))
            .thenAnswer((_) async => testPilot);
        when(() => mockAuthService.signOut()).thenAnswer((_) async {});

        await sessionState.logIn(email: 'standard@hyperlog.aero');
      });

      test('sets isLoggedIn to false', () async {
        await sessionState.logOut();

        expect(sessionState.isLoggedIn, false);
      });

      test('clears currentPilot and userId', () async {
        expect(sessionState.currentPilot, isNotNull); // Verify setup
        expect(sessionState.userId, isNotNull);

        await sessionState.logOut();

        expect(sessionState.currentPilot, isNull);
        expect(sessionState.userId, isNull);
        expect(sessionState.pilotLicense, isNull);
      });

      test('clears error', () async {
        await sessionState.logOut();

        expect(sessionState.error, isNull);
      });

      test('calls authService.signOut()', () async {
        await sessionState.logOut();

        verify(() => mockAuthService.signOut()).called(1);
      });

      test('still logs out even if signOut() throws', () async {
        when(() => mockAuthService.signOut()).thenThrow(Exception('Network error'));

        await sessionState.logOut();

        expect(sessionState.isLoggedIn, false);
        expect(sessionState.currentPilot, isNull);
      });

      test('notifies listeners after logout', () async {
        var notifyCount = 0;
        sessionState.addListener(() => notifyCount++);

        await sessionState.logOut();

        expect(notifyCount, 1);
      });
    });

    group('setCurrentPilot()', () {
      test('sets the current pilot and userId', () {
        final pilot = createTestPilot(id: 'uuid-cpl-99999', licenseNumber: 'UK-CPL-99999');

        sessionState.setCurrentPilot(pilot);

        expect(sessionState.currentPilot, pilot);
        expect(sessionState.userId, 'uuid-cpl-99999');
        expect(sessionState.pilotLicense, 'UK-CPL-99999');
      });

      test('notifies listeners', () {
        var notified = false;
        sessionState.addListener(() => notified = true);

        sessionState.setCurrentPilot(createTestPilot());

        expect(notified, true);
      });

      test('can update pilot to different pilot', () {
        final pilot1 = createTestPilot(id: 'uuid-ppl-111', licenseNumber: 'UK-PPL-111');
        final pilot2 = createTestPilot(id: 'uuid-atpl-222', licenseNumber: 'UK-ATPL-222');

        sessionState.setCurrentPilot(pilot1);
        expect(sessionState.userId, 'uuid-ppl-111');
        expect(sessionState.pilotLicense, 'UK-PPL-111');

        sessionState.setCurrentPilot(pilot2);
        expect(sessionState.userId, 'uuid-atpl-222');
        expect(sessionState.pilotLicense, 'UK-ATPL-222');
      });
    });

    group('refreshPilot()', () {
      test('does nothing when not logged in', () async {
        when(() => mockAuthService.getCurrentUser()).thenReturn(null);

        await sessionState.refreshPilot();

        verifyNever(() => mockPilotService.getPilotByEmail(any()));
      });
    });

    group('getPilotByEmail behavior', () {
      test('calls getPilotByEmail for any email', () async {
        final testPilot = createTestPilot();
        when(() => mockPilotService.getPilotByEmail('standard@hyperlog.aero'))
            .thenAnswer((_) async => testPilot);

        await sessionState.logIn(email: 'standard@hyperlog.aero');

        verify(() => mockPilotService.getPilotByEmail('standard@hyperlog.aero')).called(1);
        expect(sessionState.userId, 'uuid-standard-pilot');
      });

      test('handles official tier pilot email lookup', () async {
        final officialPilot = createTestPilot(
          id: 'uuid-official-pilot',
          licenseNumber: 'OFFICIAL-PILOT-001',
          email: 'official@hyperlog.aero',
        );
        when(() => mockPilotService.getPilotByEmail('official@hyperlog.aero'))
            .thenAnswer((_) async => officialPilot);

        await sessionState.logIn(email: 'official@hyperlog.aero');

        verify(() => mockPilotService.getPilotByEmail('official@hyperlog.aero')).called(1);
        expect(sessionState.userId, 'uuid-official-pilot');
      });

      test('handles demo pilot email lookup', () async {
        final demoPilot = createTestPilot(
          id: 'uuid-demo-pilot',
          licenseNumber: 'DEMO-PILOT-001',
          email: 'demo@hyperlog.aero',
        );
        when(() => mockPilotService.getPilotByEmail('demo@hyperlog.aero'))
            .thenAnswer((_) async => demoPilot);

        await sessionState.logIn(email: 'demo@hyperlog.aero');

        verify(() => mockPilotService.getPilotByEmail('demo@hyperlog.aero')).called(1);
        expect(sessionState.userId, 'uuid-demo-pilot');
      });

      test('handles unknown email gracefully', () async {
        when(() => mockPilotService.getPilotByEmail('random@example.com'))
            .thenThrow(ApiException(message: 'Not found', statusCode: 404));

        await sessionState.logIn(email: 'random@example.com');

        verify(() => mockPilotService.getPilotByEmail('random@example.com')).called(1);
        expect(sessionState.currentPilot, isNull);
        expect(sessionState.userId, isNull);
      });
    });
  });
}
