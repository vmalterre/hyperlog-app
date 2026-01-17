/// Role standards supported by HyperLog
enum RoleStandard {
  easa,
  faa,
  ukCaa,
  descriptive,
}

/// The 5 universal required time field codes
/// These are internal codes that map to different labels per standard
///
/// Role categories:
/// - Primary roles (seat position/authority): PIC, SIC, PICUS
/// - Secondary roles (activity/function): DUAL, INSTRUCTOR
///
/// SOLO was removed as it's derivable from flight data (PIC + no crew = solo time)
class TimeFieldCodes {
  static const String pic = 'PIC';
  static const String picus = 'PICUS';
  static const String sic = 'SIC';
  static const String dual = 'DUAL';
  static const String instructor = 'INSTRUCTOR';

  /// All time field codes in display order
  static const List<String> all = [pic, sic, picus, dual, instructor];

  /// Primary roles (seat position/authority) - mutually exclusive
  static const List<String> primary = [pic, sic, picus];

  /// Secondary roles (activity/function) - optional, can combine with primary
  static const List<String> secondary = [dual, instructor];

  /// Primary roles that can be selected for default role
  /// @deprecated Use primary instead
  static const List<String> primaryRoles = primary;
}

/// Label mapping for time fields per standard
class RoleStandards {
  /// Labels for each time field code by standard
  static const Map<RoleStandard, Map<String, String>> _labels = {
    RoleStandard.easa: {
      TimeFieldCodes.pic: 'P1',
      TimeFieldCodes.picus: 'P1 u/s',
      TimeFieldCodes.sic: 'Co-pilot',
      TimeFieldCodes.dual: 'Dual',
      TimeFieldCodes.instructor: 'Instructor',
    },
    RoleStandard.faa: {
      TimeFieldCodes.pic: 'Pilot in Command',
      TimeFieldCodes.picus: 'PICUS',
      TimeFieldCodes.sic: 'Second in Command',
      TimeFieldCodes.dual: 'Dual Received',
      TimeFieldCodes.instructor: 'Flight Instructor',
    },
    RoleStandard.ukCaa: {
      TimeFieldCodes.pic: 'P1',
      TimeFieldCodes.picus: 'PICUS',
      TimeFieldCodes.sic: 'P2',
      TimeFieldCodes.dual: 'Dual',
      TimeFieldCodes.instructor: 'Instructor',
    },
    RoleStandard.descriptive: {
      TimeFieldCodes.pic: 'Captain',
      TimeFieldCodes.picus: 'PIC Under Supervision',
      TimeFieldCodes.sic: 'Co-Pilot',
      TimeFieldCodes.dual: 'Student',
      TimeFieldCodes.instructor: 'Instructor',
    },
  };

  /// Descriptions for each time field code (standard-agnostic)
  static const Map<String, String> _descriptions = {
    TimeFieldCodes.pic: 'Pilot in Command time',
    TimeFieldCodes.picus: 'PIC under supervision time',
    TimeFieldCodes.sic: 'Second in Command time',
    TimeFieldCodes.dual: 'Dual instruction received time',
    TimeFieldCodes.instructor: 'Flight instruction given time',
  };

  /// Get display name for a role standard
  static String getDisplayName(RoleStandard standard) {
    return switch (standard) {
      RoleStandard.easa => 'EASA',
      RoleStandard.faa => 'FAA',
      RoleStandard.ukCaa => 'UK CAA',
      RoleStandard.descriptive => 'Descriptive',
    };
  }

  /// Get subtitle description for a role standard
  static String getSubtitle(RoleStandard standard) {
    final labels = _labels[standard]!;
    final roleList = TimeFieldCodes.primaryRoles
        .map((code) => labels[code]!)
        .join(', ');
    return switch (standard) {
      RoleStandard.easa => 'European standard\n$roleList',
      RoleStandard.faa => 'American standard\n$roleList',
      RoleStandard.ukCaa => 'UK standard\n$roleList',
      RoleStandard.descriptive => 'Plain English\n$roleList',
    };
  }

  /// Get label for a time field code in the given standard
  static String getLabel(RoleStandard standard, String code) {
    return _labels[standard]?[code] ?? code;
  }

  /// Get all labels for a standard (in display order)
  static Map<String, String> getLabels(RoleStandard standard) {
    return _labels[standard] ?? _labels[RoleStandard.easa]!;
  }

  /// Get description for a time field code
  static String getDescription(String code) {
    return _descriptions[code] ?? code;
  }

  /// Get default primary role for a standard (first in the list)
  static String getDefaultRole(RoleStandard standard) {
    return TimeFieldCodes.pic;
  }

  /// Get primary role codes (seat position) with their labels for a standard
  static List<({String code, String label})> getPrimaryRolesWithLabels(
      RoleStandard standard) {
    return TimeFieldCodes.primary
        .map((code) => (code: code, label: getLabel(standard, code)))
        .toList();
  }

  /// Get secondary role codes (activity) with their labels for a standard
  static List<({String code, String label})> getSecondaryRolesWithLabels(
      RoleStandard standard) {
    return TimeFieldCodes.secondary
        .map((code) => (code: code, label: getLabel(standard, code)))
        .toList();
  }

  /// Get all time field codes with their labels for a standard
  static List<({String code, String label})> getAllTimeFieldsWithLabels(
      RoleStandard standard) {
    return TimeFieldCodes.all
        .map((code) => (code: code, label: getLabel(standard, code)))
        .toList();
  }

  /// Check if a role code is a primary role
  static bool isPrimaryRole(String code) {
    return TimeFieldCodes.primary.contains(code);
  }

  /// Check if a role code is a secondary role
  static bool isSecondaryRole(String code) {
    return TimeFieldCodes.secondary.contains(code);
  }

  // Legacy compatibility methods

  /// Get role codes for a standard (for dropdown compatibility)
  /// @deprecated Use getPrimaryRolesWithLabels instead
  static List<String> getRoleCodes(RoleStandard standard) {
    return TimeFieldCodes.primary;
  }

  /// Get roles for a standard (legacy format)
  /// @deprecated Use getPrimaryRolesWithLabels instead
  static List<Role> getRoles(RoleStandard standard) {
    return TimeFieldCodes.primary
        .map((code) => Role(code, getLabel(standard, code)))
        .toList();
  }
}

/// Role data with code and description (legacy compatibility)
/// @deprecated Use TimeFieldCodes and RoleStandards.getLabel instead
class Role {
  final String code;
  final String description;

  const Role(this.code, this.description);
}
