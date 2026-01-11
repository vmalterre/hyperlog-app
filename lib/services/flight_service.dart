import '../config/app_config.dart';
import '../models/logbook_entry.dart';
import '../models/logbook_entry_short.dart';
import '../models/flight_history.dart';
import 'api_exception.dart';
import 'api_service.dart';
import 'error_service.dart';

/// Service for flight-related API operations
class FlightService {
  final ApiService _api;
  final ErrorService _errorService;

  /// Constructor with optional dependency injection for testing
  FlightService({ApiService? api, ErrorService? errorService})
      : _api = api ?? ApiService(),
        _errorService = errorService ?? ErrorService();

  /// Get all flights for a pilot (returns short format for list display)
  Future<List<LogbookEntryShort>> getFlightsForPilot(
      String licenseNumber) async {
    try {
      final response = await _api.get(
        '${AppConfig.pilots}/$licenseNumber${AppConfig.flights}',
      );

      final List<dynamic> flightsJson = response['data'] ?? [];
      return flightsJson
          .map((json) => LogbookEntry.fromJson(json).toShort())
          .toList();
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
              e,
              StackTrace.current,
              message: 'Failed to fetch flights',
              metadata: {'licenseNumber': licenseNumber},
            );
      }
      rethrow;
    }
  }

  /// Get all flights for a pilot (returns full format for statistics)
  Future<List<LogbookEntry>> getFullFlightsForPilot(
      String licenseNumber) async {
    try {
      final response = await _api.get(
        '${AppConfig.pilots}/$licenseNumber${AppConfig.flights}',
      );

      final List<dynamic> flightsJson = response['data'] ?? [];
      return flightsJson
          .map((json) => LogbookEntry.fromJson(json))
          .toList();
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
              e,
              StackTrace.current,
              message: 'Failed to fetch flights for statistics',
              metadata: {'licenseNumber': licenseNumber},
            );
      }
      rethrow;
    }
  }

  /// Get a single flight by ID (returns full format)
  /// Pass [pilotLicense] to ensure correct tier routing on backend
  Future<LogbookEntry> getFlight(String id, {String? pilotLicense}) async {
    try {
      final queryParams = pilotLicense != null ? '?pilotLicense=$pilotLicense' : '';
      final response = await _api.get('${AppConfig.flights}/$id$queryParams');
      return LogbookEntry.fromJson(response['data']);
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
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
      final response = await _api.post(AppConfig.flights, entry.toJson());
      return LogbookEntry.fromJson(response['data']);
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
              e,
              StackTrace.current,
              message: 'Failed to create flight',
              metadata: {
                'creatorLicense': entry.creatorLicense,
                'dep': entry.dep,
                'dest': entry.dest,
              },
            );
      }
      rethrow;
    } catch (e) {
      // Handle parsing or other unexpected errors
      _errorService.reporter.reportError(
            e,
            StackTrace.current,
            message: 'Unexpected error creating flight',
            metadata: {
              'creatorLicense': entry.creatorLicense,
              'dep': entry.dep,
              'dest': entry.dest,
            },
          );
      throw ApiException(message: 'Failed to save flight. Please try again.');
    }
  }

  /// Update an existing flight entry
  Future<LogbookEntry> updateFlight(String id, LogbookEntry entry) async {
    try {
      final response = await _api.put('${AppConfig.flights}/$id', entry.toJson());
      return LogbookEntry.fromJson(response['data']);
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
              e,
              StackTrace.current,
              message: 'Failed to update flight',
              metadata: {'flightId': id},
            );
      }
      rethrow;
    }
  }

  /// Get flight history from blockchain
  Future<FlightHistory> getFlightHistory(String id) async {
    try {
      final response = await _api.get('${AppConfig.flights}/$id/history');
      return FlightHistory.fromJson(response['data']);
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
              e,
              StackTrace.current,
              message: 'Failed to fetch flight history',
              metadata: {'flightId': id},
            );
      }
      rethrow;
    }
  }

  /// Compute diffs between consecutive history versions
  List<VersionDiff> computeHistoryDiffs(FlightHistory history, {String? pilotName}) {
    final diffs = <VersionDiff>[];

    for (int i = 0; i < history.history.length; i++) {
      final current = history.history[i];
      final pilotLicense = current.entry?.creatorLicense;

      if (i == 0) {
        // First entry is creation
        diffs.add(VersionDiff(
          txId: current.txId,
          timestamp: current.timestamp,
          changes: [],
          isCreation: true,
          pilotLicense: pilotLicense,
          pilotName: pilotName,
        ));
        continue;
      }

      if (current.isDelete) {
        diffs.add(VersionDiff(
          txId: current.txId,
          timestamp: current.timestamp,
          changes: [],
          isDeletion: true,
          pilotLicense: pilotLicense,
          pilotName: pilotName,
        ));
        continue;
      }

      final previous = history.history[i - 1];
      if (previous.entry == null || current.entry == null) continue;

      final changes = _compareEntries(previous.entry!, current.entry!);

      diffs.add(VersionDiff(
        txId: current.txId,
        timestamp: current.timestamp,
        changes: changes,
        pilotLicense: pilotLicense,
        pilotName: pilotName,
        verifications: current.entry!.verifications,
        endorsements: current.entry!.endorsements,
      ));
    }

    return diffs.reversed.toList(); // Most recent first
  }

  List<FieldChange> _compareEntries(LogbookEntry old, LogbookEntry updated) {
    final changes = <FieldChange>[];

    void check(String field, String display, String? oldVal, String? newVal) {
      if (oldVal != newVal) {
        changes.add(FieldChange(
          fieldName: field,
          displayName: display,
          oldValue: oldVal,
          newValue: newVal,
        ));
      }
    }

    // Format helpers for dates/times
    String formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
    String formatTime(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    check('flightDate', 'Flight Date', formatDate(old.flightDate), formatDate(updated.flightDate));
    check('flightNumber', 'Flight Number', old.flightNumber, updated.flightNumber);
    check('dep', 'Departure', old.dep, updated.dep);
    check('dest', 'Destination', old.dest, updated.dest);
    check('blockOff', 'Block Off', formatTime(old.blockOff), formatTime(updated.blockOff));
    check('blockOn', 'Block On', formatTime(old.blockOn), formatTime(updated.blockOn));
    check('aircraftType', 'Aircraft Type', old.aircraftType, updated.aircraftType);
    check('aircraftReg', 'Registration', old.aircraftReg, updated.aircraftReg);
    check('flightTime', 'Flight Time', old.flightTime.formatted, updated.flightTime.formatted);
    check('landings', 'Landings', old.totalLandings.total.toString(), updated.totalLandings.total.toString());
    check('role', 'Role', old.creatorCrew?.primaryRole ?? '', updated.creatorCrew?.primaryRole ?? '');
    check('remarks', 'Remarks', old.creatorCrew?.remarks ?? '', updated.creatorCrew?.remarks ?? '');
    check('trustLevel', 'Trust Level', old.trustLevel.name.toUpperCase(), updated.trustLevel.name.toUpperCase());

    return changes;
  }
}
