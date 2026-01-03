import '../config/api_config.dart';
import '../models/pilot.dart';
import 'api_exception.dart';
import 'api_service.dart';
import 'error_service.dart';

/// Service for pilot-related API operations
class PilotService {
  final ApiService _api;
  final ErrorService _errorService;

  /// Constructor with optional dependency injection for testing
  PilotService({ApiService? api, ErrorService? errorService})
      : _api = api ?? ApiService(),
        _errorService = errorService ?? ErrorService();

  /// Register a new pilot
  Future<Pilot> registerPilot({
    required String licenseNumber,
    required String name,
    required String email,
  }) async {
    try {
      final response = await _api.post(ApiConfig.pilots, {
        'licenseNumber': licenseNumber,
        'name': name,
        'email': email,
      });

      return Pilot.fromJson(response['data']);
    } on ApiException catch (e) {
      // Log to Crashlytics if unexpected error
      if (e.isServerError) {
        _errorService.reporter.reportError(
              e,
              StackTrace.current,
              message: 'Failed to register pilot',
              metadata: {'licenseNumber': licenseNumber, 'email': email},
            );
      }
      rethrow;
    }
  }

  /// Get pilot by license number
  Future<Pilot> getPilot(String licenseNumber) async {
    try {
      final response = await _api.get('${ApiConfig.pilots}/$licenseNumber');
      return Pilot.fromJson(response['data']);
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
              e,
              StackTrace.current,
              message: 'Failed to get pilot',
              metadata: {'licenseNumber': licenseNumber},
            );
      }
      rethrow;
    }
  }

  /// Check if pilot exists by license number
  Future<bool> pilotExists(String licenseNumber) async {
    try {
      await getPilot(licenseNumber);
      return true;
    } on ApiException catch (e) {
      if (e.isNotFound) {
        return false;
      }
      rethrow;
    }
  }
}
