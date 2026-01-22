import 'package:flutter/widgets.dart';

import '../repositories/aircraft_repository.dart';
import '../repositories/airport_repository.dart';
import '../repositories/flight_repository.dart';
import '../services/connectivity_service.dart';
import '../services/draft_service.dart';
import '../services/sync_service.dart';
import 'database.dart';

/// Provides access to the database and repositories throughout the app.
///
/// Initialize once at app startup via [DatabaseProvider.initialize()].
/// Access via [DatabaseProvider.instance] or through Flutter's Provider.
class DatabaseProvider extends ChangeNotifier {
  static DatabaseProvider? _instance;

  late final HyperlogDatabase _db;
  late final AirportRepository _airportRepository;
  late final AircraftRepository _aircraftRepository;
  late final FlightRepository _flightRepository;
  late final SyncService _syncService;
  late final DraftService _draftService;
  late final ConnectivityService _connectivityService;

  bool _isInitialized = false;
  String? _initError;

  DatabaseProvider._();

  /// Get the singleton instance
  static DatabaseProvider get instance {
    _instance ??= DatabaseProvider._();
    return _instance!;
  }

  /// Whether the database has been initialized
  bool get isInitialized => _isInitialized;

  /// Error message if initialization failed
  String? get initError => _initError;

  /// The database instance
  HyperlogDatabase get database => _db;

  /// Airport repository (local-first)
  AirportRepository get airportRepository => _airportRepository;

  /// Aircraft type repository (local-first)
  AircraftRepository get aircraftRepository => _aircraftRepository;

  /// Flight repository (local-first with sync queue)
  FlightRepository get flightRepository => _flightRepository;

  /// Sync service for coordinating all sync operations
  SyncService get syncService => _syncService;

  /// Draft service for form state persistence
  DraftService get draftService => _draftService;

  /// Connectivity service for network status
  ConnectivityService get connectivityService => _connectivityService;

  /// Initialize the database and all repositories.
  /// Call once at app startup before runApp().
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize connectivity service first
      _connectivityService = ConnectivityService();
      await _connectivityService.initialize();

      // Create database
      _db = HyperlogDatabase();

      // Create repositories
      _airportRepository = AirportRepository(db: _db);
      _aircraftRepository = AircraftRepository(db: _db);
      _flightRepository = FlightRepository(db: _db);

      // Create services
      _draftService = DraftService(db: _db);
      _syncService = SyncService(
        db: _db,
        flightRepo: _flightRepository,
        airportRepo: _airportRepository,
        aircraftRepo: _aircraftRepository,
        connectivity: _connectivityService,
      );

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _initError = e.toString();
      rethrow;
    }
  }

  /// Start sync service for a user (call after login)
  Future<void> startSyncForUser(String userId) async {
    await _syncService.initialize(userId);
  }

  /// Stop sync service (call on logout)
  void stopSync() {
    _syncService.dispose();
  }

  /// Clear user data on logout (keeps reference data)
  Future<void> clearUserData() async {
    stopSync();
    await _db.clearAllData();
  }

  /// Dispose of resources
  @override
  void dispose() {
    _connectivityService.dispose();
    _syncService.dispose();
    _draftService.dispose();
    super.dispose();
  }
}

/// Convenience getters for quick access to repositories
HyperlogDatabase get db => DatabaseProvider.instance.database;
AirportRepository get airportRepo => DatabaseProvider.instance.airportRepository;
AircraftRepository get aircraftRepo => DatabaseProvider.instance.aircraftRepository;
FlightRepository get flightRepo => DatabaseProvider.instance.flightRepository;
SyncService get syncService => DatabaseProvider.instance.syncService;
DraftService get draftService => DatabaseProvider.instance.draftService;
ConnectivityService get connectivity => DatabaseProvider.instance.connectivityService;
