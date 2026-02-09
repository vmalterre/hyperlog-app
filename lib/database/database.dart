import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ============================================================================
// Tables
// ============================================================================

/// Reference data: Airports from OurAirports (~70,000 records)
class Airports extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ident => text().withLength(max: 10).unique()();
  TextColumn get icaoCode => text().withLength(max: 4).nullable()();
  TextColumn get iataCode => text().withLength(max: 3).nullable()();
  TextColumn get name => text()();
  TextColumn get municipality => text().nullable()();
  TextColumn get isoCountry => text().withLength(max: 2).nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get timezone => text().nullable()();
}

/// Reference data: Aircraft types from ICAO Doc 8643 (~5,000 records)
class AircraftTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get icaoDesignator => text().withLength(max: 10).unique()();
  TextColumn get manufacturer => text()();
  TextColumn get model => text()();
  TextColumn get category => text()();
  IntColumn get engineCount => integer()();
  TextColumn get engineType => text()();
  TextColumn get wtc => text().nullable()(); // Wake turbulence category
  BoolColumn get multiPilot => boolean().nullable()();
  BoolColumn get complex => boolean().nullable()();
  BoolColumn get highPerformance => boolean().nullable()();
  BoolColumn get retractableGear => boolean().nullable()();
}

/// User's flight logbook entries (cached + pending)
class Flights extends Table {
  TextColumn get id => text()(); // UUID - client-generated for offline
  TextColumn get creatorUuid => text()();
  TextColumn get flightDate => text()(); // ISO date string YYYY-MM-DD
  TextColumn get flightNumber => text().nullable()();
  TextColumn get dep => text()(); // Primary airport code
  TextColumn get dest => text()(); // Primary airport code
  TextColumn get depIcao => text().nullable()();
  TextColumn get depIata => text().nullable()();
  TextColumn get destIcao => text().nullable()();
  TextColumn get destIata => text().nullable()();
  TextColumn get blockOff => text()(); // ISO datetime (chocks off)
  TextColumn get blockOn => text()(); // ISO datetime (chocks on)
  TextColumn get takeoffAt => text().nullable()(); // ISO datetime (wheels up)
  TextColumn get landingAt => text().nullable()(); // ISO datetime (wheels down)
  TextColumn get aircraftType => text()();
  TextColumn get aircraftReg => text()();
  TextColumn get simReg => text().nullable()(); // Simulator registration (null for real flights)
  TextColumn get flightTimeJson => text()(); // JSON-encoded FlightTime
  BoolColumn get isPilotFlying => boolean().withDefault(const Constant(true))();
  TextColumn get approachesJson => text().nullable()(); // JSON-encoded Approaches
  TextColumn get crewJson => text()(); // JSON-encoded List<CrewMember>
  TextColumn get verificationsJson => text().nullable()(); // JSON-encoded List<Verification>
  TextColumn get endorsementsJson => text().nullable()(); // JSON-encoded List<Endorsement>
  TextColumn get createdAt => text()(); // ISO datetime
  TextColumn get updatedAt => text()(); // ISO datetime
  // Sync fields
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))(); // pending, synced, conflict
  TextColumn get serverUpdatedAt => text().nullable()(); // Last known server timestamp
  TextColumn get localUpdatedAt => text()(); // Timestamp of local change

  @override
  Set<Column> get primaryKey => {id};
}

/// Sync metadata - tracks last sync timestamps per entity type
class SyncMetadata extends Table {
  TextColumn get entityType => text()(); // airports, aircraft_types, flights, etc.
  TextColumn get lastSyncAt => text().nullable()(); // ISO datetime
  IntColumn get recordCount => integer().nullable()();

  @override
  Set<Column> get primaryKey => {entityType};
}

/// Pending deletions - queued delete operations for offline sync
class PendingDeletions extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get deletedAt => text()(); // ISO datetime

  @override
  Set<Column> get primaryKey => {id};
}

/// Draft storage - unsaved form state for crash recovery
class FlightDrafts extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get formData => text()(); // JSON-encoded form state
  IntColumn get createdAt => integer()(); // Unix timestamp
  IntColumn get updatedAt => integer()(); // Unix timestamp

  @override
  Set<Column> get primaryKey => {id};
}

/// User's saved pilots (crew contacts)
class SavedPilots extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get userId => text()(); // Owner user UUID
  TextColumn get name => text()();
  TextColumn get licenseNumber => text().nullable()();
  TextColumn get pilotUuid => text().nullable()(); // If linked to registered pilot
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  // Sync fields
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get serverUpdatedAt => text().nullable()();
  TextColumn get localUpdatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================================
// Database
// ============================================================================

@DriftDatabase(tables: [
  Airports,
  AircraftTypes,
  Flights,
  SyncMetadata,
  PendingDeletions,
  FlightDrafts,
  SavedPilots,
])
class HyperlogDatabase extends _$HyperlogDatabase {
  HyperlogDatabase() : super(_openConnection());

  /// For testing: create database with custom executor
  HyperlogDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Create indexes for search performance
        await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_airports_icao ON airports(icao_code)');
        await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_airports_iata ON airports(iata_code)');
        await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_airports_name ON airports(name)');
        await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_aircraft_designator ON aircraft_types(icao_designator)');
        await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_flights_creator ON flights(creator_uuid)');
        await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_flights_date ON flights(flight_date DESC)');
        await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_flights_sync ON flights(sync_status)');
        await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_saved_pilots_user ON saved_pilots(user_id)');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migration v1 -> v2: Add takeoff_at and landing_at columns to flights
        if (from < 2) {
          await customStatement(
              'ALTER TABLE flights ADD COLUMN takeoff_at TEXT');
          await customStatement(
              'ALTER TABLE flights ADD COLUMN landing_at TEXT');
        }
        // Migration v2 -> v3: Add sim_reg column to flights
        if (from < 3) {
          await customStatement(
              'ALTER TABLE flights ADD COLUMN sim_reg TEXT');
          // Force full re-sync so simReg gets populated from server data
          await customStatement(
              "DELETE FROM sync_metadata WHERE entity_type = 'flights'");
        }
      },
    );
  }

  // ==========================================================================
  // Airport Operations
  // ==========================================================================

  /// Search airports by query (matches ICAO, IATA, name, municipality)
  Future<List<Airport>> searchAirports(String query, {int limit = 10}) {
    final pattern = '%${query.toLowerCase()}%';
    return (select(airports)
          ..where((a) =>
              a.icaoCode.lower().like(pattern) |
              a.iataCode.lower().like(pattern) |
              a.name.lower().like(pattern) |
              a.municipality.lower().like(pattern) |
              a.ident.lower().like(pattern))
          ..limit(limit))
        .get();
  }

  /// Get airport by code (ICAO, IATA, or ident)
  Future<Airport?> getAirportByCode(String code) {
    final upperCode = code.toUpperCase();
    return (select(airports)
          ..where((a) =>
              a.icaoCode.equals(upperCode) |
              a.iataCode.equals(upperCode) |
              a.ident.equals(upperCode)))
        .getSingleOrNull();
  }

  /// Bulk insert airports (for initial sync)
  Future<void> insertAirports(List<AirportsCompanion> airportList) async {
    await batch((batch) {
      batch.insertAll(airports, airportList, mode: InsertMode.insertOrReplace);
    });
  }

  /// Get airport count
  Future<int> getAirportCount() async {
    final count = airports.id.count();
    final query = selectOnly(airports)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // ==========================================================================
  // Aircraft Type Operations
  // ==========================================================================

  /// Search aircraft types by query (matches designator, manufacturer, model)
  Future<List<AircraftType>> searchAircraftTypes(String query,
      {int limit = 10}) {
    final pattern = '%${query.toLowerCase()}%';
    return (select(aircraftTypes)
          ..where((a) =>
              a.icaoDesignator.lower().like(pattern) |
              a.manufacturer.lower().like(pattern) |
              a.model.lower().like(pattern))
          ..limit(limit))
        .get();
  }

  /// Get aircraft type by ICAO designator
  Future<AircraftType?> getAircraftTypeByDesignator(String designator) {
    return (select(aircraftTypes)
          ..where((a) => a.icaoDesignator.equals(designator.toUpperCase())))
        .getSingleOrNull();
  }

  /// Bulk insert aircraft types (for initial sync)
  Future<void> insertAircraftTypes(
      List<AircraftTypesCompanion> typeList) async {
    await batch((batch) {
      batch.insertAll(aircraftTypes, typeList, mode: InsertMode.insertOrReplace);
    });
  }

  /// Get aircraft type count
  Future<int> getAircraftTypeCount() async {
    final count = aircraftTypes.id.count();
    final query = selectOnly(aircraftTypes)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // ==========================================================================
  // Flight Operations
  // ==========================================================================

  /// Get all flights for a user, sorted by date descending
  Future<List<Flight>> getFlightsForUser(String userId) {
    return (select(flights)
          ..where((f) => f.creatorUuid.equals(userId))
          ..orderBy([(f) => OrderingTerm.desc(f.flightDate)]))
        .get();
  }

  /// Watch flights for a user (reactive stream)
  Stream<List<Flight>> watchFlightsForUser(String userId) {
    return (select(flights)
          ..where((f) => f.creatorUuid.equals(userId))
          ..orderBy([(f) => OrderingTerm.desc(f.flightDate)]))
        .watch();
  }

  /// Get a single flight by ID
  Future<Flight?> getFlightById(String id) {
    return (select(flights)..where((f) => f.id.equals(id))).getSingleOrNull();
  }

  /// Insert or update a flight
  Future<void> upsertFlight(FlightsCompanion flight) async {
    await into(flights).insertOnConflictUpdate(flight);
  }

  /// Bulk insert/update flights (for sync)
  Future<void> upsertFlights(List<FlightsCompanion> flightList) async {
    await batch((batch) {
      for (final flight in flightList) {
        batch.insert(flights, flight, mode: InsertMode.insertOrReplace);
      }
    });
  }

  /// Get pending flights (not yet synced)
  Future<List<Flight>> getPendingFlights() {
    return (select(flights)..where((f) => f.syncStatus.equals('pending')))
        .get();
  }

  /// Mark flight as synced
  Future<void> markFlightSynced(String id, String serverUpdatedAt) async {
    await (update(flights)..where((f) => f.id.equals(id))).write(
      FlightsCompanion(
        syncStatus: const Value('synced'),
        serverUpdatedAt: Value(serverUpdatedAt),
      ),
    );
  }

  /// Delete a flight locally
  Future<void> deleteFlightLocal(String id) async {
    await (delete(flights)..where((f) => f.id.equals(id))).go();
  }

  /// Delete all flights for a user locally
  Future<int> deleteAllFlightsForUser(String userId) async {
    return await transaction(() async {
      return await (delete(flights)..where((f) => f.creatorUuid.equals(userId))).go();
    });
  }

  /// Get flight count for user
  Future<int> getFlightCountForUser(String userId) async {
    final count = flights.id.count();
    final query = selectOnly(flights)
      ..addColumns([count])
      ..where(flights.creatorUuid.equals(userId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // ==========================================================================
  // Sync Metadata Operations
  // ==========================================================================

  /// Get last sync time for an entity type
  Future<DateTime?> getLastSyncTime(String entityType) async {
    final row = await (select(syncMetadata)
          ..where((m) => m.entityType.equals(entityType)))
        .getSingleOrNull();
    if (row?.lastSyncAt == null) return null;
    return DateTime.tryParse(row!.lastSyncAt!);
  }

  /// Update last sync time
  Future<void> updateSyncMetadata(
      String entityType, DateTime lastSyncAt, int recordCount) async {
    await into(syncMetadata).insertOnConflictUpdate(
      SyncMetadataCompanion(
        entityType: Value(entityType),
        lastSyncAt: Value(lastSyncAt.toIso8601String()),
        recordCount: Value(recordCount),
      ),
    );
  }

  /// Delete sync metadata for an entity type (for full re-sync)
  Future<void> deleteSyncMetadata(String entityType) async {
    await (delete(syncMetadata)
          ..where((t) => t.entityType.equals(entityType)))
        .go();
  }

  // ==========================================================================
  // Pending Deletions Operations
  // ==========================================================================

  /// Add a pending deletion
  Future<void> addPendingDeletion(
      String id, String entityType, String entityId) async {
    await into(pendingDeletions).insert(
      PendingDeletionsCompanion(
        id: Value(id),
        entityType: Value(entityType),
        entityId: Value(entityId),
        deletedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  /// Get all pending deletions
  Future<List<PendingDeletion>> getAllPendingDeletions() {
    return select(pendingDeletions).get();
  }

  /// Remove a pending deletion after successful sync
  Future<void> removePendingDeletion(String id) async {
    await (delete(pendingDeletions)..where((d) => d.id.equals(id))).go();
  }

  // ==========================================================================
  // Draft Operations
  // ==========================================================================

  /// Save a flight draft
  Future<void> saveDraft(String id, String formData) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(flightDrafts).insertOnConflictUpdate(
      FlightDraftsCompanion(
        id: Value(id),
        formData: Value(formData),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Get the most recent draft
  Future<FlightDraft?> getLatestDraft() async {
    return (select(flightDrafts)
          ..orderBy([(d) => OrderingTerm.desc(d.updatedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Delete a draft
  Future<void> deleteDraft(String id) async {
    await (delete(flightDrafts)..where((d) => d.id.equals(id))).go();
  }

  /// Delete all drafts
  Future<void> deleteAllDrafts() async {
    await delete(flightDrafts).go();
  }

  // ==========================================================================
  // Saved Pilots Operations
  // ==========================================================================

  /// Get saved pilots for a user
  Future<List<SavedPilot>> getSavedPilotsForUser(String userId) {
    return (select(savedPilots)
          ..where((p) => p.userId.equals(userId))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();
  }

  /// Insert or update a saved pilot
  Future<void> upsertSavedPilot(SavedPilotsCompanion pilot) async {
    await into(savedPilots).insertOnConflictUpdate(pilot);
  }

  /// Delete a saved pilot
  Future<void> deleteSavedPilot(String id) async {
    await (delete(savedPilots)..where((p) => p.id.equals(id))).go();
  }

  /// Get pending saved pilots
  Future<List<SavedPilot>> getPendingSavedPilots() {
    return (select(savedPilots)..where((p) => p.syncStatus.equals('pending')))
        .get();
  }

  // ==========================================================================
  // Utility Operations
  // ==========================================================================

  /// Clear all data (for logout)
  Future<void> clearAllData() async {
    await delete(flights).go();
    await delete(savedPilots).go();
    await delete(pendingDeletions).go();
    await delete(flightDrafts).go();
    // Keep reference data (airports, aircraft) - they're shared
    // Reset sync metadata for user data
    await (delete(syncMetadata)
          ..where((m) =>
              m.entityType.equals('flights') |
              m.entityType.equals('saved_pilots')))
        .go();
  }

  /// Clear all data including reference data (for testing)
  Future<void> clearAllDataIncludingReference() async {
    await delete(flights).go();
    await delete(savedPilots).go();
    await delete(pendingDeletions).go();
    await delete(flightDrafts).go();
    await delete(airports).go();
    await delete(aircraftTypes).go();
    await delete(syncMetadata).go();
  }

  /// Clear airports (for re-sync)
  Future<void> clearAirports() async {
    await delete(airports).go();
  }

  /// Clear aircraft types (for re-sync)
  Future<void> clearAircraftTypes() async {
    await delete(aircraftTypes).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Use application documents directory for the database
    // Note: On iOS, we must stay within the sandbox (Documents, Library, tmp)
    // The app container root is not writable on iOS
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'hyperlog.db'));
    return NativeDatabase.createInBackground(
      file,
      setup: (database) {
        // Set busy timeout to 5 seconds - SQLite will retry instead of failing immediately
        database.execute('PRAGMA busy_timeout = 5000;');
      },
    );
  });
}
