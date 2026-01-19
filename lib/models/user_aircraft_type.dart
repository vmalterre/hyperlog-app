import 'aircraft_type.dart';

/// User's personal aircraft type with editable properties
class UserAircraftType {
  final String id;
  final String pilotId;
  final int aircraftTypeId;
  final bool multiEngine;
  final bool multiPilot;
  final String engineType;
  final bool complex;
  final bool highPerformance;
  final String category;
  final String? variant;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AircraftType? aircraftType; // Joined from global types

  UserAircraftType({
    required this.id,
    required this.pilotId,
    required this.aircraftTypeId,
    required this.multiEngine,
    required this.multiPilot,
    required this.engineType,
    required this.complex,
    required this.highPerformance,
    required this.category,
    this.variant,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.aircraftType,
  });

  factory UserAircraftType.fromJson(Map<String, dynamic> json) {
    return UserAircraftType(
      id: json['id'] as String,
      pilotId: json['pilotId'] as String,
      aircraftTypeId: json['aircraftTypeId'] as int,
      multiEngine: json['multiEngine'] as bool? ?? false,
      multiPilot: json['multiPilot'] as bool? ?? false,
      engineType: json['engineType'] as String? ?? 'PISTON',
      complex: json['complex'] as bool? ?? false,
      highPerformance: json['highPerformance'] as bool? ?? false,
      category: json['category'] as String? ?? 'LANDPLANE',
      variant: json['variant'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      aircraftType: json['aircraftType'] != null
          ? AircraftType.fromJson(json['aircraftType'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pilotId': pilotId,
        'aircraftTypeId': aircraftTypeId,
        'multiEngine': multiEngine,
        'multiPilot': multiPilot,
        'engineType': engineType,
        'complex': complex,
        'highPerformance': highPerformance,
        'category': category,
        if (variant != null) 'variant': variant,
        if (notes != null) 'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (aircraftType != null) 'aircraftType': aircraftType!.toJson(),
      };

  /// Display name - shows manufacturer + model
  String get displayName {
    if (aircraftType != null) {
      return '${aircraftType!.manufacturer} ${aircraftType!.model}';
    }
    return 'Unknown Type ($aircraftTypeId)';
  }

  /// Full display name for dropdowns: "ICAO - Manufacturer Model" or "ICAO - Manufacturer Model (Variant)"
  String get fullDisplayName {
    final icao = icaoDesignator;
    final base = displayName;

    if (variant != null && variant!.isNotEmpty) {
      return '$icao - $base ($variant)';
    }
    return '$icao - $base';
  }

  /// Short display for cards: "Manufacturer Model" or "Variant" if set
  String get shortDisplayName {
    if (variant != null && variant!.isNotEmpty) {
      return variant!;
    }
    return displayName;
  }

  /// Display name with variant but without ICAO: "Manufacturer Model" or "Manufacturer Model (Variant)"
  String get displayNameWithVariant {
    final base = displayName;
    if (variant != null && variant!.isNotEmpty) {
      return '$base ($variant)';
    }
    return base;
  }

  /// ICAO designator from the joined aircraft type
  String get icaoDesignator => aircraftType?.icaoDesignator ?? '';

  /// Manufacturer from the joined aircraft type
  String get manufacturer => aircraftType?.manufacturer ?? '';

  /// Model from the joined aircraft type
  String get model => aircraftType?.model ?? '';

  /// Create a copy with updated fields
  UserAircraftType copyWith({
    bool? multiEngine,
    bool? multiPilot,
    String? engineType,
    bool? complex,
    bool? highPerformance,
    String? category,
    String? variant,
    String? notes,
  }) {
    return UserAircraftType(
      id: id,
      pilotId: pilotId,
      aircraftTypeId: aircraftTypeId,
      multiEngine: multiEngine ?? this.multiEngine,
      multiPilot: multiPilot ?? this.multiPilot,
      engineType: engineType ?? this.engineType,
      complex: complex ?? this.complex,
      highPerformance: highPerformance ?? this.highPerformance,
      category: category ?? this.category,
      variant: variant ?? this.variant,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      aircraftType: aircraftType,
    );
  }

  @override
  String toString() => displayName;
}
