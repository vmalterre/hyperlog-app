import '../config/app_config.dart';
import '../models/user_simulator.dart';
import 'api_exception.dart';
import 'api_service.dart';
import 'error_service.dart';

/// Service for simulator-related API operations
class SimulatorService {
  final ApiService _api;
  final ErrorService _errorService;

  /// Constructor with optional dependency injection for testing
  SimulatorService({ApiService? api, ErrorService? errorService})
      : _api = api ?? ApiService(),
        _errorService = errorService ?? ErrorService();

  // ===========================================================================
  // User Simulator Types (Level 1)
  // ===========================================================================

  /// Get all simulator types for a user
  Future<List<UserSimulatorType>> getUserSimulatorTypes(String userId) async {
    try {
      final response = await _api.get(
        '${AppConfig.users}/$userId/simulator-types',
      );
      final data = response['data'] as List;
      return data
          .map((json) => UserSimulatorType.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to get user simulator types',
          metadata: {'userId': userId},
        );
      }
      rethrow;
    }
  }

  /// Get a specific simulator type by ID
  Future<UserSimulatorType?> getSimulatorTypeById(
    String userId,
    String id,
  ) async {
    try {
      final response = await _api.get(
        '${AppConfig.users}/$userId/simulator-types/$id',
      );
      return UserSimulatorType.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.isNotFound) {
        return null;
      }
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to get simulator type',
          metadata: {'userId': userId, 'id': id},
        );
      }
      rethrow;
    }
  }

  /// Add a simulator type to user's list
  Future<UserSimulatorType> addUserSimulatorType(
    String userId,
    int? aircraftTypeId,
    FstdCategory fstdCategory, {
    String? fstdLevel,
    String? deviceManufacturer,
    String? deviceModel,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        if (aircraftTypeId != null) 'aircraftTypeId': aircraftTypeId,
        'fstdCategory': UserSimulatorType.categoryToString(fstdCategory),
        if (fstdLevel != null) 'fstdLevel': fstdLevel,
        if (deviceManufacturer != null) 'deviceManufacturer': deviceManufacturer,
        if (deviceModel != null) 'deviceModel': deviceModel,
        if (notes != null) 'notes': notes,
      };

      final response = await _api.post(
        '${AppConfig.users}/$userId/simulator-types',
        body,
      );
      return UserSimulatorType.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to add simulator type',
          metadata: {
            'userId': userId,
            'aircraftTypeId': aircraftTypeId,
            'fstdCategory': UserSimulatorType.categoryToString(fstdCategory),
          },
        );
      }
      rethrow;
    }
  }

  /// Update a user simulator type
  ///
  /// Pass explicit null values to clear optional fields.
  /// Only fields included in the request will be updated.
  Future<UserSimulatorType> updateUserSimulatorType(
    String userId,
    String id, {
    required int? aircraftTypeId,
    required FstdCategory fstdCategory,
    required String? fstdLevel,
    required String? deviceManufacturer,
    required String? deviceModel,
    required String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'aircraftTypeId': aircraftTypeId,  // Send null to clear
        'fstdCategory': UserSimulatorType.categoryToString(fstdCategory),
        'fstdLevel': fstdLevel,  // Send null to clear
        'deviceManufacturer': deviceManufacturer,  // Send null to clear
        'deviceModel': deviceModel,  // Send null to clear
        'notes': notes,  // Send null to clear
      };

      final response = await _api.put(
        '${AppConfig.users}/$userId/simulator-types/$id',
        body,
      );
      return UserSimulatorType.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to update simulator type',
          metadata: {'userId': userId, 'id': id},
        );
      }
      rethrow;
    }
  }

  /// Delete a user simulator type (cascades to registrations)
  Future<bool> deleteUserSimulatorType(String userId, String id) async {
    try {
      final response = await _api.delete(
        '${AppConfig.users}/$userId/simulator-types/$id',
      );
      return response['data']['deleted'] == true;
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to delete simulator type',
          metadata: {'userId': userId, 'id': id},
        );
      }
      rethrow;
    }
  }

  // ===========================================================================
  // User Simulator Registrations (Level 2)
  // ===========================================================================

  /// Get all simulator registrations for a user
  Future<List<UserSimulatorRegistration>> getUserSimulatorRegistrations(
    String userId,
  ) async {
    try {
      final response = await _api.get(
        '${AppConfig.users}/$userId/simulator-registrations',
      );
      final data = response['data'] as List;
      return data
          .map((json) =>
              UserSimulatorRegistration.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to get user simulator registrations',
          metadata: {'userId': userId},
        );
      }
      rethrow;
    }
  }

  /// Get a specific simulator registration by ID
  Future<UserSimulatorRegistration?> getSimulatorRegistrationById(
    String userId,
    String id,
  ) async {
    try {
      final response = await _api.get(
        '${AppConfig.users}/$userId/simulator-registrations/$id',
      );
      return UserSimulatorRegistration.fromJson(
        response['data'] as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      if (e.isNotFound) {
        return null;
      }
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to get simulator registration',
          metadata: {'userId': userId, 'id': id},
        );
      }
      rethrow;
    }
  }

  /// Lookup a simulator registration by registration string
  Future<UserSimulatorRegistration?> lookupSimulatorRegistration(
    String userId,
    String registration,
  ) async {
    try {
      final encoded = Uri.encodeComponent(registration);
      final response = await _api.get(
        '${AppConfig.users}/$userId/simulator-registrations/lookup/$encoded',
      );
      return UserSimulatorRegistration.fromJson(
        response['data'] as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      if (e.isNotFound) {
        return null;
      }
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to lookup simulator registration',
          metadata: {'userId': userId, 'registration': registration},
        );
      }
      rethrow;
    }
  }

  /// Add a simulator registration to a type
  Future<UserSimulatorRegistration> addUserSimulatorRegistration(
    String userId,
    String userSimulatorTypeId,
    String registration, {
    String? trainingFacility,
  }) async {
    try {
      final body = <String, dynamic>{
        'userSimulatorTypeId': userSimulatorTypeId,
        'registration': registration,
        if (trainingFacility != null) 'trainingFacility': trainingFacility,
      };

      final response = await _api.post(
        '${AppConfig.users}/$userId/simulator-registrations',
        body,
      );
      return UserSimulatorRegistration.fromJson(
        response['data'] as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to add simulator registration',
          metadata: {
            'userId': userId,
            'userSimulatorTypeId': userSimulatorTypeId,
            'registration': registration,
          },
        );
      }
      rethrow;
    }
  }

  /// Update a user simulator registration
  Future<UserSimulatorRegistration> updateUserSimulatorRegistration(
    String userId,
    String id, {
    String? registration,
    String? trainingFacility,
  }) async {
    try {
      final body = <String, dynamic>{
        if (registration != null) 'registration': registration,
        if (trainingFacility != null) 'trainingFacility': trainingFacility,
      };

      final response = await _api.put(
        '${AppConfig.users}/$userId/simulator-registrations/$id',
        body,
      );
      return UserSimulatorRegistration.fromJson(
        response['data'] as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to update simulator registration',
          metadata: {'userId': userId, 'id': id},
        );
      }
      rethrow;
    }
  }

  /// Delete a user simulator registration
  Future<bool> deleteUserSimulatorRegistration(
    String userId,
    String id,
  ) async {
    try {
      final response = await _api.delete(
        '${AppConfig.users}/$userId/simulator-registrations/$id',
      );
      return response['data']['deleted'] == true;
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to delete simulator registration',
          metadata: {'userId': userId, 'id': id},
        );
      }
      rethrow;
    }
  }
}
