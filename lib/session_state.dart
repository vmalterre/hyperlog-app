import 'package:flutter/material.dart';
import 'package:hyperlog/database/database_provider.dart';
import 'package:hyperlog/models/pilot.dart';
import 'package:hyperlog/services/auth_service.dart';
import 'package:hyperlog/services/pilot_service.dart';

/// Application session state that manages authentication and current user data.
///
/// This replaces the old LoginState and fixes the async initialization race condition.
/// It also stores the current pilot data, eliminating hardcoded pilot licenses.
class SessionState extends ChangeNotifier {
  final AuthService _authService;
  final PilotService _pilotService;

  bool _isInitialized = false;
  bool _isLoggedIn = false;
  Pilot? _currentPilot;
  String? _error;
  String? _pilotLoadError;

  SessionState({
    AuthService? authService,
    PilotService? pilotService,
  })  : _authService = authService ?? AuthService(),
        _pilotService = pilotService ?? PilotService();

  /// Whether the session has been initialized (auth state checked)
  bool get isInitialized => _isInitialized;

  /// Whether the user is logged in
  bool get isLoggedIn => _isLoggedIn;

  /// The current pilot profile (null if not logged in or pilot not found)
  Pilot? get currentPilot => _currentPilot;

  /// The current pilot's UUID - primary identifier for all API operations
  String? get userId => _currentPilot?.id;

  /// The current pilot's license number
  /// @deprecated Use userId for API operations
  String? get pilotLicense => _currentPilot?.licenseNumber;

  /// Any error that occurred during session operations
  String? get error => _error;

  /// Any error that occurred while loading pilot data
  String? get pilotLoadError => _pilotLoadError;

  /// Initialize the session state by checking Firebase Auth
  ///
  /// Call this once during app startup, before the first frame.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        _isLoggedIn = true;
        // Try to load pilot data if user is logged in
        await _loadPilotData(user.email);

        // Start sync service for returning users (offline-first)
        if (_currentPilot?.id != null && DatabaseProvider.instance.isInitialized) {
          await DatabaseProvider.instance.startSyncForUser(_currentPilot!.id);
        }
      }
    } catch (e) {
      _error = 'Failed to initialize session: $e';
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Log in the user and load their pilot data
  ///
  /// Call this after successful Firebase Auth sign in/up.
  /// [email] is the user's email to look up pilot data.
  Future<void> logIn({required String email}) async {
    _isLoggedIn = true;
    _error = null;
    await _loadPilotData(email);

    // Start sync service for offline-first support
    if (_currentPilot?.id != null && DatabaseProvider.instance.isInitialized) {
      await DatabaseProvider.instance.startSyncForUser(_currentPilot!.id);
    }

    notifyListeners();
  }

  /// Log out the user and clear session data
  Future<void> logOut() async {
    // Stop sync service (only if database is initialized)
    if (DatabaseProvider.instance.isInitialized) {
      DatabaseProvider.instance.stopSync();
    }

    try {
      await _authService.signOut();
    } catch (e) {
      // Log but don't block logout
    }
    _isLoggedIn = false;
    _currentPilot = null;
    _error = null;
    notifyListeners();
  }

  /// Load pilot data by email
  ///
  /// Uses the API to look up pilot by email, which returns the full profile
  /// including the UUID for subsequent API calls.
  Future<void> _loadPilotData(String? email) async {
    if (email == null) return;

    _pilotLoadError = null;

    try {
      // Look up pilot by email - API returns full profile with UUID
      _currentPilot = await _pilotService.getPilotByEmail(email);
    } catch (e) {
      // Capture the error for debugging
      _pilotLoadError = e.toString();
      _currentPilot = null;
    }
  }

  /// Refresh pilot data from the server
  Future<void> refreshPilot() async {
    if (!_isLoggedIn) return;

    final user = _authService.getCurrentUser();
    if (user?.email != null) {
      await _loadPilotData(user!.email);
      notifyListeners();
    }
  }

  /// Set the current pilot (for registration flow)
  void setCurrentPilot(Pilot pilot) {
    _currentPilot = pilot;
    notifyListeners();
  }
}
