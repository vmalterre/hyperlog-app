import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/airport.dart' as models;
import '../models/aircraft_type.dart' as models;
import '../models/logbook_entry.dart';
import '../models/logbook_entry_short.dart';
import '../models/saved_pilot.dart' as models;
import '../widgets/trust_badge.dart';
import 'database.dart';

// ============================================================================
// Airport Converters
// ============================================================================

/// Convert API Airport model to database companion
AirportsCompanion airportToCompanion(models.Airport airport) {
  return AirportsCompanion(
    id: Value(airport.id),
    ident: Value(airport.ident),
    icaoCode: Value(airport.icaoCode),
    iataCode: Value(airport.iataCode),
    name: Value(airport.name),
    municipality: Value(airport.municipality),
    isoCountry: Value(airport.isoCountry),
    latitude: Value(airport.latitude),
    longitude: Value(airport.longitude),
    timezone: Value(airport.timezone),
  );
}

/// Convert database Airport row to API model
models.Airport airportFromRow(Airport row) {
  return models.Airport(
    id: row.id,
    ident: row.ident,
    icaoCode: row.icaoCode,
    iataCode: row.iataCode,
    name: row.name,
    municipality: row.municipality,
    isoCountry: row.isoCountry,
    latitude: row.latitude,
    longitude: row.longitude,
    timezone: row.timezone,
  );
}

// ============================================================================
// Aircraft Type Converters
// ============================================================================

/// Convert API AircraftType model to database companion
AircraftTypesCompanion aircraftTypeToCompanion(models.AircraftType type) {
  return AircraftTypesCompanion(
    id: Value(type.id),
    icaoDesignator: Value(type.icaoDesignator),
    manufacturer: Value(type.manufacturer),
    model: Value(type.model),
    category: Value(type.category),
    engineCount: Value(type.engineCount),
    engineType: Value(type.engineType),
    wtc: Value(type.wtc),
    multiPilot: Value(type.multiPilot),
    complex: Value(type.complex),
    highPerformance: Value(type.highPerformance),
    retractableGear: Value(type.retractableGear),
  );
}

/// Convert database AircraftType row to API model
models.AircraftType aircraftTypeFromRow(AircraftType row) {
  return models.AircraftType(
    id: row.id,
    icaoDesignator: row.icaoDesignator,
    manufacturer: row.manufacturer,
    model: row.model,
    category: row.category,
    engineCount: row.engineCount,
    engineType: row.engineType,
    wtc: row.wtc,
    multiPilot: row.multiPilot,
    complex: row.complex,
    highPerformance: row.highPerformance,
    retractableGear: row.retractableGear,
  );
}

// ============================================================================
// Flight Converters
// ============================================================================

/// Convert LogbookEntry to database companion
FlightsCompanion flightToCompanion(
  LogbookEntry entry, {
  required String syncStatus,
  String? serverUpdatedAt,
}) {
  final now = DateTime.now().toIso8601String();
  return FlightsCompanion(
    id: Value(entry.id),
    creatorUuid: Value(entry.creatorUUID),
    flightDate: Value(_formatDateOnly(entry.flightDate)),
    flightNumber: Value(entry.flightNumber),
    dep: Value(entry.dep),
    dest: Value(entry.dest),
    depIcao: Value(entry.depIcao),
    depIata: Value(entry.depIata),
    destIcao: Value(entry.destIcao),
    destIata: Value(entry.destIata),
    blockOff: Value(entry.blockOff.toIso8601String()),
    blockOn: Value(entry.blockOn.toIso8601String()),
    aircraftType: Value(entry.aircraftType),
    aircraftReg: Value(entry.displayReg),
    simReg: Value(entry.simReg),
    flightTimeJson: Value(jsonEncode(entry.flightTime.toJson())),
    isPilotFlying: Value(entry.isPilotFlying),
    approachesJson: Value(jsonEncode(entry.approaches.toJson())),
    crewJson: Value(jsonEncode(entry.crew.map((c) => c.toJson()).toList())),
    verificationsJson:
        Value(jsonEncode(entry.verifications.map((v) => v.toJson()).toList())),
    endorsementsJson:
        Value(jsonEncode(entry.endorsements.map((e) => e.toJson()).toList())),
    createdAt: Value(entry.createdAt.toIso8601String()),
    updatedAt: Value(entry.updatedAt.toIso8601String()),
    syncStatus: Value(syncStatus),
    serverUpdatedAt: Value(serverUpdatedAt),
    localUpdatedAt: Value(now),
  );
}

/// Convert database Flight row to LogbookEntry
LogbookEntry flightFromRow(Flight row) {
  final flightTimeMap =
      jsonDecode(row.flightTimeJson) as Map<String, dynamic>;
  final approachesMap = row.approachesJson != null
      ? jsonDecode(row.approachesJson!) as Map<String, dynamic>
      : <String, dynamic>{};
  final crewList = (jsonDecode(row.crewJson) as List<dynamic>)
      .map((c) => CrewMember.fromJson(c as Map<String, dynamic>))
      .toList();
  final verificationsList = row.verificationsJson != null
      ? (jsonDecode(row.verificationsJson!) as List<dynamic>)
          .map((v) => Verification.fromJson(v as Map<String, dynamic>))
          .toList()
      : <Verification>[];
  final endorsementsList = row.endorsementsJson != null
      ? (jsonDecode(row.endorsementsJson!) as List<dynamic>)
          .map((e) => Endorsement.fromJson(e as Map<String, dynamic>))
          .toList()
      : <Endorsement>[];

  return LogbookEntry(
    id: row.id,
    creatorUUID: row.creatorUuid,
    flightDate: _parseDateAsUtc(row.flightDate),
    flightNumber: row.flightNumber,
    dep: row.dep,
    dest: row.dest,
    depIcao: row.depIcao,
    depIata: row.depIata,
    destIcao: row.destIcao,
    destIata: row.destIata,
    blockOff: DateTime.parse(row.blockOff),
    blockOn: DateTime.parse(row.blockOn),
    aircraftType: row.aircraftType,
    aircraftReg: row.aircraftReg,
    simReg: row.simReg,
    flightTime: FlightTime.fromJson(flightTimeMap),
    isPilotFlying: row.isPilotFlying,
    approaches: Approaches.fromJson(approachesMap),
    crew: crewList,
    verifications: verificationsList,
    endorsements: endorsementsList,
    createdAt: DateTime.parse(row.createdAt),
    updatedAt: DateTime.parse(row.updatedAt),
  );
}

/// Convert database Flight row to LogbookEntryShort for list display
LogbookEntryShort flightToShort(Flight row) {
  // Calculate trust level from crew/verifications
  final crewList = (jsonDecode(row.crewJson) as List<dynamic>);
  final verificationsList = row.verificationsJson != null
      ? (jsonDecode(row.verificationsJson!) as List<dynamic>)
      : <dynamic>[];

  TrustLevel trustLevel;
  if (crewList.length >= 2) {
    trustLevel = TrustLevel.endorsed;
  } else if (verificationsList.isNotEmpty) {
    trustLevel = TrustLevel.tracked;
  } else {
    trustLevel = TrustLevel.logged;
  }

  final flightTimeMap =
      jsonDecode(row.flightTimeJson) as Map<String, dynamic>;
  final flightTime = FlightTime.fromJson(flightTimeMap);

  return LogbookEntryShort(
    id: row.id,
    date: _parseDateAsUtc(row.flightDate),
    depCode: row.dep,
    destCode: row.dest,
    depIcao: row.depIcao,
    depIata: row.depIata,
    destIcao: row.destIcao,
    destIata: row.destIata,
    acftReg: row.aircraftReg,
    acftType: row.aircraftType,
    simReg: row.simReg,
    blockTime: flightTime.formatted,
    trustLevel: trustLevel,
  );
}

/// Get sync status from flight row
String getFlightSyncStatus(Flight row) => row.syncStatus;

// ============================================================================
// Saved Pilot Converters
// ============================================================================

/// Convert API SavedPilot model to database companion
SavedPilotsCompanion savedPilotToCompanion(
  models.SavedPilot pilot, {
  required String userId,
  required String syncStatus,
  String? serverUpdatedAt,
}) {
  final now = DateTime.now().toIso8601String();
  return SavedPilotsCompanion(
    id: Value(pilot.id ?? ''),
    userId: Value(userId),
    name: Value(pilot.name),
    syncStatus: Value(syncStatus),
    serverUpdatedAt: Value(serverUpdatedAt),
    localUpdatedAt: Value(now),
    createdAt: Value(now),
    updatedAt: Value(now),
  );
}

/// Convert database SavedPilot row to API model
models.SavedPilot savedPilotFromRow(SavedPilot row) {
  return models.SavedPilot(
    id: row.id,
    name: row.name,
    flightCount: 0, // Flight count is calculated on server
    isManuallyAdded: true,
  );
}

// ============================================================================
// Helper Functions
// ============================================================================

/// Format date as YYYY-MM-DD
String _formatDateOnly(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Parse a date-only string (e.g., '2024-06-15') as UTC DateTime
DateTime _parseDateAsUtc(String dateString) {
  if (dateString.contains('T')) {
    return DateTime.parse(dateString).toUtc();
  }
  final parts = dateString.split('-');
  return DateTime.utc(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}
