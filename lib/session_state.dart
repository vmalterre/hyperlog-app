import 'package:flutter/material.dart';
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

  /// The current pilot's license number (convenience getter)
  String? get pilotLicense => _currentPilot?.licenseNumber;

  /// Any error that occurred during session operations
  String? get error => _error;

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
    notifyListeners();
  }

  /// Log out the user and clear session data
  Future<void> logOut() async {
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
  /// Looks up pilot by license number derived from email.
  /// In a future phase, this could use a proper user-pilot mapping.
  Future<void> _loadPilotData(String? email) async {
    if (email == null) return;

    try {
      // For now, we use a dev mapping for known test users
      // In production, this would query a user-pilot mapping or use email lookup
      final license = _getLicenseForEmail(email);
      if (license != null) {
        _currentPilot = await _pilotService.getPilot(license);
      }
    } catch (e) {
      // Pilot not found - this is OK, user might need to complete registration
      _currentPilot = null;
    }
  }

  /// Map email to pilot license (development helper)
  ///
  /// In production, this would be replaced with a proper user-pilot lookup.
  String? _getLicenseForEmail(String email) {
    // Alpha test mappings
    const emailToLicense = {
      'standard@hyperlog.aero': 'STANDARD-PILOT-001',
      'official@hyperlog.aero': 'OFFICIAL-PILOT-001',
      'demo@hyperlog.aero': 'DEMO-PILOT-001',
    };
    return emailToLicense[email.toLowerCase()];
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
