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

  Landings({this.day = 0, this.night = 0});

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

/// Crew member on a flight
/// GDPR-compliant: pilotUUID is stored on blockchain, name/license resolved from PostgreSQL
class CrewMember {
  final String pilotUUID;
  final String? pilotLicense; // Resolved from PostgreSQL for display
  final String? pilotName;    // Resolved from PostgreSQL for display
  final List<RoleSegment> roles;
  final Landings landings;
  final String remarks;
  final DateTime joinedAt;

  CrewMember({
    required this.pilotUUID,
    this.pilotLicense,
    this.pilotName,
    required this.roles,
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
      landings: json['landings'] != null
          ? Landings.fromJson(json['landings'])
          : Landings(),
      remarks: json['remarks'] ?? '',
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'pilotUUID': pilotUUID,
        if (pilotLicense != null) 'pilotLicense': pilotLicense,
        if (pilotName != null) 'pilotName': pilotName,
        'roles': roles.map((r) => r.toJson()).toList(),
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
/// SOLO was removed as it's derivable from flight data (PIC + no crew = solo time)
class FlightTime {
  final int total;
  final int night;
  final int ifr;

  // Primary role time fields (seat position - mutually exclusive)
  final int pic;        // PIC / P1 / Captain
  final int picus;      // PIC Under Supervision / P1 u/s
  final int sic;        // SIC / Co-pilot / P2

  // Secondary role time fields (activity - can combine with primary)
  final int dual;       // Dual instruction received
  final int instructor; // Instructor time given

  // Custom time fields (user-defined, name -> minutes)
  final Map<String, int> customFields;

  FlightTime({
    required this.total,
    this.night = 0,
    this.ifr = 0,
    this.pic = 0,
    this.picus = 0,
    this.sic = 0,
    this.dual = 0,
    this.instructor = 0,
    this.customFields = const {},
  });

  factory FlightTime.fromJson(Map<String, dynamic> json) {
    return FlightTime(
      total: json['total'] ?? 0,
      night: json['night'] ?? 0,
      ifr: json['ifr'] ?? 0,
      pic: json['pic'] ?? 0,
      picus: json['picus'] ?? 0,
      sic: json['sic'] ?? 0,
      dual: json['dual'] ?? 0,
      instructor: json['instructor'] ?? 0,
      customFields: (json['customFields'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'night': night,
        'ifr': ifr,
        'pic': pic,
        'picus': picus,
        'sic': sic,
        'dual': dual,
        'instructor': instructor,
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
      default:
        return customFields[fieldCode] ?? 0;
    }
  }

  /// Create a copy with updated values
  FlightTime copyWith({
    int? total,
    int? night,
    int? ifr,
    int? pic,
    int? picus,
    int? sic,
    int? dual,
    int? instructor,
    Map<String, int>? customFields,
  }) {
    return FlightTime(
      total: total ?? this.total,
      night: night ?? this.night,
      ifr: ifr ?? this.ifr,
      pic: pic ?? this.pic,
      picus: picus ?? this.picus,
      sic: sic ?? this.sic,
      dual: dual ?? this.dual,
      instructor: instructor ?? this.instructor,
      customFields: customFields ?? this.customFields,
    );
  }

  /// Create FlightTime from primary and optional secondary role
  /// Primary role determines seat position time (PIC, SIC, PICUS)
  /// Secondary role determines activity time (DUAL, INSTRUCTOR)
  factory FlightTime.fromRoles({
    required String primaryRole,
    String? secondaryRole,
    required int totalMinutes,
    int night = 0,
    int ifr = 0,
    Map<String, int>? customFields,
  }) {
    return FlightTime(
      total: totalMinutes,
      night: night,
      ifr: ifr,
      // Primary role (seat position)
      pic: primaryRole == 'PIC' ? totalMinutes : 0,
      picus: primaryRole == 'PICUS' ? totalMinutes : 0,
      sic: primaryRole == 'SIC' ? totalMinutes : 0,
      // Secondary role (activity)
      dual: secondaryRole == 'DUAL' ? totalMinutes : 0,
      instructor: secondaryRole == 'INSTRUCTOR' ? totalMinutes : 0,
      customFields: customFields ?? {},
    );
  }

  /// Create FlightTime from primary role only
  /// @deprecated Use fromRoles instead for primary + secondary support
  factory FlightTime.fromPrimaryRole(String primaryRole, int totalMinutes, {
    int night = 0,
    int ifr = 0,
    Map<String, int>? customFields,
  }) {
    return FlightTime.fromRoles(
      primaryRole: primaryRole,
      totalMinutes: totalMinutes,
      night: night,
      ifr: ifr,
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
  final String dep;
  final String dest;
  final DateTime blockOff;
  final DateTime blockOn;
  final String aircraftType;
  final String aircraftReg;
  final FlightTime flightTime;
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
    required this.blockOff,
    required this.blockOn,
    required this.aircraftType,
    required this.aircraftReg,
    required this.flightTime,
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
      blockOff: DateTime.parse(json['blockOff']),
      blockOn: DateTime.parse(json['blockOn']),
      aircraftType: json['aircraftType'],
      aircraftReg: json['aircraftReg'],
      flightTime: FlightTime.fromJson(json['flightTime']),
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
      depIata: dep,
      desIata: dest,
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
      'blockOff': blockOff.toUtc().toIso8601String(),
      'blockOn': blockOn.toUtc().toIso8601String(),
      'aircraftType': aircraftType,
      'aircraftReg': aircraftReg,
      'flightTime': flightTime.toJson(),
      'roles': creator?.roles.map((r) => r.toJson()).toList() ?? [],
      'landings': creator?.landings.toJson() ?? Landings().toJson(),
      'remarks': creator?.remarks ?? '',
      if (standardCrew.isNotEmpty) 'crew': standardCrew,
    };
  }

  /// Format date as YYYY-MM-DD (date only, no time)
  static String _formatDateOnly(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
