import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../config/app_config.dart';
import '../database/converters.dart';
import '../database/database.dart';
import '../models/logbook_entry.dart';
import '../models/logbook_entry_short.dart';
import '../services/api_exception.dart';
import '../services/api_service.dart';
import '../services/error_service.dart';
import 'airport_repository.dart'; // For SyncResult

/// Sync status for local records
enum SyncStatus {
  pending, // Not yet synced to server
  synced,  // Successfully synced
  conflict, // Server has different version
}

/// Repository for flight data with local-first architecture.
///
/// All reads are served from the local SQLite database for instant access.
/// Writes are saved locally first, then queued for server sync.
/// Supports reactive streams for automatic UI updates.
class FlightRepository {
  final HyperlogDatabase _db;
  final ApiService _api;
  final ErrorService _errorService;
  final _uuid = const Uuid();

  FlightRepository({
    required HyperlogDatabase db,
    ApiService? api,
    ErrorService? errorService,
  })  : _db = db,
        _api = api ?? ApiService(),
        _errorService = errorService ?? ErrorService();

  // ==========================================================================
  // Local Read Operations (Instant, Offline-First)
  // ==========================================================================

  /// Get all flights for a user (instant local read)
  /// Returns short format for list display, sorted by date descending
  Future<List<LogbookEntryShort>> getFlightsForUser(String userId) async {
    final rows = await _db.getFlightsForUser(userId);
    return rows.map((row) => flightToShort(row)).toList();
  }

  /// Get all full flight entries for a user (for statistics)
  Future<List<LogbookEntry>> getFullFlightsForUser(String userId) async {
    final rows = await _db.getFlightsForUser(userId);
    return rows.map((row) => flightFromRow(row)).toList();
  }

  /// Watch flights for a user (reactive stream for UI)
  /// Emits new list whenever local data changes
  Stream<List<LogbookEntryShort>> watchFlightsForUser(String userId) {
    return _db.watchFlightsForUser(userId).map(
      (rows) => rows.map((row) => flightToShort(row)).toList(),
    );
  }

  /// Watch full flights for a user (for statistics)
  Stream<List<LogbookEntry>> watchFullFlightsForUser(String userId) {
    return _db.watchFlightsForUser(userId).map(
      (rows) => rows.map((row) => flightFromRow(row)).toList(),
    );
  }

  /// Get a single flight by ID
  Future<LogbookEntry?> getFlightById(String id) async {
    final row = await _db.getFlightById(id);
    return row != null ? flightFromRow(row) : null;
  }

  /// Get local flight count for a user
  Future<int> getFlightCount(String userId) async {
    return _db.getFlightCountForUser(userId);
  }

  /// Get sync status for a flight
  Future<SyncStatus?> getFlightSyncStatus(String id) async {
    final row = await _db.getFlightById(id);
    if (row == null) return null;
    return _parseSyncStatus(row.syncStatus);
  }

  /// Get count of pending (unsynced) flights
  Future<int> getPendingFlightCount() async {
    final pending = await _db.getPendingFlights();
    return pending.length;
  }

  /// Check if local database has flights for a user
  Future<bool> hasLocalData(String userId) async {
    final count = await getFlightCount(userId);
    return count > 0;
  }

  // ==========================================================================
  // Write Operations (Local-First with Sync Queue)
  // ==========================================================================

  /// Create a new flight entry
  ///
  /// Saves immediately to local database with `pending` sync status.
  /// The SyncService will upload to server when online.
  /// Returns the created entry with its generated ID.
  Future<LogbookEntry> createFlight(LogbookEntry entry) async {
    // Generate UUID if not provided
    final id = entry.id.isEmpty ? _uuid.v4() : entry.id;
    final now = DateTime.now();

    // Create entry with generated ID and timestamps
    final newEntry = LogbookEntry(
      id: id,
      creatorUUID: entry.creatorUUID,
      creatorLicense: entry.creatorLicense,
      flightDate: entry.flightDate,
      flightNumber: entry.flightNumber,
      dep: entry.dep,
      dest: entry.dest,
      depIcao: entry.depIcao,
      depIata: entry.depIata,
      destIcao: entry.destIcao,
      destIata: entry.destIata,
      blockOff: entry.blockOff,
      blockOn: entry.blockOn,
      aircraftType: entry.aircraftType,
      aircraftReg: entry.aircraftReg,
      flightTime: entry.flightTime,
      isPilotFlying: entry.isPilotFlying,
      approaches: entry.approaches,
      crew: entry.crew,
      verifications: entry.verifications,
      endorsements: entry.endorsements,
      createdAt: now,
      updatedAt: now,
    );

    // Save to local database with pending status
    final companion = flightToCompanion(newEntry, syncStatus: 'pending');
    await _db.upsertFlight(companion);

    return newEntry;
  }

  /// Update an existing flight entry
  ///
  /// Saves immediately to local database with `pending` sync status.
  /// The SyncService will upload to server when online.
  Future<LogbookEntry> updateFlight(LogbookEntry entry) async {
    final now = DateTime.now();

    // Create updated entry with new timestamp
    final updatedEntry = LogbookEntry(
      id: entry.id,
      creatorUUID: entry.creatorUUID,
      creatorLicense: entry.creatorLicense,
      flightDate: entry.flightDate,
      flightNumber: entry.flightNumber,
      dep: entry.dep,
      dest: entry.dest,
      depIcao: entry.depIcao,
      depIata: entry.depIata,
      destIcao: entry.destIcao,
      destIata: entry.destIata,
      blockOff: entry.blockOff,
      blockOn: entry.blockOn,
      aircraftType: entry.aircraftType,
      aircraftReg: entry.aircraftReg,
      flightTime: entry.flightTime,
      isPilotFlying: entry.isPilotFlying,
      approaches: entry.approaches,
      crew: entry.crew,
      verifications: entry.verifications,
      endorsements: entry.endorsements,
      createdAt: entry.createdAt,
      updatedAt: now,
    );

    // Save to local database with pending status
    final companion = flightToCompanion(updatedEntry, syncStatus: 'pending');
    await _db.upsertFlight(companion);

    return updatedEntry;
  }

  /// Delete a flight entry
  ///
  /// Removes from local database and queues deletion for server sync.
  /// If flight was never synced (pending), just removes locally.
  Future<void> deleteFlight(String id) async {
    // Check if flight exists and its sync status
    final existing = await _db.getFlightById(id);
    if (existing == null) return;

    final status = _parseSyncStatus(existing.syncStatus);

    // If flight was synced, queue deletion for server
    if (status == SyncStatus.synced) {
      await _db.addPendingDeletion(_uuid.v4(), 'flight', id);
    }

    // Remove from local database
    await _db.deleteFlightLocal(id);
  }

  // ==========================================================================
  // Sync Operations
  // ==========================================================================

  /// Sync flights from server (delta sync)
  /// Downloads changes since last sync and updates local storage.
  Future<SyncResult> syncFromServer(String userId) async {
    final startTime = DateTime.now();
    int recordsProcessed = 0;

    try {
      // Get last sync timestamp
      final lastSync = await _db.getLastSyncTime('flights');
      final sinceParam = lastSync?.toIso8601String();

      // Fetch changes from server
      final response = await _api.get(
        '${AppConfig.users}/$userId${AppConfig.flights}'
        '${sinceParam != null ? '?updatedSince=$sinceParam' : ''}',
      );

      final dataJson = response['data'] as List<dynamic>? ?? [];
      final flights = dataJson
          .map((json) => LogbookEntry.fromJson(json as Map<String, dynamic>))
          .toList();

      // Process deletions if provided
      final deletions = response['deletions'] as List<dynamic>? ?? [];
      for (final deletedId in deletions) {
        await _db.deleteFlightLocal(deletedId as String);
      }

      // Upsert received flights
      for (final flight in flights) {
        // Check if we have a local pending version
        final localFlight = await _db.getFlightById(flight.id);

        if (localFlight != null && localFlight.syncStatus == 'pending') {
          // Local pending changes exist - skip server version (last-write-wins)
          // The pending local version will be uploaded on next upload sync
          continue;
        }

        // Save server version as synced
        final companion = flightToCompanion(
          flight,
          syncStatus: 'synced',
          serverUpdatedAt: flight.updatedAt.toIso8601String(),
        );
        await _db.upsertFlight(companion);
        recordsProcessed++;
      }

      // Update sync metadata
      await _db.updateSyncMetadata(
        'flights',
        DateTime.now(),
        await _db.getFlightCountForUser(userId),
      );

      return SyncResult(
        entityType: 'flights',
        recordsProcessed: recordsProcessed,
        duration: DateTime.now().difference(startTime),
        success: true,
      );
    } catch (e, stackTrace) {
      _errorService.reporter.reportError(
        e,
        stackTrace,
        message: 'Failed to sync flights from server',
        metadata: {'userId': userId},
      );

      return SyncResult(
        entityType: 'flights',
        recordsProcessed: recordsProcessed,
        duration: DateTime.now().difference(startTime),
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Upload pending local changes to server
  /// Returns number of successfully uploaded changes.
  Future<UploadResult> uploadPendingChanges() async {
    int uploaded = 0;
    int failed = 0;
    final errors = <String>[];

    try {
      // Upload pending flights
      final pendingFlights = await _db.getPendingFlights();

      for (final row in pendingFlights) {
        try {
          final entry = flightFromRow(row);

          // Check if this is a new flight or an update
          // Try to create first, if conflict (409), update instead
          try {
            await _api.post(AppConfig.flights, entry.toJson());
          } on ApiException catch (e) {
            if (e.statusCode == 409) {
              // Flight exists, update instead
              await _api.put(
                '${AppConfig.flights}/${entry.id}?tier=standard',
                entry.toJson(),
              );
            } else {
              rethrow;
            }
          }

          // Mark as synced
          await _db.markFlightSynced(row.id, DateTime.now().toIso8601String());
          uploaded++;
        } catch (e) {
          failed++;
          errors.add('Flight ${row.id}: $e');
        }
      }

      // Process pending deletions
      final pendingDeletions = await _db.getAllPendingDeletions();

      for (final deletion in pendingDeletions) {
        if (deletion.entityType == 'flight') {
          try {
            await _api.delete('${AppConfig.flights}/${deletion.entityId}');
            await _db.removePendingDeletion(deletion.id);
            uploaded++;
          } catch (e) {
            // If 404, the flight was already deleted on server - remove from queue
            if (e is ApiException && e.statusCode == 404) {
              await _db.removePendingDeletion(deletion.id);
            } else {
              failed++;
              errors.add('Delete ${deletion.entityId}: $e');
            }
          }
        }
      }

      return UploadResult(
        uploaded: uploaded,
        failed: failed,
        errors: errors,
      );
    } catch (e, stackTrace) {
      _errorService.reporter.reportError(
        e,
        stackTrace,
        message: 'Failed to upload pending changes',
      );

      return UploadResult(
        uploaded: uploaded,
        failed: failed + 1,
        errors: [...errors, e.toString()],
      );
    }
  }

  /// Full bidirectional sync: upload local changes, then download server changes
  Future<void> fullSync(String userId) async {
    // Upload first to avoid overwriting local changes
    await uploadPendingChanges();
    // Then download server changes
    await syncFromServer(userId);
  }

  /// Check if there are pending changes to upload
  Future<bool> hasPendingChanges() async {
    final pendingFlights = await _db.getPendingFlights();
    final pendingDeletions = await _db.getAllPendingDeletions();
    return pendingFlights.isNotEmpty || pendingDeletions.isNotEmpty;
  }

  // ==========================================================================
  // Draft Operations
  // ==========================================================================

  /// Save a flight draft (for crash recovery)
  Future<void> saveDraft(String id, Map<String, dynamic> formData) async {
    await _db.saveDraft(id, _encodeJson(formData));
  }

  /// Get the latest draft
  Future<Map<String, dynamic>?> getLatestDraft() async {
    final draft = await _db.getLatestDraft();
    if (draft == null) return null;
    return _decodeJson(draft.formData);
  }

  /// Delete a draft
  Future<void> deleteDraft(String id) async {
    await _db.deleteDraft(id);
  }

  /// Delete all drafts
  Future<void> deleteAllDrafts() async {
    await _db.deleteAllDrafts();
  }

  // ==========================================================================
  // Private Helpers
  // ==========================================================================

  SyncStatus _parseSyncStatus(String status) {
    return switch (status) {
      'pending' => SyncStatus.pending,
      'synced' => SyncStatus.synced,
      'conflict' => SyncStatus.conflict,
      _ => SyncStatus.pending,
    };
  }

  String _encodeJson(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  Map<String, dynamic> _decodeJson(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}

/// Result of an upload operation
class UploadResult {
  final int uploaded;
  final int failed;
  final List<String> errors;

  UploadResult({
    required this.uploaded,
    required this.failed,
    required this.errors,
  });

  bool get success => failed == 0;

  @override
  String toString() {
    if (success) {
      return 'UploadResult: $uploaded uploaded successfully';
    }
    return 'UploadResult: $uploaded uploaded, $failed failed';
  }
}
