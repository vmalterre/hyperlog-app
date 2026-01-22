import 'dart:async';

import '../config/app_config.dart';
import '../database/database.dart';
import '../repositories/airport_repository.dart';
import '../repositories/aircraft_repository.dart';
import '../repositories/flight_repository.dart';
import 'api_service.dart';
import 'connectivity_service.dart';
import 'error_service.dart';

/// Sync status for tracking overall sync state
enum OverallSyncStatus {
  idle,
  syncing,
  error,
  offline,
}

/// Simple sync status for UI display
enum SyncStatus {
  idle,
  syncing,
  error,
}

/// Service that coordinates all sync operations.
///
/// Responsibilities:
/// - Upload pending local changes when online
/// - Download server updates (delta sync)
/// - Manage initial reference data download
/// - Handle connectivity changes
/// - Retry failed syncs with exponential backoff
class SyncService {
  final FlightRepository _flightRepo;
  final AirportRepository _airportRepo;
  final AircraftRepository _aircraftRepo;
  final ConnectivityService _connectivity;
  final ErrorService _errorService;

  Timer? _periodicSyncTimer;
  StreamSubscription<bool>? _connectivitySubscription;

  /// Current sync status
  OverallSyncStatus _status = OverallSyncStatus.idle;
  String? _lastError;
  DateTime? _lastSyncTime;

  /// Current user ID for flight sync
  String? _currentUserId;

  /// Sync progress callbacks
  final _statusController = StreamController<SyncStatusUpdate>.broadcast();

  /// Simple status stream for UI widgets
  final _simpleStatusController = StreamController<SyncStatus>.broadcast();

  SyncService({
    required HyperlogDatabase db,
    FlightRepository? flightRepo,
    AirportRepository? airportRepo,
    AircraftRepository? aircraftRepo,
    ConnectivityService? connectivity,
    ErrorService? errorService,
  })  : _flightRepo = flightRepo ?? FlightRepository(db: db),
        _airportRepo = airportRepo ?? AirportRepository(db: db),
        _aircraftRepo = aircraftRepo ?? AircraftRepository(db: db),
        _connectivity = connectivity ?? connectivityService,
        _errorService = errorService ?? ErrorService();

  /// Current sync status
  OverallSyncStatus get status => _status;

  /// Last error message (if any)
  String? get lastError => _lastError;

  /// Last successful sync time
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Whether currently syncing
  bool get isSyncing => _status == OverallSyncStatus.syncing;

  /// Stream of sync status updates
  Stream<SyncStatusUpdate> get onStatusChanged => _statusController.stream;

  /// Simple status stream for UI widgets
  Stream<SyncStatus> get statusStream => _simpleStatusController.stream;

  /// Initialize the sync service
  /// Call this after user login with their userId
  Future<void> initialize(String userId) async {
    _currentUserId = userId;

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    // Start periodic sync (every 15 minutes)
    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => syncIfNeeded(),
    );

    // Initial sync if online
    if (_connectivity.isOnline) {
      // Check if we need to download reference data (airports, aircraft)
      final needsInitial = await needsInitialSync();
      if (needsInitial) {
        // Run initial sync in background - don't block the user
        _runInitialSyncInBackground();
      } else {
        // Check if server has new data (quick count comparison)
        _checkForUpdatesInBackground();
        // Sync flights
        await syncIfNeeded();
      }
    } else {
      _updateStatus(OverallSyncStatus.offline);
    }
  }

  /// Quick check if server has more data than local
  void _checkForUpdatesInBackground() {
    _checkAndUpdateReferenceData().catchError((e) {
      _errorService.reporter.reportError(
        e,
        StackTrace.current,
        message: 'Background reference data check failed',
      );
    });
  }

  Future<void> _checkAndUpdateReferenceData() async {
    try {
      // Check airports
      final airportStats = await _fetchStats(AppConfig.airports);
      final serverAirportCount = airportStats['count'] as int? ?? 0;
      final localAirportCount = await _airportRepo.getLocalCount();

      if (serverAirportCount > localAirportCount) {
        // Server has more airports - sync in background
        _airportRepo.syncFromServer();
      }

      // Check aircraft types
      final aircraftStats = await _fetchStats(AppConfig.aircraftTypes);
      final serverAircraftCount = aircraftStats['count'] as int? ?? 0;
      final localAircraftCount = await _aircraftRepo.getLocalCount();

      if (serverAircraftCount > localAircraftCount) {
        // Server has more aircraft - sync in background
        _aircraftRepo.syncFromServer();
      }
    } catch (e) {
      // Silent fail - not critical
    }
  }

  Future<Map<String, dynamic>> _fetchStats(String endpoint) async {
    final api = ApiService();
    final response = await api.get('$endpoint/stats');
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Run initial sync in background without blocking
  void _runInitialSyncInBackground() {
    // Fire and forget - runs asynchronously
    performInitialSync(
      onProgress: (progress, message) {
        // Emit status updates for UI indicator
        _emitUpdate(SyncStatusUpdate(
          phase: SyncPhase.downloading,
          message: message,
          progress: progress,
        ));
      },
    ).then((_) {
      // After initial sync completes, sync flights
      syncIfNeeded();
    }).catchError((e) {
      _errorService.reporter.reportError(
        e,
        StackTrace.current,
        message: 'Background initial sync failed',
      );
    });
  }

  /// Stop the sync service (call on logout)
  void dispose() {
    _periodicSyncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _statusController.close();
    _simpleStatusController.close();
    _currentUserId = null;
  }

  // ==========================================================================
  // Initial Setup (First Login)
  // ==========================================================================

  /// Perform initial reference data sync
  /// Shows progress to user during first login
  Future<InitialSyncResult> performInitialSync({
    void Function(double progress, String message)? onProgress,
  }) async {
    if (!_connectivity.isOnline) {
      return InitialSyncResult(
        success: false,
        error: 'No internet connection. Please try again when online.',
      );
    }

    _updateStatus(OverallSyncStatus.syncing);

    try {
      // Check what needs syncing
      final needsAirports = await _airportRepo.needsSync();
      final needsAircraft = await _aircraftRepo.needsSync();

      int totalSteps = 0;
      if (needsAirports) totalSteps++;
      if (needsAircraft) totalSteps++;
      if (_currentUserId != null) totalSteps++; // Flights

      if (totalSteps == 0) {
        _updateStatus(OverallSyncStatus.idle);
        onProgress?.call(1.0, 'Already up to date');
        return InitialSyncResult(success: true);
      }

      int completedSteps = 0;

      // Sync airports if needed
      if (needsAirports) {
        onProgress?.call(
          completedSteps / totalSteps,
          'Downloading airport database...',
        );

        final airportResult = await _airportRepo.syncFromServer(
          onProgress: (progress, message) {
            final overallProgress =
                (completedSteps + progress) / totalSteps;
            onProgress?.call(overallProgress, message);
          },
        );

        if (!airportResult.success) {
          _updateStatus(OverallSyncStatus.error, error: airportResult.error);
          return InitialSyncResult(
            success: false,
            error: 'Failed to sync airports: ${airportResult.error}',
          );
        }

        completedSteps++;
      }

      // Sync aircraft types if needed
      if (needsAircraft) {
        onProgress?.call(
          completedSteps / totalSteps,
          'Downloading aircraft database...',
        );

        final aircraftResult = await _aircraftRepo.syncFromServer(
          onProgress: (progress, message) {
            final overallProgress =
                (completedSteps + progress) / totalSteps;
            onProgress?.call(overallProgress, message);
          },
        );

        if (!aircraftResult.success) {
          _updateStatus(OverallSyncStatus.error, error: aircraftResult.error);
          return InitialSyncResult(
            success: false,
            error: 'Failed to sync aircraft: ${aircraftResult.error}',
          );
        }

        completedSteps++;
      }

      // Sync flights if user is logged in
      if (_currentUserId != null) {
        onProgress?.call(
          completedSteps / totalSteps,
          'Syncing your logbook...',
        );

        final flightResult = await _flightRepo.syncFromServer(_currentUserId!);

        if (!flightResult.success) {
          // Flight sync failure is not critical - continue
          _errorService.reporter.reportError(
            Exception(flightResult.error),
            StackTrace.current,
            message: 'Initial flight sync failed',
          );
        }

        completedSteps++;
      }

      _lastSyncTime = DateTime.now();
      _updateStatus(OverallSyncStatus.idle);
      onProgress?.call(1.0, 'Sync complete');

      return InitialSyncResult(success: true);
    } catch (e, stackTrace) {
      _errorService.reporter.reportError(
        e,
        stackTrace,
        message: 'Initial sync failed',
      );
      _updateStatus(OverallSyncStatus.error, error: e.toString());
      return InitialSyncResult(success: false, error: e.toString());
    }
  }

  /// Check if initial sync is needed (no data or incomplete download)
  Future<bool> needsInitialSync() async {
    // Check if we have no data
    final hasAirports = await _airportRepo.hasLocalData();
    final hasAircraft = await _aircraftRepo.hasLocalData();
    if (!hasAirports || !hasAircraft) return true;

    // Check if previous sync was interrupted (has data but not completed)
    final airportsPending = await _airportRepo.hasPendingSync();
    final aircraftPending = await _aircraftRepo.hasPendingSync();
    return airportsPending || aircraftPending;
  }

  // ==========================================================================
  // Regular Sync Operations
  // ==========================================================================

  /// Perform a full sync if conditions are met
  Future<void> syncIfNeeded() async {
    if (!_connectivity.isOnline) {
      _updateStatus(OverallSyncStatus.offline);
      return;
    }

    if (_status == OverallSyncStatus.syncing) {
      return; // Already syncing
    }

    if (_currentUserId == null) {
      return; // No user logged in
    }

    await fullSync();
  }

  /// Trigger sync immediately (from UI retry button)
  Future<void> syncNow() async {
    await syncIfNeeded();
  }

  /// Force a full sync (upload + download)
  Future<void> fullSync() async {
    if (_currentUserId == null) return;

    _updateStatus(OverallSyncStatus.syncing);

    try {
      // Upload pending changes first
      final uploadResult = await _flightRepo.uploadPendingChanges();
      if (!uploadResult.success) {
        _emitUpdate(SyncStatusUpdate(
          phase: SyncPhase.uploading,
          message: 'Some changes failed to upload',
          isError: true,
        ));
      }

      // Download server changes
      final downloadResult = await _flightRepo.syncFromServer(_currentUserId!);
      if (!downloadResult.success) {
        _updateStatus(OverallSyncStatus.error, error: downloadResult.error);
        return;
      }

      _lastSyncTime = DateTime.now();
      _updateStatus(OverallSyncStatus.idle);
    } catch (e, stackTrace) {
      _errorService.reporter.reportError(
        e,
        stackTrace,
        message: 'Full sync failed',
      );
      _updateStatus(OverallSyncStatus.error, error: e.toString());
    }
  }

  /// Sync flights for a specific user (pull-to-refresh)
  Future<void> syncFlights(String userId) async {
    if (!_connectivity.isOnline || userId.isEmpty) return;

    _updateStatus(OverallSyncStatus.syncing);

    try {
      // Upload first, then download
      await _flightRepo.uploadPendingChanges();
      await _flightRepo.syncFromServer(userId);
      _lastSyncTime = DateTime.now();
      _updateStatus(OverallSyncStatus.idle);
    } catch (e, stackTrace) {
      _errorService.reporter.reportError(
        e,
        stackTrace,
        message: 'Flight sync failed',
      );
      _updateStatus(OverallSyncStatus.error, error: e.toString());
    }
  }

  /// Upload pending changes only (quick sync when going online)
  Future<void> uploadPendingChanges() async {
    if (!_connectivity.isOnline) return;

    try {
      await _flightRepo.uploadPendingChanges();
    } catch (e) {
      // Don't update status for upload-only failures
      // They'll be retried on next sync
    }
  }

  /// Refresh reference data (airports and aircraft types)
  Future<void> refreshReferenceData({
    void Function(double progress, String message)? onProgress,
  }) async {
    if (!_connectivity.isOnline) {
      throw Exception('Cannot refresh reference data while offline');
    }

    _updateStatus(OverallSyncStatus.syncing);

    try {
      onProgress?.call(0.0, 'Clearing and refreshing airports...');
      await _airportRepo.clearAndSync(onProgress: (p, m) {
        onProgress?.call(p * 0.5, m);
      });

      onProgress?.call(0.5, 'Clearing and refreshing aircraft types...');
      await _aircraftRepo.clearAndSync(onProgress: (p, m) {
        onProgress?.call(0.5 + p * 0.5, m);
      });

      _updateStatus(OverallSyncStatus.idle);
      onProgress?.call(1.0, 'Reference data updated');
    } catch (e, stackTrace) {
      _errorService.reporter.reportError(
        e,
        stackTrace,
        message: 'Reference data refresh failed',
      );
      _updateStatus(OverallSyncStatus.error, error: e.toString());
      rethrow;
    }
  }

  // ==========================================================================
  // Status Queries
  // ==========================================================================

  /// Check if there are pending changes to upload
  Future<bool> hasPendingChanges() async {
    return _flightRepo.hasPendingChanges();
  }

  /// Get count of pending changes
  Future<int> getPendingChangeCount() async {
    return _flightRepo.getPendingFlightCount();
  }

  // ==========================================================================
  // Private Methods
  // ==========================================================================

  void _onConnectivityChanged(bool isOnline) {
    if (isOnline) {
      _updateStatus(OverallSyncStatus.idle);
      // Trigger sync when coming back online
      syncIfNeeded();
    } else {
      _updateStatus(OverallSyncStatus.offline);
    }
  }

  void _updateStatus(OverallSyncStatus status, {String? error}) {
    _status = status;
    _lastError = error;
    _emitUpdate(SyncStatusUpdate(
      phase: _phaseFromStatus(status),
      message: error ?? _messageFromStatus(status),
      isError: status == OverallSyncStatus.error,
    ));

    // Also emit simple status for UI widgets
    final simpleStatus = _toSimpleStatus(status);
    if (!_simpleStatusController.isClosed) {
      _simpleStatusController.add(simpleStatus);
    }
  }

  SyncStatus _toSimpleStatus(OverallSyncStatus status) {
    return switch (status) {
      OverallSyncStatus.idle => SyncStatus.idle,
      OverallSyncStatus.syncing => SyncStatus.syncing,
      OverallSyncStatus.error => SyncStatus.error,
      OverallSyncStatus.offline => SyncStatus.idle, // Show as idle when offline
    };
  }

  void _emitUpdate(SyncStatusUpdate update) {
    if (!_statusController.isClosed) {
      _statusController.add(update);
    }
  }

  SyncPhase _phaseFromStatus(OverallSyncStatus status) {
    return switch (status) {
      OverallSyncStatus.idle => SyncPhase.idle,
      OverallSyncStatus.syncing => SyncPhase.downloading,
      OverallSyncStatus.error => SyncPhase.error,
      OverallSyncStatus.offline => SyncPhase.offline,
    };
  }

  String _messageFromStatus(OverallSyncStatus status) {
    return switch (status) {
      OverallSyncStatus.idle => 'Up to date',
      OverallSyncStatus.syncing => 'Syncing...',
      OverallSyncStatus.error => 'Sync failed',
      OverallSyncStatus.offline => 'Offline',
    };
  }
}

/// Sync phases for UI feedback
enum SyncPhase {
  idle,
  uploading,
  downloading,
  error,
  offline,
}

/// Status update for sync progress
class SyncStatusUpdate {
  final SyncPhase phase;
  final String message;
  final bool isError;
  final double? progress;

  SyncStatusUpdate({
    required this.phase,
    required this.message,
    this.isError = false,
    this.progress,
  });
}

/// Result of initial sync operation
class InitialSyncResult {
  final bool success;
  final String? error;

  InitialSyncResult({required this.success, this.error});
}
