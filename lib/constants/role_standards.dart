/// Role standards supported by HyperLog
enum RoleStandard {
  easa,
  faa,
  descriptive,
}

/// Role data with code and description
class Role {
  final String code;
  final String description;

  const Role(this.code, this.description);
}

/// Role definitions for each standard
class RoleStandards {
  static const Map<RoleStandard, List<Role>> roles = {
    RoleStandard.easa: [
      Role('PIC', 'Pilot In Command'),
      Role('SIC', 'Second In Command'),
      Role('DUAL', 'Dual (Instruction)'),
      Role('SPIC', 'Student PIC'),
      Role('PICUS', 'PIC Under Supervision'),
      Role('FI', 'Flight Instructor'),
      Role('FE', 'Flight Examiner'),
      Role('SP', 'Single Pilot'),
      Role('RP', 'Relief Pilot'),
      Role('OBS', 'Observer'),
      Role('PUT', 'Pilot Under Training'),
    ],
    RoleStandard.faa: [
      Role('PIC', 'Pilot In Command'),
      Role('SIC', 'Second In Command'),
      Role('DUAL', 'Dual Instruction'),
      Role('SOLO', 'Solo Flight'),
      Role('CFI', 'Certificated Flight Instructor'),
      Role('SP', 'Safety Pilot'),
    ],
    RoleStandard.descriptive: [
      Role('Captain', 'Flying as captain'),
      Role('Co-Pilot', 'Flying as second pilot'),
      Role('Student', 'Receiving instruction'),
      Role('Instructor', 'Providing instruction'),
      Role('Observer', 'Observing only'),
      Role('Safety Pilot', 'Acting as safety observer'),
    ],
  };

  /// Get display name for a role standard
  static String getDisplayName(RoleStandard standard) {
    return switch (standard) {
      RoleStandard.easa => 'EASA',
      RoleStandard.faa => 'FAA',
      RoleStandard.descriptive => 'Descriptive',
    };
  }

  /// Get subtitle description for a role standard
  static String getSubtitle(RoleStandard standard) {
    return switch (standard) {
      RoleStandard.easa => 'European standard\nPIC, SIC, DUAL, SPIC, PICUS, FI, FE,\nSP, RP, OBS, PUT',
      RoleStandard.faa => 'American standard\nPIC, SIC, DUAL, SOLO, CFI, SP',
      RoleStandard.descriptive => 'Plain English\nCaptain, Co-Pilot, Student,\nInstructor, Observer, Safety Pilot',
    };
  }

  /// Get roles for a specific standard
  static List<Role> getRoles(RoleStandard standard) {
    return roles[standard] ?? roles[RoleStandard.easa]!;
  }

  /// Get role codes only for a specific standard
  static List<String> getRoleCodes(RoleStandard standard) {
    return getRoles(standard).map((r) => r.code).toList();
  }

  /// Get description for a role code within a standard
  static String getDescription(RoleStandard standard, String code) {
    final roleList = getRoles(standard);
    final role = roleList.where((r) => r.code == code).firstOrNull;
    return role?.description ?? code;
  }

  /// Get default role for a standard (first in list)
  static String getDefaultRole(RoleStandard standard) {
    return getRoles(standard).first.code;
  }
}
