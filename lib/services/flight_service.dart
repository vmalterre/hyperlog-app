import '../config/app_config.dart';
import '../database/converters.dart';
import '../database/database_provider.dart';
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

  // ==========================================
  // Flight Operations (UUID-based - preferred)
  // ==========================================

  /// Get all flights for a user by UUID (returns short format for list display)
  /// This is the preferred method using the UUID-based route
  Future<List<LogbookEntryShort>> getFlightsForUser(String userId) async {
    try {
      final response = await _api.get(
        '${AppConfig.users}/$userId${AppConfig.flights}',
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
              metadata: {'userId': userId},
            );
      }
      rethrow;
    }
  }

  /// Get all flights for a user by UUID (returns full format for statistics)
  /// This is the preferred method using the UUID-based route
  Future<List<LogbookEntry>> getFullFlightsForUser(String userId) async {
    try {
      final response = await _api.get(
        '${AppConfig.users}/$userId${AppConfig.flights}',
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
              metadata: {'userId': userId},
            );
      }
      rethrow;
    }
  }

  // ==========================================
  // Flight Operations (deprecated - use UUID methods above)
  // ==========================================

  /// Get all flights for a pilot (returns short format for list display)
  /// @deprecated Use getFlightsForUser instead
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
  /// @deprecated Use getFullFlightsForUser instead
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
  /// Pass [userId] to ensure correct tier routing on backend
  Future<LogbookEntry> getFlight(String id, {String? userId}) async {
    try {
      final queryParams = userId != null ? '?userId=$userId' : '';
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
  /// Saves to server first, then to local database for offline access
  Future<LogbookEntry> createFlight(LogbookEntry entry) async {
    try {
      final response = await _api.post(AppConfig.flights, entry.toJson());
      final createdEntry = LogbookEntry.fromJson(response['data']);

      // Save to local database so it appears in the list immediately
      // (only if database is initialized - may not be in tests)
      if (DatabaseProvider.instance.isInitialized) {
        final db = DatabaseProvider.instance.database;
        final companion = flightToCompanion(createdEntry, syncStatus: 'synced');
        await db.upsertFlight(companion);
      }

      return createdEntry;
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
  /// Pass [tier] to route to correct storage (expired=PostgreSQL, active=blockchain)
  /// Saves to server first, then updates local database
  Future<LogbookEntry> updateFlight(String id, LogbookEntry entry, {String tier = 'active'}) async {
    try {
      final response = await _api.put('${AppConfig.flights}/$id?tier=$tier', entry.toJson());
      final updatedEntry = LogbookEntry.fromJson(response['data']);

      // Update local database so changes appear immediately
      // (only if database is initialized - may not be in tests)
      if (DatabaseProvider.instance.isInitialized) {
        final db = DatabaseProvider.instance.database;
        final companion = flightToCompanion(updatedEntry, syncStatus: 'synced');
        await db.upsertFlight(companion);
      }

      return updatedEntry;
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

  /// Delete a flight entry (Standard tier only - blockchain entries cannot be deleted)
  /// Deletes from server first, then from local database
  Future<void> deleteFlight(String id) async {
    try {
      await _api.delete('${AppConfig.flights}/$id');

      // Remove from local database so it disappears from list immediately
      // (only if database is initialized - may not be in tests)
      if (DatabaseProvider.instance.isInitialized) {
        final db = DatabaseProvider.instance.database;
        await db.deleteFlightLocal(id);
      }
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
              e,
              StackTrace.current,
              message: 'Failed to delete flight',
              metadata: {'flightId': id},
            );
      }
      rethrow;
    }
  }

  /// Delete all flights for a user (Alpha testing only)
  /// Deletes from both server and returns count for local deletion
  Future<int> deleteAllFlightsForUser(String userId) async {
    try {
      final response = await _api.delete('${AppConfig.users}/$userId${AppConfig.flights}');
      return response['data']?['deletedCount'] ?? 0;
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
              e,
              StackTrace.current,
              message: 'Failed to delete all flights',
              metadata: {'userId': userId},
            );
      }
      rethrow;
    }
  }

  /// Get flight history from blockchain
  /// Pass [userId] for tier routing (required for Official tier to access history)
  Future<FlightHistory> getFlightHistory(String id, {String? userId}) async {
    try {
      final queryParams = userId != null ? '?userId=$userId' : '';
      final response = await _api.get('${AppConfig.flights}/$id/history$queryParams');
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

      // Try to get pilot name from the entry's crew (creator crew member)
      // Fall back to the passed-in pilotName if not available
      final entryPilotName = current.entry?.creatorCrew?.pilotName ?? pilotName;

      if (i == 0) {
        // First entry is creation
        diffs.add(VersionDiff(
          txId: current.txId,
          timestamp: current.timestamp,
          changes: [],
          isCreation: true,
          pilotLicense: pilotLicense,
          pilotName: entryPilotName,
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
          pilotName: entryPilotName,
        ));
        continue;
      }

      final previous = history.history[i - 1];
      if (previous.entry == null || current.entry == null) continue;

      final changes = _compareEntries(previous.entry!, current.entry!);

      // Detect if new verifications or endorsements were added
      final prevVerificationCount = previous.entry!.verifications.length;
      final currVerificationCount = current.entry!.verifications.length;
      final hasNewVerification = currVerificationCount > prevVerificationCount;

      final prevEndorsementCount = previous.entry!.endorsements.length;
      final currEndorsementCount = current.entry!.endorsements.length;
      final hasNewEndorsement = currEndorsementCount > prevEndorsementCount;

      diffs.add(VersionDiff(
        txId: current.txId,
        timestamp: current.timestamp,
        changes: changes,
        hasNewVerification: hasNewVerification,
        hasNewEndorsement: hasNewEndorsement,
        pilotLicense: pilotLicense,
        pilotName: entryPilotName,
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
    check('aircraftReg', 'Registration', old.displayReg, updated.displayReg);
    check('flightTime', 'Block Time', old.flightTime.formatted, updated.flightTime.formatted);
    check('landings', 'Landings', old.totalLandings.total.toString(), updated.totalLandings.total.toString());
    check('role', 'Role', old.creatorCrew?.primaryRole ?? '', updated.creatorCrew?.primaryRole ?? '');
    check('remarks', 'Remarks', old.creatorCrew?.remarks ?? '', updated.creatorCrew?.remarks ?? '');
    check('trustLevel', 'Trust Level', old.trustLevel.name.toUpperCase(), updated.trustLevel.name.toUpperCase());

    return changes;
  }
}
