/// Defines all optional flight fields that can be shown/hidden in custom screens.
/// Required fields (Date, From, To, Aircraft, Block Times, Self crew with role)
/// are not included here as they cannot be hidden.
enum FlightField {
  // Flight Details
  flightNumber,

  // Manual time fields
  ifrTime,
  soloTime,
  customTimeFields,

  // Calculated time fields (display only - still calculated if hidden)
  nightTime,
  crossCountryTime,
  multiEngineTime,
  multiPilotTime,

  // Crew
  additionalCrew,

  // Takeoffs and Landings
  pfPmToggle,
  takeoffsLandings,

  // Approaches (only shown for PF anyway)
  approaches,

  // Remarks
  remarks,
}

/// Metadata for a flight field, providing display information
class FlightFieldMeta {
  final FlightField field;
  final String label;
  final String section;
  final String description;
  final bool isCalculated;

  const FlightFieldMeta({
    required this.field,
    required this.label,
    required this.section,
    required this.description,
    this.isCalculated = false,
  });
}

/// Static metadata for all flight fields
class FlightFieldsMeta {
  static const Map<FlightField, FlightFieldMeta> _metadata = {
    FlightField.flightNumber: FlightFieldMeta(
      field: FlightField.flightNumber,
      label: 'Flight Number',
      section: 'Flight Details',
      description: 'Commercial flight number (e.g. BA 123)',
    ),
    FlightField.ifrTime: FlightFieldMeta(
      field: FlightField.ifrTime,
      label: 'IFR Time',
      section: 'Times',
      description: 'Instrument flight rules time (manual entry)',
    ),
    FlightField.soloTime: FlightFieldMeta(
      field: FlightField.soloTime,
      label: 'Solo Time',
      section: 'Times',
      description: 'Time flying as sole occupant',
    ),
    FlightField.customTimeFields: FlightFieldMeta(
      field: FlightField.customTimeFields,
      label: 'Custom Time Fields',
      section: 'Times',
      description: 'Your custom time fields from My Roles',
    ),
    FlightField.nightTime: FlightFieldMeta(
      field: FlightField.nightTime,
      label: 'Night Time',
      section: 'Times',
      description: 'Auto-calculated based on airports and times',
      isCalculated: true,
    ),
    FlightField.crossCountryTime: FlightFieldMeta(
      field: FlightField.crossCountryTime,
      label: 'Cross-Country Time',
      section: 'Times',
      description: 'Auto-calculated when destination is 50+ NM away',
      isCalculated: true,
    ),
    FlightField.multiEngineTime: FlightFieldMeta(
      field: FlightField.multiEngineTime,
      label: 'Multi-Engine Time',
      section: 'Times',
      description: 'Auto-set based on aircraft type',
      isCalculated: true,
    ),
    FlightField.multiPilotTime: FlightFieldMeta(
      field: FlightField.multiPilotTime,
      label: 'Multi-Pilot Time',
      section: 'Times',
      description: 'Auto-set based on aircraft type',
      isCalculated: true,
    ),
    FlightField.additionalCrew: FlightFieldMeta(
      field: FlightField.additionalCrew,
      label: 'Additional Crew',
      section: 'Crew',
      description: 'Add crew members beyond yourself',
    ),
    FlightField.pfPmToggle: FlightFieldMeta(
      field: FlightField.pfPmToggle,
      label: 'PF/PM Toggle',
      section: 'Takeoffs & Landings',
      description: 'Toggle between Pilot Flying and Pilot Monitoring',
    ),
    FlightField.takeoffsLandings: FlightFieldMeta(
      field: FlightField.takeoffsLandings,
      label: 'Takeoffs & Landings',
      section: 'Takeoffs & Landings',
      description: 'Day/night takeoff and landing counts',
    ),
    FlightField.approaches: FlightFieldMeta(
      field: FlightField.approaches,
      label: 'Approaches',
      section: 'Approaches',
      description: 'Instrument approach types and counts',
    ),
    FlightField.remarks: FlightFieldMeta(
      field: FlightField.remarks,
      label: 'Remarks',
      section: 'Remarks',
      description: 'Notes about the flight',
    ),
  };

  /// Get metadata for a specific field
  static FlightFieldMeta? get(FlightField field) => _metadata[field];

  /// Get all fields metadata
  static List<FlightFieldMeta> get all => _metadata.values.toList();

  /// Get fields grouped by section
  static Map<String, List<FlightFieldMeta>> get bySection {
    final Map<String, List<FlightFieldMeta>> result = {};
    for (final meta in _metadata.values) {
      result.putIfAbsent(meta.section, () => []).add(meta);
    }
    return result;
  }

  /// Get the ordered list of sections
  static List<String> get sectionOrder => [
        'Flight Details',
        'Times',
        'Crew',
        'Takeoffs & Landings',
        'Approaches',
        'Remarks',
      ];
}
