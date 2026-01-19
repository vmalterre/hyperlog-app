import '../config/app_config.dart';
import '../models/aircraft_type.dart';
import '../models/user_aircraft_type.dart';
import '../models/user_aircraft_registration.dart';
import 'api_exception.dart';
import 'api_service.dart';
import 'error_service.dart';

/// Service for aircraft-related API operations
class AircraftService {
  final ApiService _api;
  final ErrorService _errorService;

  /// Constructor with optional dependency injection for testing
  AircraftService({ApiService? api, ErrorService? errorService})
      : _api = api ?? ApiService(),
        _errorService = errorService ?? ErrorService();

  // ===========================================================================
  // Global Aircraft Types (read-only)
  // ===========================================================================

  /// Search global aircraft types for autocomplete
  Future<List<AircraftType>> searchAircraftTypes(
    String query, {
    int limit = 10,
  }) async {
    try {
      final encodedQuery = Uri.encodeQueryComponent(query);
      final response = await _api.get(
        '${AppConfig.aircraftTypes}/search?q=$encodedQuery&limit=$limit',
      );
      final data = response['data'] as List;
      return data
          .map((json) => AircraftType.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to search aircraft types',
          metadata: {'query': query},
        );
      }
      rethrow;
    }
  }

  /// Get aircraft type by ICAO designator
  Future<AircraftType?> getAircraftType(String designator) async {
    try {
      final response = await _api.get(
        '${AppConfig.aircraftTypes}/$designator',
      );
      return AircraftType.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.isNotFound) {
        return null;
      }
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to get aircraft type',
          metadata: {'designator': designator},
        );
      }
      rethrow;
    }
  }

  // ===========================================================================
  // User Aircraft Types
  // ===========================================================================

  /// Get all aircraft types for a user
  Future<List<UserAircraftType>> getUserAircraftTypes(String userId) async {
    try {
      final response = await _api.get(
        '${AppConfig.users}/$userId/aircraft-types',
      );
      final data = response['data'] as List;
      return data
          .map(
              (json) => UserAircraftType.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to get user aircraft types',
          metadata: {'userId': userId},
        );
      }
      rethrow;
    }
  }

  /// Add an aircraft type to user's list
  Future<UserAircraftType> addUserAircraftType(
    String userId,
    int aircraftTypeId, {
    bool? multiEngine,
    bool? multiPilot,
    String? engineType,
    bool? complex,
    bool? highPerformance,
    String? category,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'aircraftTypeId': aircraftTypeId,
        if (multiEngine != null) 'multiEngine': multiEngine,
        if (multiPilot != null) 'multiPilot': multiPilot,
        if (engineType != null) 'engineType': engineType,
        if (complex != null) 'complex': complex,
        if (highPerformance != null) 'highPerformance': highPerformance,
        if (category != null) 'category': category,
        if (notes != null) 'notes': notes,
      };

      final response = await _api.post(
        '${AppConfig.users}/$userId/aircraft-types',
        body,
      );
      return UserAircraftType.fromJson(
          response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to add user aircraft type',
          metadata: {'userId': userId, 'aircraftTypeId': aircraftTypeId},
        );
      }
      rethrow;
    }
  }

  /// Update a user aircraft type
  Future<UserAircraftType> updateUserAircraftType(
    String userId,
    String id, {
    bool? multiEngine,
    bool? multiPilot,
    String? engineType,
    bool? complex,
    bool? highPerformance,
    String? category,
    String? variant,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        if (multiEngine != null) 'multiEngine': multiEngine,
        if (multiPilot != null) 'multiPilot': multiPilot,
        if (engineType != null) 'engineType': engineType,
        if (complex != null) 'complex': complex,
        if (highPerformance != null) 'highPerformance': highPerformance,
        if (category != null) 'category': category,
        if (variant != null) 'variant': variant,
        if (notes != null) 'notes': notes,
      };

      final response = await _api.put(
        '${AppConfig.users}/$userId/aircraft-types/$id',
        body,
      );
      return UserAircraftType.fromJson(
          response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to update user aircraft type',
          metadata: {'userId': userId, 'id': id},
        );
      }
      rethrow;
    }
  }

  /// Delete a user aircraft type
  Future<bool> deleteUserAircraftType(String userId, String id) async {
    try {
      final response = await _api.delete(
        '${AppConfig.users}/$userId/aircraft-types/$id',
      );
      return response['data']['deleted'] == true;
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to delete user aircraft type',
          metadata: {'userId': userId, 'id': id},
        );
      }
      rethrow;
    }
  }

  // ===========================================================================
  // User Aircraft Registrations
  // ===========================================================================

  /// Get all aircraft registrations for a user
  Future<List<UserAircraftRegistration>> getUserAircraftRegistrations(
    String userId,
  ) async {
    try {
      final response = await _api.get(
        '${AppConfig.users}/$userId/aircraft-registrations',
      );
      final data = response['data'] as List;
      return data
          .map((json) =>
              UserAircraftRegistration.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to get user aircraft registrations',
          metadata: {'userId': userId},
        );
      }
      rethrow;
    }
  }

  /// Lookup a registration by registration string
  Future<UserAircraftRegistration?> lookupRegistration(
    String userId,
    String registration,
  ) async {
    try {
      final encoded = Uri.encodeComponent(registration);
      final response = await _api.get(
        '${AppConfig.users}/$userId/aircraft-registrations/lookup/$encoded',
      );
      return UserAircraftRegistration.fromJson(
          response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.isNotFound) {
        return null;
      }
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to lookup registration',
          metadata: {'userId': userId, 'registration': registration},
        );
      }
      rethrow;
    }
  }

  /// Add an aircraft registration
  Future<UserAircraftRegistration> addUserAircraftRegistration(
    String userId,
    String registration,
    String userAircraftTypeId, {
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'registration': registration,
        'userAircraftTypeId': userAircraftTypeId,
        if (notes != null) 'notes': notes,
      };

      final response = await _api.post(
        '${AppConfig.users}/$userId/aircraft-registrations',
        body,
      );
      return UserAircraftRegistration.fromJson(
          response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to add aircraft registration',
          metadata: {
            'userId': userId,
            'registration': registration,
            'userAircraftTypeId': userAircraftTypeId,
          },
        );
      }
      rethrow;
    }
  }

  /// Update an aircraft registration
  Future<UserAircraftRegistration> updateUserAircraftRegistration(
    String userId,
    String id, {
    String? registration,
    String? userAircraftTypeId,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        if (registration != null) 'registration': registration,
        if (userAircraftTypeId != null) 'userAircraftTypeId': userAircraftTypeId,
        if (notes != null) 'notes': notes,
      };

      final response = await _api.put(
        '${AppConfig.users}/$userId/aircraft-registrations/$id',
        body,
      );
      return UserAircraftRegistration.fromJson(
          response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to update aircraft registration',
          metadata: {'userId': userId, 'id': id},
        );
      }
      rethrow;
    }
  }

  /// Delete an aircraft registration
  Future<bool> deleteUserAircraftRegistration(String userId, String id) async {
    try {
      final response = await _api.delete(
        '${AppConfig.users}/$userId/aircraft-registrations/$id',
      );
      return response['data']['deleted'] == true;
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to delete aircraft registration',
          metadata: {'userId': userId, 'id': id},
        );
      }
      rethrow;
    }
  }
}
