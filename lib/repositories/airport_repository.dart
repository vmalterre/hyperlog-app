import '../config/app_config.dart';
import '../database/converters.dart';
import '../database/database.dart';
import '../models/airport.dart' as models;
import '../services/api_service.dart';
import '../services/error_service.dart';

/// Repository for airport data with local-first architecture.
///
/// Reads are served from the local SQLite database for instant offline access.
/// Sync operations fetch bulk data from the server and update local storage.
class AirportRepository {
  final HyperlogDatabase _db;
  final ApiService _api;
  final ErrorService _errorService;

  AirportRepository({
    required HyperlogDatabase db,
    ApiService? api,
    ErrorService? errorService,
  })  : _db = db,
        _api = api ?? ApiService(),
        _errorService = errorService ?? ErrorService();

  // ==========================================================================
  // Local Operations (Offline-First)
  // ==========================================================================

  /// Search airports locally (instant, offline-capable)
  /// Returns up to [limit] results matching ICAO, IATA, name, or municipality
  Future<List<models.Airport>> search(String query, {int limit = 10}) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final rows = await _db.searchAirports(query, limit: limit);
    return rows.map((row) => airportFromRow(row)).toList();
  }

  /// Get airport by code (ICAO, IATA, or ident) locally
  Future<models.Airport?> getByCode(String code) async {
    final row = await _db.getAirportByCode(code);
    return row != null ? airportFromRow(row) : null;
  }

  /// Get local airport count
  Future<int> getLocalCount() async {
    return _db.getAirportCount();
  }

  /// Check if local database has airports
  Future<bool> hasLocalData() async {
    final count = await getLocalCount();
    return count > 0;
  }

  /// Clear all local airports and sync fresh from server
  Future<SyncResult> clearAndSync({
    void Function(double progress, String message)? onProgress,
  }) async {
    onProgress?.call(0.0, 'Clearing local airports...');
    await _db.clearAirports();
    await _db.deleteSyncMetadata('airports');
    return syncFromServer(onProgress: onProgress);
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    return _db.getLastSyncTime('airports');
  }

  // ==========================================================================
  // Sync Operations
  // ==========================================================================

  /// Sync airports from server (resumable)
  /// Downloads all airports in batches and stores locally.
  /// Resumes from last position if interrupted.
  /// Use [onProgress] to track download progress (0.0 to 1.0)
  Future<SyncResult> syncFromServer({
    void Function(double progress, String message)? onProgress,
  }) async {
    final startTime = DateTime.now();
    const pageSize = 5000;

    try {
      // First, get total count from stats
      onProgress?.call(0.0, 'Checking airport database...');
      final stats = await _fetchStats();
      final totalExpected = stats['count'] as int? ?? 0;

      if (totalExpected == 0) {
        return SyncResult(
          entityType: 'airports',
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
          'Resuming airport download ($currentCount / $totalExpected)...',
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
          'Downloading airports ($totalInserted / $totalExpected)...',
        );

        final result = await _fetchPage(page, pageSize);
        final airports = result['data'] as List<models.Airport>;
        final pagination = result['pagination'] as Map<String, dynamic>;

        if (airports.isNotEmpty) {
          // Convert to database companions and bulk insert
          final companions = airports.map((a) => airportToCompanion(a)).toList();
          await _db.insertAirports(companions);
          totalInserted += airports.length;
        }

        hasMore = pagination['hasMore'] as bool? ?? false;
        page++;
      }

      // Update sync metadata - mark as complete
      await _db.updateSyncMetadata('airports', DateTime.now(), totalInserted);

      onProgress?.call(1.0, 'Airport sync complete');

      return SyncResult(
        entityType: 'airports',
        recordsProcessed: totalInserted,
        duration: DateTime.now().difference(startTime),
        success: true,
      );
    } catch (e, stackTrace) {
      _errorService.reporter.reportError(
        e,
        stackTrace,
        message: 'Failed to sync airports',
      );

      // Don't mark as failed - we can resume next time
      return SyncResult(
        entityType: 'airports',
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
    final response = await _api.get('${AppConfig.airports}/stats');
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _fetchPage(int page, int limit) async {
    final response = await _api.get(
      '${AppConfig.airports}/all?page=$page&limit=$limit',
    );

    final dataJson = response['data'] as List<dynamic>? ?? [];
    final airports = dataJson
        .map((json) => models.Airport.fromJson(json as Map<String, dynamic>))
        .toList();

    return {
      'data': airports,
      'pagination': response['pagination'] as Map<String, dynamic>? ?? {},
    };
  }
}

/// Result of a sync operation
class SyncResult {
  final String entityType;
  final int recordsProcessed;
  final Duration duration;
  final bool success;
  final String? error;

  SyncResult({
    required this.entityType,
    required this.recordsProcessed,
    required this.duration,
    required this.success,
    this.error,
  });

  @override
  String toString() {
    if (success) {
      return 'SyncResult($entityType: $recordsProcessed records in ${duration.inSeconds}s)';
    }
    return 'SyncResult($entityType: FAILED - $error)';
  }
}
