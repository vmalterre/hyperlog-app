/// Aircraft category constants
class AircraftCategory {
  static const jet = 'jet';
  static const gaPiston = 'ga_piston';
  static const unknown = 'unknown';
}

/// Utility class for categorizing aircraft types
class AircraftCategorizer {
  // Common jet aircraft types (ICAO codes)
  static const Set<String> _jetTypes = {
    // Boeing
    'B737', 'B738', 'B739', 'B73H', 'B77W', 'B788', 'B789', 'B78X',
    'B744', 'B752', 'B753', 'B763', 'B764', 'B772', 'B773', 'B77L',
    // Airbus
    'A318', 'A319', 'A320', 'A321', 'A20N', 'A21N',
    'A332', 'A333', 'A339', 'A35K', 'A359', 'A388', 'A380',
    // Embraer jets
    'E170', 'E175', 'E190', 'E195', 'E290', 'E295',
    'E135', 'E145', 'E35L', 'E75L', 'E75S',
    // Regional jets
    'CRJ1', 'CRJ2', 'CRJ7', 'CRJ9', 'CRJX',
    // Business jets
    'C525', 'C550', 'C560', 'C680', 'C750', // Citation
    'GLF4', 'GLF5', 'GLEX', 'G280', 'G550', 'G650', // Gulfstream
    'CL30', 'CL35', 'CL60', 'GL5T', 'GL7T', // Challenger/Global
    'FA7X', 'F900', 'F2TH', // Falcon
    'LJ35', 'LJ45', 'LJ60', 'LJ75', // Learjet
    'PC24', // Pilatus jet
  };

  // Common GA/piston aircraft types (ICAO codes)
  static const Set<String> _gaPistonTypes = {
    // Cessna single-engine
    'C150', 'C152', 'C172', 'C177', 'C182', 'C206', 'C210',
    // Cessna multi-engine
    'C310', 'C340', 'C402', 'C414', 'C421',
    // Piper
    'PA28', 'PA32', 'PA34', 'PA44', 'PA46', 'PA31', 'PA24', 'PA30',
    'P28A', 'P28B', 'P28R', 'P28T', 'P32R', 'P32T',
    // Cirrus
    'SR20', 'SR22', 'SR22T',
    // Diamond
    'DA20', 'DA40', 'DA42', 'DA62',
    // Beechcraft
    'BE35', 'BE36', 'BE55', 'BE58', 'BE76',
    'B36T', 'BE33', 'BE23', 'BE24',
    // Mooney
    'M20P', 'M20R', 'M20T', 'M20J', 'M20K', 'M20M',
    // Robin
    'DR40', 'DR40D',
    // Socata/Daher
    'TB10', 'TB20', 'TB21', 'TBM7', 'TBM8', 'TBM9',
    // Grumman
    'AA5', 'AA5A', 'AA5B',
    // Tecnam
    'P2002', 'P2006', 'P2008', 'P2010', 'P2012',
  };

  // Turboprop types (categorized with jets for simplicity)
  static const Set<String> _turbopropTypes = {
    'AT43', 'AT45', 'AT72', 'AT76', // ATR
    'DH8A', 'DH8B', 'DH8C', 'DH8D', // Dash 8
    'SF34', 'SB20', // Saab
    'BE20', 'BE30', 'BE40', 'B190', 'B350', // Beech King Air
    'C208', // Cessna Caravan
    'PC12', 'PC6', // Pilatus
  };

  /// Categorize an aircraft type string
  static String categorize(String aircraftType) {
    final normalized = aircraftType.toUpperCase().trim();

    // Remove common suffixes/variants
    final base = normalized.replaceAll(RegExp(r'[-/].*'), '');

    if (_jetTypes.contains(normalized) || _jetTypes.contains(base)) {
      return AircraftCategory.jet;
    }

    if (_turbopropTypes.contains(normalized) || _turbopropTypes.contains(base)) {
      return AircraftCategory.jet; // Group turboprops with jets
    }

    if (_gaPistonTypes.contains(normalized) || _gaPistonTypes.contains(base)) {
      return AircraftCategory.gaPiston;
    }

    // Fallback heuristics based on common patterns
    if (normalized.startsWith('B7') || normalized.startsWith('A3') ||
        normalized.startsWith('E1') || normalized.startsWith('E2') ||
        normalized.startsWith('CRJ') || normalized.startsWith('GLF')) {
      return AircraftCategory.jet;
    }

    if (normalized.startsWith('C1') || normalized.startsWith('PA') ||
        normalized.startsWith('SR') || normalized.startsWith('DA') ||
        normalized.startsWith('BE') || normalized.startsWith('M20')) {
      return AircraftCategory.gaPiston;
    }

    return AircraftCategory.unknown;
  }

  /// Check if aircraft type is a jet
  static bool isJet(String aircraftType) =>
      categorize(aircraftType) == AircraftCategory.jet;

  /// Check if aircraft type is GA/piston
  static bool isGaPiston(String aircraftType) =>
      categorize(aircraftType) == AircraftCategory.gaPiston;
}
