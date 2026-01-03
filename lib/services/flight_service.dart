import '../config/api_config.dart';
import '../models/logbook_entry.dart';
import '../models/logbook_entry_short.dart';
import 'api_exception.dart';
import 'api_service.dart';
import 'error_service.dart';

/// Service for flight-related API operations
class FlightService {
  final ApiService _api = ApiService();

  /// Get all flights for a pilot (returns short format for list display)
  Future<List<LogbookEntryShort>> getFlightsForPilot(
      String licenseNumber) async {
    try {
      final response = await _api.get(
        '${ApiConfig.pilots}/$licenseNumber${ApiConfig.flights}',
      );

      final List<dynamic> flightsJson = response['data'] ?? [];
      return flightsJson
          .map((json) => LogbookEntry.fromJson(json).toShort())
          .toList();
    } on ApiException catch (e) {
      if (e.isServerError) {
        ErrorService().reporter.reportError(
              e,
              StackTrace.current,
              message: 'Failed to fetch flights',
              metadata: {'licenseNumber': licenseNumber},
            );
      }
      rethrow;
    }
  }

  /// Get a single flight by ID (returns full format)
  Future<LogbookEntry> getFlight(String id) async {
    try {
      final response = await _api.get('${ApiConfig.flights}/$id');
      return LogbookEntry.fromJson(response['data']);
    } on ApiException catch (e) {
      if (e.isServerError) {
        ErrorService().reporter.reportError(
              e,
              StackTrace.current,
              message: 'Failed to fetch flight',
              metadata: {'flightId': id},
            );
      }
      rethrow;
    }
  }

  /// Create a new flight entry
  Future<LogbookEntry> createFlight(LogbookEntry entry) async {
    try {
      final response = await _api.post(ApiConfig.flights, entry.toJson());
      return LogbookEntry.fromJson(response['data']);
    } on ApiException catch (e) {
      if (e.isServerError) {
        ErrorService().reporter.reportError(
              e,
              StackTrace.current,
              message: 'Failed to create flight',
              metadata: {
                'pilotLicense': entry.pilotLicense,
                'dep': entry.dep,
                'dest': entry.dest,
              },
            );
      }
      rethrow;
    }
  }
}
