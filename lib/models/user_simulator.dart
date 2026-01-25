import 'aircraft_type.dart';

/// FSTD (Flight Simulation Training Device) category
enum FstdCategory {
  ffs,  // Full Flight Simulator (A, B, C, D - D = highest)
  ftd,  // Flight Training Device (1-7)
  fnpt, // Flight Navigation Procedures Trainer (I, II, III)
  bitd, // Basic Instrument Training Device (no levels)
}

/// Helper extension for FstdCategory
extension FstdCategoryExtension on FstdCategory {
  String get displayName {
    switch (this) {
      case FstdCategory.ffs:
        return 'FFS';
      case FstdCategory.ftd:
        return 'FTD';
      case FstdCategory.fnpt:
        return 'FNPT';
      case FstdCategory.bitd:
        return 'BITD';
    }
  }

  String get fullName {
    switch (this) {
      case FstdCategory.ffs:
        return 'Full Flight Simulator';
      case FstdCategory.ftd:
        return 'Flight Training Device';
      case FstdCategory.fnpt:
        return 'Flight Navigation Procedures Trainer';
      case FstdCategory.bitd:
        return 'Basic Instrument Training Device';
    }
  }

  /// Valid levels for this category
  List<String> get validLevels {
    switch (this) {
      case FstdCategory.ffs:
        return ['A', 'B', 'C', 'D'];
      case FstdCategory.ftd:
        return ['1', '2', '3', '4', '5', '6', '7'];
      case FstdCategory.fnpt:
        return ['I', 'II', 'III'];
      case FstdCategory.bitd:
        return [];
    }
  }

  /// Whether this category has qualification levels
  bool get hasLevels => validLevels.isNotEmpty;
}

// =============================================================================
// User Simulator Type (Level 1)
// =============================================================================

/// User's simulator type (defines a simulator classification like "FFS-D B738")
class UserSimulatorType {
  final String id;
  final String pilotId;
  final int? aircraftTypeId; // Nullable for generic training devices (FNPT, BITD)
  final FstdCategory fstdCategory;
  final String? fstdLevel;
  final String? deviceName; // Device identifier for training devices (e.g., FRASCA142, FNPT2)
  final String? deviceManufacturer; // Device brand (e.g., FRASCA, Redbird, Alsim)
  final String? deviceModel; // Device model (e.g., 141, 142, TD2)
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AircraftType? aircraftType; // Joined from global types
  final int? registrationCount; // Computed: count of registrations

  UserSimulatorType({
    required this.id,
    required this.pilotId,
    this.aircraftTypeId,
    required this.fstdCategory,
    this.fstdLevel,
    this.deviceName,
    this.deviceManufacturer,
    this.deviceModel,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.aircraftType,
    this.registrationCount,
  });

  factory UserSimulatorType.fromJson(Map<String, dynamic> json) {
    return UserSimulatorType(
      id: json['id'] as String,
      pilotId: json['pilotId'] as String,
      aircraftTypeId: json['aircraftTypeId'] as int?,
      fstdCategory: _parseCategory(json['fstdCategory'] as String),
      fstdLevel: json['fstdLevel'] as String?,
      deviceName: json['deviceName'] as String?,
      deviceManufacturer: json['deviceManufacturer'] as String?,
      deviceModel: json['deviceModel'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      aircraftType: json['aircraftType'] != null
          ? AircraftType.fromJson(json['aircraftType'] as Map<String, dynamic>)
          : null,
      registrationCount: json['registrationCount'] as int?,
    );
  }

  static FstdCategory _parseCategory(String value) {
    switch (value.toUpperCase()) {
      case 'FFS':
        return FstdCategory.ffs;
      case 'FTD':
        return FstdCategory.ftd;
      case 'FNPT':
        return FstdCategory.fnpt;
      case 'BITD':
        return FstdCategory.bitd;
      default:
        throw ArgumentError('Invalid FSTD category: $value');
    }
  }

  static String categoryToString(FstdCategory category) {
    return category.displayName;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pilotId': pilotId,
        if (aircraftTypeId != null) 'aircraftTypeId': aircraftTypeId,
        'fstdCategory': categoryToString(fstdCategory),
        if (fstdLevel != null) 'fstdLevel': fstdLevel,
        if (deviceName != null) 'deviceName': deviceName,
        if (deviceManufacturer != null) 'deviceManufacturer': deviceManufacturer,
        if (deviceModel != null) 'deviceModel': deviceModel,
        if (notes != null) 'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (aircraftType != null) 'aircraftType': aircraftType!.toJson(),
        if (registrationCount != null) 'registrationCount': registrationCount,
      };

  /// Category with level, e.g., "FFS-D" or "FNPT-II" or "BITD"
  String get categoryLevelDisplay {
    if (fstdLevel != null && fstdLevel!.isNotEmpty) {
      return '${fstdCategory.displayName}-$fstdLevel';
    }
    return fstdCategory.displayName;
  }

  /// Short display name: "<Category> <Level> <Brand> <Model>"
  /// Examples: "FNPT II", "FTD FRASCA Mentor", "FFS D"
  String get displayName {
    final parts = <String>[fstdCategory.displayName];

    // Add qualification level if present
    if (fstdLevel != null && fstdLevel!.isNotEmpty) {
      parts.add(fstdLevel!);
    }

    // Add brand (device manufacturer) if present
    if (deviceManufacturer != null && deviceManufacturer!.isNotEmpty) {
      parts.add(deviceManufacturer!);
    }

    // Add model (device model) if present, but skip if it's the same as fstdLevel
    if (deviceModel != null &&
        deviceModel!.isNotEmpty &&
        deviceModel != fstdLevel) {
      parts.add(deviceModel!);
    }

    return parts.join(' ');
  }

  /// Full display name: "FFS-D Boeing 737-800"
  String get fullDisplayName {
    final typeName = aircraftType != null
        ? '${aircraftType!.manufacturer} ${aircraftType!.model}'
        : '';
    return typeName.isNotEmpty ? '$categoryLevelDisplay $typeName' : categoryLevelDisplay;
  }

  /// Aircraft type display name
  String get aircraftTypeDisplay {
    if (aircraftType != null) {
      return '${aircraftType!.manufacturer} ${aircraftType!.model}';
    }
    if (aircraftTypeId != null) {
      return 'Unknown Type ($aircraftTypeId)';
    }
    return 'Generic Device';
  }

  /// ICAO designator from the joined aircraft type
  String get icaoDesignator => aircraftType?.icaoDesignator ?? '';

  /// Create a copy with updated fields
  UserSimulatorType copyWith({
    int? aircraftTypeId,
    FstdCategory? fstdCategory,
    String? fstdLevel,
    String? deviceName,
    String? deviceManufacturer,
    String? deviceModel,
    String? notes,
    AircraftType? aircraftType,
  }) {
    return UserSimulatorType(
      id: id,
      pilotId: pilotId,
      aircraftTypeId: aircraftTypeId ?? this.aircraftTypeId,
      fstdCategory: fstdCategory ?? this.fstdCategory,
      fstdLevel: fstdLevel ?? this.fstdLevel,
      deviceName: deviceName ?? this.deviceName,
      deviceManufacturer: deviceManufacturer ?? this.deviceManufacturer,
      deviceModel: deviceModel ?? this.deviceModel,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      aircraftType: aircraftType ?? this.aircraftType,
      registrationCount: registrationCount,
    );
  }

  @override
  String toString() => displayName;
}

// =============================================================================
// User Simulator Registration (Level 2)
// =============================================================================

/// User's simulator registration (a specific device linked to a type)
class UserSimulatorRegistration {
  final String id;
  final String userSimulatorTypeId;
  final String registration;
  final String? trainingFacility;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserSimulatorType? simulatorType; // Joined data

  UserSimulatorRegistration({
    required this.id,
    required this.userSimulatorTypeId,
    required this.registration,
    this.trainingFacility,
    required this.createdAt,
    required this.updatedAt,
    this.simulatorType,
  });

  factory UserSimulatorRegistration.fromJson(Map<String, dynamic> json) {
    return UserSimulatorRegistration(
      id: json['id'] as String,
      userSimulatorTypeId: json['userSimulatorTypeId'] as String,
      registration: json['registration'] as String,
      trainingFacility: json['trainingFacility'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      simulatorType: json['simulatorType'] != null
          ? UserSimulatorType.fromJson(
              json['simulatorType'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userSimulatorTypeId': userSimulatorTypeId,
        'registration': registration,
        if (trainingFacility != null) 'trainingFacility': trainingFacility,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (simulatorType != null) 'simulatorType': simulatorType!.toJson(),
      };

  /// Display name: "FR-123" or "FR-123 @ CAE London"
  String get displayName {
    if (trainingFacility != null && trainingFacility!.isNotEmpty) {
      return '$registration @ $trainingFacility';
    }
    return registration;
  }

  /// Full display name for dropdowns: "FR-123 - FFS-D B738 @ CAE London"
  String get fullDisplayName {
    final parts = <String>[registration];

    if (simulatorType != null) {
      parts.add('-');
      parts.add(simulatorType!.displayName);
    }

    if (trainingFacility != null && trainingFacility!.isNotEmpty) {
      parts.add('@ $trainingFacility');
    }

    return parts.join(' ');
  }

  /// Get the simulator type display name
  String get simulatorTypeDisplay => simulatorType?.displayName ?? 'Unknown';

  /// Get category level display (e.g., "FFS-D")
  String get categoryLevelDisplay =>
      simulatorType?.categoryLevelDisplay ?? 'Unknown';

  /// Get the ICAO designator
  String get icaoDesignator => simulatorType?.icaoDesignator ?? '';

  /// Get the aircraft type display
  String get aircraftTypeDisplay =>
      simulatorType?.aircraftTypeDisplay ?? 'Unknown';

  /// Get FSTD category
  FstdCategory? get fstdCategory => simulatorType?.fstdCategory;

  /// Get FSTD level
  String? get fstdLevel => simulatorType?.fstdLevel;

  @override
  String toString() => fullDisplayName;
}
