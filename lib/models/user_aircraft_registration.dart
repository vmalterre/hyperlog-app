import 'user_aircraft_type.dart';

/// User's aircraft registration linked to their aircraft type
class UserAircraftRegistration {
  final String id;
  final String pilotId;
  final String registration;
  final String userAircraftTypeId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserAircraftType? userAircraftType; // Joined data

  UserAircraftRegistration({
    required this.id,
    required this.pilotId,
    required this.registration,
    required this.userAircraftTypeId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.userAircraftType,
  });

  factory UserAircraftRegistration.fromJson(Map<String, dynamic> json) {
    return UserAircraftRegistration(
      id: json['id'] as String,
      pilotId: json['pilotId'] as String,
      registration: json['registration'] as String,
      userAircraftTypeId: json['userAircraftTypeId'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userAircraftType: json['userAircraftType'] != null
          ? UserAircraftType.fromJson(
              json['userAircraftType'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pilotId': pilotId,
        'registration': registration,
        'userAircraftTypeId': userAircraftTypeId,
        if (notes != null) 'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (userAircraftType != null)
          'userAircraftType': userAircraftType!.toJson(),
      };

  /// Get the aircraft type display name (includes variant if set, no ICAO)
  String get aircraftTypeDisplay {
    if (userAircraftType != null) {
      return userAircraftType!.displayNameWithVariant;
    }
    return 'Unknown';
  }

  /// Get the ICAO designator
  String get icaoDesignator => userAircraftType?.icaoDesignator ?? '';

  /// Get if aircraft is multi-engine
  bool get isMultiEngine => userAircraftType?.multiEngine ?? false;

  /// Get if aircraft requires multi-pilot
  bool get isMultiPilot => userAircraftType?.multiPilot ?? false;

  /// Get if aircraft is complex
  bool get isComplex => userAircraftType?.complex ?? false;

  /// Get if aircraft is high performance
  bool get isHighPerformance => userAircraftType?.highPerformance ?? false;

  /// Get engine type
  String get engineType => userAircraftType?.engineType ?? 'PISTON';

  /// Get category
  String get category => userAircraftType?.category ?? 'LANDPLANE';

  @override
  String toString() => '$registration ($icaoDesignator)';
}
