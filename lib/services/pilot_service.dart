import '../config/app_config.dart';
import '../models/pilot.dart';
import '../models/saved_pilot.dart';
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
      final response = await _api.post(AppConfig.pilots, {
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
  /// @deprecated Use getPilotByEmail for login flow
  Future<Pilot> getPilot(String licenseNumber) async {
    try {
      final response = await _api.get('${AppConfig.pilots}/$licenseNumber');
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

  /// Get pilot by email (primary method for login flow)
  /// Returns full profile with UUID for subsequent API operations
  Future<Pilot> getPilotByEmail(String email) async {
    try {
      final encodedEmail = Uri.encodeComponent(email);
      final response = await _api.get('${AppConfig.users}/email/$encodedEmail');
      return Pilot.fromJson(response['data']);
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
              e,
              StackTrace.current,
              message: 'Failed to get pilot by email',
              metadata: {'email': email},
            );
      }
      rethrow;
    }
  }

  /// Create a new user in PostgreSQL (auto-registration on first sign-in)
  Future<Pilot> createUser({
    required String email,
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? firebaseUid,
  }) async {
    try {
      final response = await _api.post(AppConfig.users, {
        'email': email,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (firebaseUid != null) 'firebaseUid': firebaseUid,
      });
      return Pilot.fromJson(response['data']);
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to create user',
          metadata: {'email': email},
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

  // ==========================================
  // Saved Pilots Operations (UUID-based - preferred)
  // ==========================================

  /// Get all saved pilots by user UUID (preferred method)
  Future<List<SavedPilot>> getSavedPilotsByUserId(String userId) async {
    try {
      final response = await _api.get(
        '${AppConfig.users}/$userId/saved-pilots',
      );
      final data = response['data'] as List;
      return data.map((json) => SavedPilot.fromJson(json)).toList();
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to get saved pilots',
          metadata: {'userId': userId},
        );
      }
      rethrow;
    }
  }

  /// Create a saved pilot by user UUID (preferred method)
  Future<SavedPilot> createSavedPilotByUserId(
    String userId,
    String name,
  ) async {
    try {
      final response = await _api.post(
        '${AppConfig.users}/$userId/saved-pilots',
        {'name': name},
      );
      return SavedPilot.fromJson(response['data']);
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to create saved pilot',
          metadata: {'userId': userId, 'name': name},
        );
      }
      rethrow;
    }
  }

  /// Update pilot name by user UUID (preferred method)
  Future<int> updateSavedPilotNameByUserId(
    String userId,
    String oldName,
    String newName,
  ) async {
    try {
      final response = await _api.post(
        '${AppConfig.users}/$userId/saved-pilots/rename',
        {'oldName': oldName, 'newName': newName},
      );
      return response['data']['updatedCount'] as int;
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to update saved pilot',
          metadata: {
            'userId': userId,
            'oldName': oldName,
            'newName': newName,
          },
        );
      }
      rethrow;
    }
  }

  /// Delete pilot by user UUID (preferred method)
  Future<int> deleteSavedPilotByUserId(
    String userId,
    String name,
  ) async {
    try {
      final response = await _api.post(
        '${AppConfig.users}/$userId/saved-pilots/delete',
        {'name': name},
      );
      return response['data']['deletedCount'] as int;
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to delete saved pilot',
          metadata: {'userId': userId, 'name': name},
        );
      }
      rethrow;
    }
  }

  /// Delete all saved pilots by user UUID (bulk delete)
  Future<int> deleteAllSavedPilotsByUserId(String userId) async {
    try {
      final response = await _api.delete(
        '${AppConfig.users}/$userId/saved-pilots',
      );
      return response['data']['deletedCount'] as int;
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to delete all saved pilots',
          metadata: {'userId': userId},
        );
      }
      rethrow;
    }
  }

  /// Get flight count by user UUID (preferred method)
  Future<int> getFlightCountForPilotByUserId(
    String userId,
    String name,
  ) async {
    try {
      final response = await _api.post(
        '${AppConfig.users}/$userId/saved-pilots/flight-count',
        {'name': name},
      );
      return response['data']['flightCount'] as int;
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to get flight count for pilot',
          metadata: {'userId': userId, 'name': name},
        );
      }
      rethrow;
    }
  }

  // ==========================================
  // Profile Operations (UUID-based)
  // ==========================================

  /// Update the pilot's profile photo URL
  /// Pass null to remove the photo
  Future<Pilot> updateProfilePhotoUrl(String userId, String? photoUrl) async {
    try {
      final response = await _api.put(
        '${AppConfig.users}/$userId',
        {'photoUrl': photoUrl},
      );
      return Pilot.fromJson(response['data']);
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to update profile photo',
          metadata: {'userId': userId},
        );
      }
      rethrow;
    }
  }

  // ==========================================
  // GDPR Operations (UUID-based)
  // ==========================================

  /// Request GDPR deletion of user account (anonymize personal data)
  Future<void> deleteUserAccount(String userId) async {
    try {
      await _api.post(
        '${AppConfig.users}/$userId/gdpr/delete',
        {},
      );
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to request GDPR deletion',
          metadata: {'userId': userId},
        );
      }
      rethrow;
    }
  }

  /// Export all user data (GDPR data portability)
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final response = await _api.get(
        '${AppConfig.users}/$userId/gdpr/export',
      );
      return response['data'] as Map<String, dynamic>;
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to export user data',
          metadata: {'userId': userId},
        );
      }
      rethrow;
    }
  }

  // ==========================================
  // Saved Pilots Operations (deprecated - use UUID methods above)
  // ==========================================

  /// Get all saved pilots for a pilot (merged: saved_pilots + distinct crew names)
  /// @deprecated Use getSavedPilotsByUserId instead
  Future<List<SavedPilot>> getSavedPilots(String licenseNumber) async {
    try {
      final response = await _api.get(
        '${AppConfig.pilots}/$licenseNumber/saved-pilots',
      );
      final data = response['data'] as List;
      return data.map((json) => SavedPilot.fromJson(json)).toList();
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to get saved pilots',
          metadata: {'licenseNumber': licenseNumber},
        );
      }
      rethrow;
    }
  }

  /// Create a saved pilot (manual add)
  Future<SavedPilot> createSavedPilot(
    String licenseNumber,
    String name,
  ) async {
    try {
      final response = await _api.post(
        '${AppConfig.pilots}/$licenseNumber/saved-pilots',
        {'name': name},
      );
      return SavedPilot.fromJson(response['data']);
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to create saved pilot',
          metadata: {'licenseNumber': licenseNumber, 'name': name},
        );
      }
      rethrow;
    }
  }

  /// Update pilot name across all flights
  Future<int> updateSavedPilotName(
    String licenseNumber,
    String oldName,
    String newName,
  ) async {
    try {
      final response = await _api.post(
        '${AppConfig.pilots}/$licenseNumber/saved-pilots/rename',
        {'oldName': oldName, 'newName': newName},
      );
      return response['data']['updatedCount'] as int;
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to update saved pilot',
          metadata: {
            'licenseNumber': licenseNumber,
            'oldName': oldName,
            'newName': newName,
          },
        );
      }
      rethrow;
    }
  }

  /// Delete pilot from saved_pilots and all crew entries
  Future<int> deleteSavedPilot(
    String licenseNumber,
    String name,
  ) async {
    try {
      final response = await _api.post(
        '${AppConfig.pilots}/$licenseNumber/saved-pilots/delete',
        {'name': name},
      );
      return response['data']['deletedCount'] as int;
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to delete saved pilot',
          metadata: {'licenseNumber': licenseNumber, 'name': name},
        );
      }
      rethrow;
    }
  }

  /// Get count of flights that would be affected by deleting a pilot
  Future<int> getFlightCountForPilot(
    String licenseNumber,
    String name,
  ) async {
    try {
      final response = await _api.post(
        '${AppConfig.pilots}/$licenseNumber/saved-pilots/flight-count',
        {'name': name},
      );
      return response['data']['flightCount'] as int;
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to get flight count for pilot',
          metadata: {'licenseNumber': licenseNumber, 'name': name},
        );
      }
      rethrow;
    }
  }
}
