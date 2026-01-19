/// Global aircraft type from ICAO Doc 8643 database
class AircraftType {
  final int id;
  final String icaoDesignator;
  final String manufacturer;
  final String model;
  final String category;
  final int engineCount;
  final String engineType;
  final String? wtc; // Wake turbulence category
  final bool? multiPilot;
  final bool? complex;
  final bool? highPerformance;
  final bool? retractableGear;

  AircraftType({
    required this.id,
    required this.icaoDesignator,
    required this.manufacturer,
    required this.model,
    required this.category,
    required this.engineCount,
    required this.engineType,
    this.wtc,
    this.multiPilot,
    this.complex,
    this.highPerformance,
    this.retractableGear,
  });

  factory AircraftType.fromJson(Map<String, dynamic> json) {
    return AircraftType(
      id: json['id'] as int,
      icaoDesignator: json['icaoDesignator'] as String,
      manufacturer: json['manufacturer'] as String,
      model: json['model'] as String,
      category: json['category'] as String,
      engineCount: json['engineCount'] as int,
      engineType: json['engineType'] as String,
      wtc: json['wtc'] as String?,
      multiPilot: json['multiPilot'] as bool?,
      complex: json['complex'] as bool?,
      highPerformance: json['highPerformance'] as bool?,
      retractableGear: json['retractableGear'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'icaoDesignator': icaoDesignator,
        'manufacturer': manufacturer,
        'model': model,
        'category': category,
        'engineCount': engineCount,
        'engineType': engineType,
        if (wtc != null) 'wtc': wtc,
        if (multiPilot != null) 'multiPilot': multiPilot,
        if (complex != null) 'complex': complex,
        if (highPerformance != null) 'highPerformance': highPerformance,
        if (retractableGear != null) 'retractableGear': retractableGear,
      };

  /// Display name like "A320 - Airbus A320"
  String get displayName => '$icaoDesignator - $manufacturer $model';

  /// Short display like "A320"
  String get shortName => icaoDesignator;

  /// Is this a multi-engine aircraft?
  bool get isMultiEngine => engineCount > 1;

  @override
  String toString() => displayName;
}
