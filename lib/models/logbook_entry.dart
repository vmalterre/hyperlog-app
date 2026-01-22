import '../widgets/trust_badge.dart';
import 'logbook_entry_short.dart';

/// Parse a date-only string (e.g., '2024-06-15') as UTC DateTime.
/// This ensures consistent behavior across timezones for date-only fields.
DateTime _parseDateAsUtc(String dateString) {
  // If it's already an ISO8601 with time/timezone, parse directly
  if (dateString.contains('T')) {
    return DateTime.parse(dateString).toUtc();
  }
  // For date-only strings, parse and create UTC date at midnight
  final parts = dateString.split('-');
  return DateTime.utc(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

/// External verification of a flight (from Trust Engine, instructors, etc.)
class Verification {
  final String source;
  final DateTime verifiedAt;
  final String verifiedBy;
  final String matchData;

  Verification({
    required this.source,
    required this.verifiedAt,
    required this.verifiedBy,
    this.matchData = '',
  });

  factory Verification.fromJson(Map<String, dynamic> json) {
    return Verification(
      source: json['source'] ?? '',
      verifiedAt: DateTime.parse(json['verifiedAt']),
      verifiedBy: json['verifiedBy'] ?? '',
      matchData: json['matchData'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'source': source,
        'verifiedAt': verifiedAt.toUtc().toIso8601String(),
        'verifiedBy': verifiedBy,
        'matchData': matchData,
      };
}

/// Role segment with timestamps for tracking split duties
/// Valid roles: PIC, SIC, DUAL, SOLO, SPIC, PICUS, FI, FE, SP, RP, OBS
class RoleSegment {
  final String role;
  final DateTime start;
  final DateTime end;

  RoleSegment({
    required this.role,
    required this.start,
    required this.end,
  });

  factory RoleSegment.fromJson(Map<String, dynamic> json) {
    return RoleSegment(
      role: json['role'] ?? '',
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role,
        'start': start.toUtc().toIso8601String(),
        'end': end.toUtc().toIso8601String(),
      };

  /// Duration of this role segment in minutes
  int get durationMinutes => end.difference(start).inMinutes;
}

/// Landings breakdown
class Landings {
  final int day;
  final int night;

  const Landings({this.day = 0, this.night = 0});

  factory Landings.fromJson(Map<String, dynamic> json) {
    return Landings(
      day: json['day'] ?? 0,
      night: json['night'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'night': night,
      };

  int get total => day + night;
}

/// Takeoffs breakdown
class Takeoffs {
  final int day;
  final int night;

  const Takeoffs({this.day = 0, this.night = 0});

  factory Takeoffs.fromJson(Map<String, dynamic> json) {
    return Takeoffs(
      day: json['day'] ?? 0,
      night: json['night'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'night': night,
      };

  int get total => day + night;
}

/// Approaches breakdown by type
class Approaches {
  final int visual;
  final int ilsCatI;
  final int ilsCatII;
  final int ilsCatIII;
  final int rnp;
  final int rnpAr;
  final int vor;
  final int ndb;
  final int ilsBackCourse;
  final int localizer;

  const Approaches({
    this.visual = 0,
    this.ilsCatI = 0,
    this.ilsCatII = 0,
    this.ilsCatIII = 0,
    this.rnp = 0,
    this.rnpAr = 0,
    this.vor = 0,
    this.ndb = 0,
    this.ilsBackCourse = 0,
    this.localizer = 0,
  });

  factory Approaches.fromJson(Map<String, dynamic> json) {
    return Approaches(
      visual: json['visual'] ?? 0,
      ilsCatI: json['ilsCatI'] ?? 0,
      ilsCatII: json['ilsCatII'] ?? 0,
      ilsCatIII: json['ilsCatIII'] ?? 0,
      rnp: json['rnp'] ?? 0,
      rnpAr: json['rnpAr'] ?? 0,
      vor: json['vor'] ?? 0,
      ndb: json['ndb'] ?? 0,
      ilsBackCourse: json['ilsBackCourse'] ?? 0,
      localizer: json['localizer'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'visual': visual,
        'ilsCatI': ilsCatI,
        'ilsCatII': ilsCatII,
        'ilsCatIII': ilsCatIII,
        'rnp': rnp,
        'rnpAr': rnpAr,
        'vor': vor,
        'ndb': ndb,
        'ilsBackCourse': ilsBackCourse,
        'localizer': localizer,
      };

  int get total =>
      visual +
      ilsCatI +
      ilsCatII +
      ilsCatIII +
      rnp +
      rnpAr +
      vor +
      ndb +
      ilsBackCourse +
      localizer;

  bool get hasAny => total > 0;

  /// Returns a formatted string of non-zero approaches
  /// e.g., "2 ILS I, 1 VOR" or "3 Visual"
  String get formatted {
    final parts = <String>[];
    if (visual > 0) parts.add('$visual Visual');
    if (ilsCatI > 0) parts.add('$ilsCatI ILS I');
    if (ilsCatII > 0) parts.add('$ilsCatII ILS II');
    if (ilsCatIII > 0) parts.add('$ilsCatIII ILS III');
    if (rnp > 0) parts.add('$rnp RNP');
    if (rnpAr > 0) parts.add('$rnpAr RNP AR');
    if (vor > 0) parts.add('$vor VOR');
    if (ndb > 0) parts.add('$ndb NDB');
    if (ilsBackCourse > 0) parts.add('$ilsBackCourse ILS BC');
    if (localizer > 0) parts.add('$localizer LOC');
    return parts.isEmpty ? '0' : parts.join(', ');
  }
}

/// Crew member on a flight
/// GDPR-compliant: pilotUUID is stored on blockchain, name/license resolved from PostgreSQL
class CrewMember {
  final String pilotUUID;
  final String? pilotLicense; // Resolved from PostgreSQL for display
  final String? pilotName;    // Resolved from PostgreSQL for display
  final List<RoleSegment> roles;
  final Takeoffs takeoffs;
  final Landings landings;
  final String remarks;
  final DateTime joinedAt;

  CrewMember({
    required this.pilotUUID,
    this.pilotLicense,
    this.pilotName,
    required this.roles,
    this.takeoffs = const Takeoffs(),
    required this.landings,
    this.remarks = '',
    required this.joinedAt,
  });

  factory CrewMember.fromJson(Map<String, dynamic> json) {
    return CrewMember(
      pilotUUID: json['pilotUUID'] ?? '',
      pilotLicense: json['pilotLicense'],
      pilotName: json['pilotName'],
      roles: (json['roles'] as List<dynamic>?)
              ?.map((r) => RoleSegment.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      takeoffs: json['takeoffs'] != null
          ? Takeoffs.fromJson(json['takeoffs'])
          : const Takeoffs(),
      landings: json['landings'] != null
          ? Landings.fromJson(json['landings'])
          : const Landings(),
      remarks: json['remarks'] ?? '',
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'pilotUUID': pilotUUID,
        if (pilotLicense != null) 'pilotLicense': pilotLicense,
        if (pilotName != null) 'pilotName': pilotName,
        'roles': roles.map((r) => r.toJson()).toList(),
        'takeoffs': takeoffs.toJson(),
        'landings': landings.toJson(),
        'remarks': remarks,
        'joinedAt': joinedAt.toUtc().toIso8601String(),
      };

  /// Get the primary role (longest duration or first if equal)
  String get primaryRole {
    if (roles.isEmpty) return '';
    return roles.reduce((a, b) =>
        a.durationMinutes >= b.durationMinutes ? a : b).role;
  }

  /// Get the secondary role (DUAL or INSTRUCTOR) if present
  /// Returns null if no secondary role is set
  String? get secondaryRole {
    const secondaryRoles = ['DUAL', 'INSTRUCTOR'];
    for (final segment in roles) {
      if (secondaryRoles.contains(segment.role.toUpperCase())) {
        return segment.role;
      }
    }
    return null;
  }

  /// Calculate total time in a specific role across all segments
  int roleTimeMinutes(String role) {
    return roles
        .where((r) => r.role == role)
        .fold(0, (sum, r) => sum + r.durationMinutes);
  }
}

/// Endorsement from another pilot
/// GDPR-compliant: endorserUUID is stored on blockchain, name/license resolved from PostgreSQL
class Endorsement {
  final String endorserUUID;
  final String? endorserLicense; // Resolved from PostgreSQL for display
  final String? endorserName;    // Resolved from PostgreSQL for display
  final String endorserRole;
  final DateTime endorsedAt;
  final String? remarks;

  Endorsement({
    required this.endorserUUID,
    this.endorserLicense,
    this.endorserName,
    required this.endorserRole,
    required this.endorsedAt,
    this.remarks,
  });

  factory Endorsement.fromJson(Map<String, dynamic> json) {
    return Endorsement(
      endorserUUID: json['endorserUUID'] ?? '',
      endorserLicense: json['endorserLicense'],
      endorserName: json['endorserName'],
      endorserRole: json['endorserRole'] ?? '',
      endorsedAt: DateTime.parse(json['endorsedAt']),
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() => {
        'endorserUUID': endorserUUID,
        if (endorserLicense != null) 'endorserLicense': endorserLicense,
        if (endorserName != null) 'endorserName': endorserName,
        'endorserRole': endorserRole,
        'endorsedAt': endorsedAt.toUtc().toIso8601String(),
        if (remarks != null) 'remarks': remarks,
      };
}

/// Flight time breakdown (values in minutes)
/// Includes the 5 universal required time fields for role-based tracking
///
/// Role categories:
/// - Primary roles (seat position): PIC, SIC, PICUS
/// - Secondary roles (activity): DUAL, INSTRUCTOR
///
/// Detail time fields (flight conditions/characteristics):
/// - solo: Time flown without instructor/crew
/// - multiEngine: Time in multi-engine aircraft
/// - crossCountry: Time on cross-country flights (>50nm)
/// - multiPilot: Multi-pilot operations time
/// - flight: Airborne time (takeoff to landing)
/// - ifrActual: Actual IFR time (in IMC)
/// - ifrSimulated: Simulated IFR time (under hood)
class FlightTime {
  final int total;
  final int night;
  final int ifr;

  // IFR breakdown
  final int ifrActual;     // Actual IFR time in minutes (in IMC)
  final int ifrSimulated;  // Simulated IFR time in minutes (under hood)

  // Primary role time fields (seat position - mutually exclusive)
  final int pic;        // PIC / P1 / Captain
  final int picus;      // PIC Under Supervision / P1 u/s
  final int sic;        // SIC / Co-pilot / P2

  // Secondary role time fields (activity - can combine with primary)
  final int dual;       // Dual instruction received
  final int instructor; // Instructor time given

  // Detail time fields (flight conditions/characteristics)
  final int solo;        // Solo flight time (no instructor/crew)
  final int multiEngine; // Multi-engine aircraft time
  final int crossCountry; // Cross-country flight time (>50nm)
  final int multiPilot;  // Multi-pilot operations time
  final int flight;      // Airborne time (takeoff to landing)

  // Custom time fields (user-defined, name -> minutes)
  final Map<String, int> customFields;

  FlightTime({
    required this.total,
    this.night = 0,
    this.ifr = 0,
    this.ifrActual = 0,
    this.ifrSimulated = 0,
    this.pic = 0,
    this.picus = 0,
    this.sic = 0,
    this.dual = 0,
    this.instructor = 0,
    this.solo = 0,
    this.multiEngine = 0,
    this.crossCountry = 0,
    this.multiPilot = 0,
    this.flight = 0,
    this.customFields = const {},
  });

  factory FlightTime.fromJson(Map<String, dynamic> json) {
    return FlightTime(
      total: json['total'] ?? 0,
      night: json['night'] ?? 0,
      ifr: json['ifr'] ?? 0,
      ifrActual: json['ifrActual'] ?? 0,
      ifrSimulated: json['ifrSimulated'] ?? 0,
      pic: json['pic'] ?? 0,
      picus: json['picus'] ?? 0,
      sic: json['sic'] ?? 0,
      dual: json['dual'] ?? 0,
      instructor: json['instructor'] ?? 0,
      solo: json['solo'] ?? 0,
      multiEngine: json['multiEngine'] ?? 0,
      crossCountry: json['crossCountry'] ?? json['xc'] ?? 0,
      multiPilot: json['multiPilot'] ?? 0,
      flight: json['flight'] ?? 0,
      customFields: (json['customFields'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'night': night,
        'ifr': ifr,
        'ifrActual': ifrActual,
        'ifrSimulated': ifrSimulated,
        'pic': pic,
        'picus': picus,
        'sic': sic,
        'dual': dual,
        'instructor': instructor,
        'solo': solo,
        'multiEngine': multiEngine,
        'crossCountry': crossCountry,
        'multiPilot': multiPilot,
        'flight': flight,
        if (customFields.isNotEmpty) 'customFields': customFields,
      };

  /// Format total minutes as HH:MM
  String get formatted {
    final hours = total ~/ 60;
    final minutes = total % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  /// Format a duration in minutes as HH:MM
  static String formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  /// Get time value for a given field code
  int getTimeForField(String fieldCode) {
    switch (fieldCode) {
      case 'PIC':
        return pic;
      case 'PICUS':
        return picus;
      case 'SIC':
        return sic;
      case 'DUAL':
        return dual;
      case 'INSTRUCTOR':
        return instructor;
      case 'SOLO':
        return solo;
      case 'MULTI_ENGINE':
        return multiEngine;
      case 'CROSS_COUNTRY':
        return crossCountry;
      case 'MULTI_PILOT':
        return multiPilot;
      case 'FLIGHT':
        return flight;
      case 'IFR_ACTUAL':
        return ifrActual;
      case 'IFR_SIMULATED':
        return ifrSimulated;
      default:
        return customFields[fieldCode] ?? 0;
    }
  }

  /// Create a copy with updated values
  FlightTime copyWith({
    int? total,
    int? night,
    int? ifr,
    int? ifrActual,
    int? ifrSimulated,
    int? pic,
    int? picus,
    int? sic,
    int? dual,
    int? instructor,
    int? solo,
    int? multiEngine,
    int? crossCountry,
    int? multiPilot,
    int? flight,
    Map<String, int>? customFields,
  }) {
    return FlightTime(
      total: total ?? this.total,
      night: night ?? this.night,
      ifr: ifr ?? this.ifr,
      ifrActual: ifrActual ?? this.ifrActual,
      ifrSimulated: ifrSimulated ?? this.ifrSimulated,
      pic: pic ?? this.pic,
      picus: picus ?? this.picus,
      sic: sic ?? this.sic,
      dual: dual ?? this.dual,
      instructor: instructor ?? this.instructor,
      solo: solo ?? this.solo,
      multiEngine: multiEngine ?? this.multiEngine,
      crossCountry: crossCountry ?? this.crossCountry,
      multiPilot: multiPilot ?? this.multiPilot,
      flight: flight ?? this.flight,
      customFields: customFields ?? this.customFields,
    );
  }

  /// Create FlightTime from primary and optional secondary role
  /// Primary role determines seat position time (PIC, SIC, PICUS)
  /// Secondary role determines activity time (DUAL, INSTRUCTOR)
  /// If roleMinutes is provided, use that for the role time instead of totalMinutes
  factory FlightTime.fromRoles({
    required String primaryRole,
    String? secondaryRole,
    required int totalMinutes,
    int? roleMinutes,
    int night = 0,
    int ifr = 0,
    int ifrActual = 0,
    int ifrSimulated = 0,
    int solo = 0,
    int multiEngine = 0,
    int crossCountry = 0,
    int multiPilot = 0,
    int flight = 0,
    Map<String, int>? customFields,
  }) {
    final effectiveRoleTime = roleMinutes ?? totalMinutes;
    return FlightTime(
      total: totalMinutes,
      night: night,
      ifr: ifr,
      ifrActual: ifrActual,
      ifrSimulated: ifrSimulated,
      // Primary role (seat position)
      pic: primaryRole == 'PIC' ? effectiveRoleTime : 0,
      picus: primaryRole == 'PICUS' ? effectiveRoleTime : 0,
      sic: primaryRole == 'SIC' ? effectiveRoleTime : 0,
      // Secondary role (activity)
      dual: secondaryRole == 'DUAL' ? effectiveRoleTime : 0,
      instructor: secondaryRole == 'INSTRUCTOR' ? effectiveRoleTime : 0,
      // Detail fields
      solo: solo,
      multiEngine: multiEngine,
      crossCountry: crossCountry,
      multiPilot: multiPilot,
      flight: flight,
      customFields: customFields ?? {},
    );
  }

  /// Create FlightTime from primary role only
  /// @deprecated Use fromRoles instead for primary + secondary support
  factory FlightTime.fromPrimaryRole(String primaryRole, int totalMinutes, {
    int? roleMinutes,
    int night = 0,
    int ifr = 0,
    int ifrActual = 0,
    int ifrSimulated = 0,
    int solo = 0,
    int multiEngine = 0,
    int crossCountry = 0,
    int multiPilot = 0,
    int flight = 0,
    Map<String, int>? customFields,
  }) {
    return FlightTime.fromRoles(
      primaryRole: primaryRole,
      totalMinutes: totalMinutes,
      roleMinutes: roleMinutes,
      night: night,
      ifr: ifr,
      ifrActual: ifrActual,
      ifrSimulated: ifrSimulated,
      solo: solo,
      multiEngine: multiEngine,
      crossCountry: crossCountry,
      multiPilot: multiPilot,
      flight: flight,
      customFields: customFields,
    );
  }
}

/// Full logbook entry matching backend API
/// GDPR-compliant: creatorUUID is stored on blockchain, creatorLicense resolved from PostgreSQL
/// Note: TrustLevel is computed by the app, not stored on blockchain
class LogbookEntry {
  final String id;
  final String creatorUUID;         // UUID from blockchain (GDPR-compliant)
  final String? creatorLicense;     // Resolved from PostgreSQL for display
  final DateTime flightDate;
  final String? flightNumber;
  final String dep;                 // Primary display code (ICAO preferred)
  final String dest;                // Primary display code (ICAO preferred)
  // Separate ICAO/IATA codes for display format preference
  final String? depIcao;            // 4-letter ICAO code (e.g., "EGLL")
  final String? depIata;            // 3-letter IATA code (e.g., "LHR")
  final String? destIcao;           // 4-letter ICAO code (e.g., "KJFK")
  final String? destIata;           // 3-letter IATA code (e.g., "JFK")
  final DateTime blockOff;          // Chocks off time
  final DateTime blockOn;           // Chocks on time
  final DateTime? takeoffAt;        // Wheels up time (optional)
  final DateTime? landingAt;        // Wheels down time (optional)
  final String aircraftType;
  final String aircraftReg;
  final FlightTime flightTime;
  final bool isPilotFlying;         // true = PF (can log landings), false = PM
  final Approaches approaches;      // Approaches by type (only for PF)
  final List<CrewMember> crew;
  final List<Verification> verifications;
  final List<Endorsement> endorsements;
  final DateTime createdAt;
  final DateTime updatedAt;

  LogbookEntry({
    required this.id,
    required this.creatorUUID,
    this.creatorLicense,
    required this.flightDate,
    this.flightNumber,
    required this.dep,
    required this.dest,
    this.depIcao,
    this.depIata,
    this.destIcao,
    this.destIata,
    required this.blockOff,
    required this.blockOn,
    this.takeoffAt,
    this.landingAt,
    required this.aircraftType,
    required this.aircraftReg,
    required this.flightTime,
    this.isPilotFlying = true,
    this.approaches = const Approaches(),
    this.crew = const [],
    this.verifications = const [],
    this.endorsements = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory LogbookEntry.fromJson(Map<String, dynamic> json) {
    return LogbookEntry(
      id: json['id'],
      creatorUUID: json['creatorUUID'] ?? '',
      creatorLicense: json['creatorLicense'],
      flightDate: _parseDateAsUtc(json['flightDate']),
      flightNumber: json['flightNumber'],
      dep: json['dep'],
      dest: json['dest'],
      // Parse separate ICAO/IATA codes for display format preference
      depIcao: json['depIcao'],
      depIata: json['depIata'],
      destIcao: json['destIcao'],
      destIata: json['destIata'],
      blockOff: DateTime.parse(json['blockOff']),
      blockOn: DateTime.parse(json['blockOn']),
      takeoffAt: json['takeoffAt'] != null ? DateTime.parse(json['takeoffAt']) : null,
      landingAt: json['landingAt'] != null ? DateTime.parse(json['landingAt']) : null,
      aircraftType: json['aircraftType'],
      aircraftReg: json['aircraftReg'],
      flightTime: json['flightTime'] != null
          ? FlightTime.fromJson(json['flightTime'])
          : FlightTime(total: 0),
      isPilotFlying: json['isPilotFlying'] ?? true, // Default true for backward compatibility
      approaches: json['approaches'] != null
          ? Approaches.fromJson(json['approaches'])
          : const Approaches(),
      crew: (json['crew'] as List<dynamic>?)
              ?.map((c) => CrewMember.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      verifications: (json['verifications'] as List<dynamic>?)
              ?.map((v) => Verification.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      endorsements: (json['endorsements'] as List<dynamic>?)
              ?.map((e) => Endorsement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Compute trust level from entry data (not stored on blockchain)
  /// - ENDORSED: 2+ pilots in the crew array
  /// - TRACKED: Third-party verification exists (FR24, ADS-B, organization)
  /// - LOGGED: Single pilot (creator only), no external verification
  TrustLevel get trustLevel {
    // ENDORSED: 2+ pilots in the crew array
    if (crew.length >= 2) {
      return TrustLevel.endorsed;
    }
    // TRACKED: Third-party organization verified the entry
    if (verifications.isNotEmpty) {
      return TrustLevel.tracked;
    }
    // LOGGED: Single pilot (creator only), no external verification
    return TrustLevel.logged;
  }

  /// Get the creator's crew entry (first crew member with matching UUID)
  CrewMember? get creatorCrew {
    try {
      return crew.firstWhere((c) => c.pilotUUID == creatorUUID);
    } catch (_) {
      return crew.isNotEmpty ? crew.first : null;
    }
  }

  /// Get total takeoffs from all crew members (typically only PF logs takeoffs)
  Takeoffs get totalTakeoffs {
    int day = 0;
    int night = 0;
    for (final c in crew) {
      day += c.takeoffs.day;
      night += c.takeoffs.night;
    }
    return Takeoffs(day: day, night: night);
  }

  /// Get total landings from all crew members (typically only PF logs landings)
  Landings get totalLandings {
    int day = 0;
    int night = 0;
    for (final c in crew) {
      day += c.landings.day;
      night += c.landings.night;
    }
    return Landings(day: day, night: night);
  }

  /// Convert to short format for list display
  LogbookEntryShort toShort() {
    return LogbookEntryShort(
      id: id,
      date: flightDate,
      depCode: dep,
      destCode: dest,
      depIcao: depIcao,
      depIata: depIata,
      destIcao: destIcao,
      destIata: destIata,
      acftReg: aircraftReg,
      acftType: aircraftType,
      blockTime: flightTime.formatted,
      trustLevel: trustLevel,
    );
  }

  /// Convert to JSON for API (CreateFlightRequest format)
  Map<String, dynamic> toJson() {
    final creator = creatorCrew;

    // Build standard crew list (other crew members, not the creator)
    // Format: { name: string, role: string }
    final standardCrew = crew
        .where((c) => c.pilotUUID != creatorUUID)
        .map((c) => {
              'name': c.pilotName ?? '',
              'role': c.primaryRole,
            })
        .where((c) => (c['name'] as String).isNotEmpty)
        .toList();

    return {
      // Primary: UUID for API operations
      'userId': creatorUUID,
      'flightDate': _formatDateOnly(flightDate),
      'flightNumber': flightNumber ?? '',
      'dep': dep,
      'dest': dest,
      // Include ICAO/IATA codes when available (from airport autocomplete)
      if (depIcao != null) 'depIcao': depIcao,
      if (depIata != null) 'depIata': depIata,
      if (destIcao != null) 'destIcao': destIcao,
      if (destIata != null) 'destIata': destIata,
      'blockOff': blockOff.toUtc().toIso8601String(),
      'blockOn': blockOn.toUtc().toIso8601String(),
      if (takeoffAt != null) 'takeoffAt': takeoffAt!.toUtc().toIso8601String(),
      if (landingAt != null) 'landingAt': landingAt!.toUtc().toIso8601String(),
      'aircraftType': aircraftType,
      'aircraftReg': aircraftReg,
      'flightTime': flightTime.toJson(),
      'isPilotFlying': isPilotFlying,
      'approaches': approaches.toJson(),
      'roles': creator?.roles.map((r) => r.toJson()).toList() ?? [],
      'takeoffs': creator?.takeoffs.toJson() ?? const Takeoffs().toJson(),
      'landings': creator?.landings.toJson() ?? const Landings().toJson(),
      'remarks': creator?.remarks ?? '',
      if (standardCrew.isNotEmpty) 'crew': standardCrew,
    };
  }

  /// Format date as YYYY-MM-DD (date only, no time)
  static String _formatDateOnly(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
