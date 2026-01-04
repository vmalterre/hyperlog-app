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
    String licenseNumber = 'ALPHA-TEST-001',
    String name = 'Test Pilot',
    String email = 'test@hyperlog.aero',
  }) {
    return Pilot(
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

        verifyNever(() => mockPilotService.getPilot(any()));
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

      test('loads pilot data for known test email', () async {
        final testPilot = createTestPilot();
        when(() => mockPilotService.getPilot('ALPHA-TEST-001'))
            .thenAnswer((_) async => testPilot);

        await sessionState.logIn(email: 'test@hyperlog.aero');

        expect(sessionState.currentPilot, testPilot);
        expect(sessionState.pilotLicense, 'ALPHA-TEST-001');
      });

      test('handles case-insensitive email matching', () async {
        final testPilot = createTestPilot();
        when(() => mockPilotService.getPilot('ALPHA-TEST-001'))
            .thenAnswer((_) async => testPilot);

        await sessionState.logIn(email: 'TEST@HYPERLOG.AERO');

        expect(sessionState.currentPilot, testPilot);
      });

      test('currentPilot is null for unknown email', () async {
        await sessionState.logIn(email: 'unknown@example.com');

        expect(sessionState.currentPilot, isNull);
        expect(sessionState.pilotLicense, isNull);
        verifyNever(() => mockPilotService.getPilot(any()));
      });

      test('currentPilot is null when pilot lookup fails', () async {
        when(() => mockPilotService.getPilot(any()))
            .thenThrow(ApiException(message: 'Not found', statusCode: 404));

        await sessionState.logIn(email: 'test@hyperlog.aero');

        expect(sessionState.isLoggedIn, true); // Still logged in
        expect(sessionState.currentPilot, isNull); // But no pilot data
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
        when(() => mockPilotService.getPilot('ALPHA-TEST-001'))
            .thenAnswer((_) async => testPilot);
        when(() => mockAuthService.signOut()).thenAnswer((_) async {});

        await sessionState.logIn(email: 'test@hyperlog.aero');
      });

      test('sets isLoggedIn to false', () async {
        await sessionState.logOut();

        expect(sessionState.isLoggedIn, false);
      });

      test('clears currentPilot', () async {
        expect(sessionState.currentPilot, isNotNull); // Verify setup

        await sessionState.logOut();

        expect(sessionState.currentPilot, isNull);
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
      test('sets the current pilot', () {
        final pilot = createTestPilot(licenseNumber: 'UK-CPL-99999');

        sessionState.setCurrentPilot(pilot);

        expect(sessionState.currentPilot, pilot);
        expect(sessionState.pilotLicense, 'UK-CPL-99999');
      });

      test('notifies listeners', () {
        var notified = false;
        sessionState.addListener(() => notified = true);

        sessionState.setCurrentPilot(createTestPilot());

        expect(notified, true);
      });

      test('can update pilot to different pilot', () {
        final pilot1 = createTestPilot(licenseNumber: 'UK-PPL-111');
        final pilot2 = createTestPilot(licenseNumber: 'UK-ATPL-222');

        sessionState.setCurrentPilot(pilot1);
        expect(sessionState.pilotLicense, 'UK-PPL-111');

        sessionState.setCurrentPilot(pilot2);
        expect(sessionState.pilotLicense, 'UK-ATPL-222');
      });
    });

    group('refreshPilot()', () {
      test('does nothing when not logged in', () async {
        when(() => mockAuthService.getCurrentUser()).thenReturn(null);

        await sessionState.refreshPilot();

        verifyNever(() => mockPilotService.getPilot(any()));
      });
    });

    group('email to license mapping', () {
      test('maps test@hyperlog.aero to ALPHA-TEST-001', () async {
        final testPilot = createTestPilot();
        when(() => mockPilotService.getPilot('ALPHA-TEST-001'))
            .thenAnswer((_) async => testPilot);

        await sessionState.logIn(email: 'test@hyperlog.aero');

        verify(() => mockPilotService.getPilot('ALPHA-TEST-001')).called(1);
      });

      test('maps demo@hyperlog.aero to ALPHA-DEMO-001', () async {
        final demoPilot = createTestPilot(
          licenseNumber: 'ALPHA-DEMO-001',
          email: 'demo@hyperlog.aero',
        );
        when(() => mockPilotService.getPilot('ALPHA-DEMO-001'))
            .thenAnswer((_) async => demoPilot);

        await sessionState.logIn(email: 'demo@hyperlog.aero');

        verify(() => mockPilotService.getPilot('ALPHA-DEMO-001')).called(1);
      });

      test('returns null for unmapped emails', () async {
        await sessionState.logIn(email: 'random@example.com');

        verifyNever(() => mockPilotService.getPilot(any()));
        expect(sessionState.currentPilot, isNull);
      });
    });
  });
}
