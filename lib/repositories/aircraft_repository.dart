import '../config/app_config.dart';
import '../database/converters.dart';
import '../database/database.dart';
import '../models/aircraft_type.dart' as models;
import '../services/api_service.dart';
import '../services/error_service.dart';
import 'airport_repository.dart'; // For SyncResult

/// Repository for aircraft type data with local-first architecture.
///
/// Reads are served from the local SQLite database for instant offline access.
/// Sync operations fetch bulk data from the server and update local storage.
class AircraftRepository {
  final HyperlogDatabase _db;
  final ApiService _api;
  final ErrorService _errorService;

  AircraftRepository({
    required HyperlogDatabase db,
    ApiService? api,
    ErrorService? errorService,
  })  : _db = db,
        _api = api ?? ApiService(),
        _errorService = errorService ?? ErrorService();

  // ==========================================================================
  // Local Operations (Offline-First)
  // ==========================================================================

  /// Search aircraft types locally (instant, offline-capable)
  /// Returns up to [limit] results matching designator, manufacturer, or model
  Future<List<models.AircraftType>> search(String query, {int limit = 10}) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final rows = await _db.searchAircraftTypes(query, limit: limit);
    return rows.map((row) => aircraftTypeFromRow(row)).toList();
  }

  /// Get aircraft type by ICAO designator locally
  Future<models.AircraftType?> getByDesignator(String designator) async {
    final row = await _db.getAircraftTypeByDesignator(designator);
    return row != null ? aircraftTypeFromRow(row) : null;
  }

  /// Get local aircraft type count
  Future<int> getLocalCount() async {
    return _db.getAircraftTypeCount();
  }

  /// Check if local database has aircraft types
  Future<bool> hasLocalData() async {
    final count = await getLocalCount();
    return count > 0;
  }

  /// Clear all local aircraft types and sync fresh from server
  Future<SyncResult> clearAndSync({
    void Function(double progress, String message)? onProgress,
  }) async {
    onProgress?.call(0.0, 'Clearing local aircraft types...');
    await _db.clearAircraftTypes();
    await _db.deleteSyncMetadata('aircraft_types');
    return syncFromServer(onProgress: onProgress);
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    return _db.getLastSyncTime('aircraft_types');
  }

  // ==========================================================================
  // Sync Operations
  // ==========================================================================

  /// Sync aircraft types from server (resumable)
  /// Downloads all aircraft types in batches and stores locally.
  /// Resumes from last position if interrupted.
  /// Use [onProgress] to track download progress (0.0 to 1.0)
  Future<SyncResult> syncFromServer({
    void Function(double progress, String message)? onProgress,
  }) async {
    final startTime = DateTime.now();
    const pageSize = 2000;

    try {
      // First, get total count from stats
      onProgress?.call(0.0, 'Checking aircraft database...');
      final stats = await _fetchStats();
      final totalExpected = stats['count'] as int? ?? 0;

      if (totalExpected == 0) {
        return SyncResult(
          entityType: 'aircraft_types',
          recordsProcessed: 0,
          duration: DateTime.now().difference(startTime),
          success: true,
        );
      }

      // Check current progress - resume from where we left off
      final currentCount = await getLocalCount();
      int page = (currentCount ~/ pageSize) + 1;
      int totalInserted = currentCount;

      if (currentCount > 0 && currentCount < totalExpected) {
        onProgress?.call(
          currentCount / totalExpected,
          'Resuming aircraft download ($currentCount / $totalExpected)...',
        );
      }

      // Download in batches
      bool hasMore = currentCount < totalExpected;
      while (hasMore) {
        final progressPercent = totalExpected > 0
            ? (totalInserted / totalExpected).clamp(0.0, 0.95)
            : 0.0;
        onProgress?.call(
          progressPercent,
          'Downloading aircraft types ($totalInserted / $totalExpected)...',
        );

        final result = await _fetchPage(page, pageSize);
        final aircraftTypes = result['data'] as List<models.AircraftType>;
        final pagination = result['pagination'] as Map<String, dynamic>;

        if (aircraftTypes.isNotEmpty) {
          // Convert to database companions and bulk insert
          final companions = aircraftTypes.map((a) => aircraftTypeToCompanion(a)).toList();
          await _db.insertAircraftTypes(companions);
          totalInserted += aircraftTypes.length;
        }

        hasMore = pagination['hasMore'] as bool? ?? false;
        page++;
      }

      // Update sync metadata - mark as complete
      await _db.updateSyncMetadata('aircraft_types', DateTime.now(), totalInserted);

      onProgress?.call(1.0, 'Aircraft sync complete');

      return SyncResult(
        entityType: 'aircraft_types',
        recordsProcessed: totalInserted,
        duration: DateTime.now().difference(startTime),
        success: true,
      );
    } catch (e, stackTrace) {
      _errorService.reporter.reportError(
        e,
        stackTrace,
        message: 'Failed to sync aircraft types',
      );

      // Don't mark as failed - we can resume next time
      return SyncResult(
        entityType: 'aircraft_types',
        recordsProcessed: await getLocalCount(),
        duration: DateTime.now().difference(startTime),
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Check if sync is needed (e.g., no local data, incomplete, or stale)
  Future<bool> needsSync({Duration maxAge = const Duration(days: 7)}) async {
    final hasData = await hasLocalData();
    if (!hasData) return true;

    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true; // Sync was never completed

    return DateTime.now().difference(lastSync) > maxAge;
  }

  /// Check if initial sync is incomplete (partial download)
  Future<bool> hasPendingSync() async {
    final lastSync = await getLastSyncTime();
    // If we have data but no lastSync timestamp, sync was interrupted
    return await hasLocalData() && lastSync == null;
  }

  // ==========================================================================
  // Private API Methods
  // ==========================================================================

  Future<Map<String, dynamic>> _fetchStats() async {
    final response = await _api.get('${AppConfig.aircraftTypes}/stats');
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _fetchPage(int page, int limit) async {
    final response = await _api.get(
      '${AppConfig.aircraftTypes}/all?page=$page&limit=$limit',
    );

    final dataJson = response['data'] as List<dynamic>? ?? [];
    final aircraftTypes = dataJson
        .map((json) => models.AircraftType.fromJson(json as Map<String, dynamic>))
        .toList();

    return {
      'data': aircraftTypes,
      'pagination': response['pagination'] as Map<String, dynamic>? ?? {},
    };
  }
}
