/// Models for logbook import feature
///
/// Supports importing flight data from external providers (FlyLog, LogTen, etc.)

/// Supported import providers
enum ImportProvider {
  flylog;

  String get displayName {
    switch (this) {
      case ImportProvider.flylog:
        return 'FlyLog';
    }
  }

  String get description {
    switch (this) {
      case ImportProvider.flylog:
        return 'Import from FlyLog app CSV export';
    }
  }

  static ImportProvider? fromString(String value) {
    switch (value.toLowerCase()) {
      case 'flylog':
        return ImportProvider.flylog;
      default:
        return null;
    }
  }
}

/// Severity levels for import issues
enum IssueSeverity {
  error,
  warning,
  info;

  static IssueSeverity fromString(String value) {
    switch (value.toLowerCase()) {
      case 'error':
        return IssueSeverity.error;
      case 'warning':
        return IssueSeverity.warning;
      case 'info':
        return IssueSeverity.info;
      default:
        return IssueSeverity.info;
    }
  }
}

/// Crew member in import preview
class ImportCrewMember {
  final String name;
  final String role;

  const ImportCrewMember({required this.name, required this.role});

  factory ImportCrewMember.fromJson(Map<String, dynamic> json) {
    return ImportCrewMember(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
      };
}

/// Approach count in import preview
class ImportApproachCount {
  final String typeCode;
  final String typeName;
  final int count;

  const ImportApproachCount({
    required this.typeCode,
    required this.typeName,
    required this.count,
  });

  factory ImportApproachCount.fromJson(Map<String, dynamic> json) {
    return ImportApproachCount(
      typeCode: json['typeCode'] ?? '',
      typeName: json['typeName'] ?? '',
      count: json['count'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'typeCode': typeCode,
        'typeName': typeName,
        'count': count,
      };
}

/// A flight parsed from the import file, ready for preview
class ImportFlightPreview {
  final int rowIndex;
  final String flightDate;
  final String? flightNumber;
  final String depCode;
  final int? depAirportId;
  final String destCode;
  final int? destAirportId;
  final String? blockOff;
  final String? blockOn;
  final String aircraftType;
  final String? aircraftReg;
  final String? simReg;        // Simulator registration (set for sim sessions)
  final String? simDeviceRaw;  // Original device identifier from CSV (e.g., "B738SIM")
  final bool isSimulator;       // True if this is a simulator session
  final String? fstdCategory;  // For simulators: FFS, FTD, FNPT, BITD
  final String role;
  final bool isPilotFlying;
  final int takeoffsDay;
  final int takeoffsNight;
  final int landingsDay;
  final int landingsNight;
  // Time fields (in minutes)
  final int timeTotal;
  final int timeNight;
  final int timeIfr;
  final int timeIfrActual;
  final int timeIfrSimulated;
  final int timeXc;
  final int timeMultiPilot;
  final int timePic;
  final int timePicus;
  final int timeSic;
  final int timeDual;
  final int timeInstructor;
  final List<ImportApproachCount> approaches;
  final List<ImportCrewMember> crew;
  final String? remarks;

  const ImportFlightPreview({
    required this.rowIndex,
    required this.flightDate,
    this.flightNumber,
    required this.depCode,
    this.depAirportId,
    required this.destCode,
    this.destAirportId,
    this.blockOff,
    this.blockOn,
    required this.aircraftType,
    this.aircraftReg,
    this.simReg,
    this.simDeviceRaw,
    required this.isSimulator,
    this.fstdCategory,
    required this.role,
    required this.isPilotFlying,
    required this.takeoffsDay,
    required this.takeoffsNight,
    required this.landingsDay,
    required this.landingsNight,
    required this.timeTotal,
    required this.timeNight,
    required this.timeIfr,
    required this.timeIfrActual,
    required this.timeIfrSimulated,
    required this.timeXc,
    required this.timeMultiPilot,
    required this.timePic,
    required this.timePicus,
    required this.timeSic,
    required this.timeDual,
    required this.timeInstructor,
    required this.approaches,
    required this.crew,
    this.remarks,
  });

  factory ImportFlightPreview.fromJson(Map<String, dynamic> json) {
    return ImportFlightPreview(
      rowIndex: json['rowIndex'] ?? 0,
      flightDate: json['flightDate'] ?? '',
      flightNumber: json['flightNumber'],
      depCode: json['depCode'] ?? '',
      depAirportId: json['depAirportId'],
      destCode: json['destCode'] ?? '',
      destAirportId: json['destAirportId'],
      blockOff: json['blockOff'],
      blockOn: json['blockOn'],
      aircraftType: json['aircraftType'] ?? '',
      aircraftReg: json['aircraftReg'],
      simReg: json['simReg'],
      simDeviceRaw: json['simDeviceRaw'],
      isSimulator: json['isSimulator'] ?? false,
      fstdCategory: json['fstdCategory'],
      role: json['role'] ?? 'PIC',
      isPilotFlying: json['isPilotFlying'] ?? true,
      takeoffsDay: json['takeoffsDay'] ?? 0,
      takeoffsNight: json['takeoffsNight'] ?? 0,
      landingsDay: json['landingsDay'] ?? 0,
      landingsNight: json['landingsNight'] ?? 0,
      timeTotal: json['timeTotal'] ?? 0,
      timeNight: json['timeNight'] ?? 0,
      timeIfr: json['timeIfr'] ?? 0,
      timeIfrActual: json['timeIfrActual'] ?? 0,
      timeIfrSimulated: json['timeIfrSimulated'] ?? 0,
      timeXc: json['timeXc'] ?? 0,
      timeMultiPilot: json['timeMultiPilot'] ?? 0,
      timePic: json['timePic'] ?? 0,
      timePicus: json['timePicus'] ?? 0,
      timeSic: json['timeSic'] ?? 0,
      timeDual: json['timeDual'] ?? 0,
      timeInstructor: json['timeInstructor'] ?? 0,
      approaches: (json['approaches'] as List<dynamic>?)
              ?.map((e) => ImportApproachCount.fromJson(e))
              .toList() ??
          [],
      crew: (json['crew'] as List<dynamic>?)
              ?.map((e) => ImportCrewMember.fromJson(e))
              .toList() ??
          [],
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() => {
        'rowIndex': rowIndex,
        'flightDate': flightDate,
        if (flightNumber != null) 'flightNumber': flightNumber,
        'depCode': depCode,
        if (depAirportId != null) 'depAirportId': depAirportId,
        'destCode': destCode,
        if (destAirportId != null) 'destAirportId': destAirportId,
        if (blockOff != null) 'blockOff': blockOff,
        if (blockOn != null) 'blockOn': blockOn,
        'aircraftType': aircraftType,
        if (aircraftReg != null) 'aircraftReg': aircraftReg,
        if (simReg != null) 'simReg': simReg,
        if (simDeviceRaw != null) 'simDeviceRaw': simDeviceRaw,
        'isSimulator': isSimulator,
        if (fstdCategory != null) 'fstdCategory': fstdCategory,
        'role': role,
        'isPilotFlying': isPilotFlying,
        'takeoffsDay': takeoffsDay,
        'takeoffsNight': takeoffsNight,
        'landingsDay': landingsDay,
        'landingsNight': landingsNight,
        'timeTotal': timeTotal,
        'timeNight': timeNight,
        'timeIfr': timeIfr,
        'timeIfrActual': timeIfrActual,
        'timeIfrSimulated': timeIfrSimulated,
        'timeXc': timeXc,
        'timeMultiPilot': timeMultiPilot,
        'timePic': timePic,
        'timePicus': timePicus,
        'timeSic': timeSic,
        'timeDual': timeDual,
        'timeInstructor': timeInstructor,
        'approaches': approaches.map((a) => a.toJson()).toList(),
        'crew': crew.map((c) => c.toJson()).toList(),
        if (remarks != null) 'remarks': remarks,
      };

  /// Formatted flight time as HH:MM
  String get formattedFlightTime {
    final hours = timeTotal ~/ 60;
    final minutes = timeTotal % 60;
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  /// Route display string (or sim identifier for simulator sessions)
  String get route => isSimulator
      ? 'SIM: ${simReg ?? "Unknown"}'
      : '$depCode - $destCode';
}

/// An issue found during import analysis
class ImportIssue {
  final int rowIndex;
  final String type;
  final IssueSeverity severity;
  final String message;
  final String? field;
  final String? originalValue;
  final String? suggestedValue;
  final bool canImport;

  const ImportIssue({
    required this.rowIndex,
    required this.type,
    required this.severity,
    required this.message,
    this.field,
    this.originalValue,
    this.suggestedValue,
    required this.canImport,
  });

  factory ImportIssue.fromJson(Map<String, dynamic> json) {
    return ImportIssue(
      rowIndex: json['rowIndex'] ?? 0,
      type: json['type'] ?? '',
      severity: IssueSeverity.fromString(json['severity'] ?? 'info'),
      message: json['message'] ?? '',
      field: json['field'],
      originalValue: json['originalValue'],
      suggestedValue: json['suggestedValue'],
      canImport: json['canImport'] ?? true,
    );
  }
}

/// A duplicate flight detected during analysis
class ImportDuplicate {
  final int rowIndex;
  final String flightDate;
  final String route;           // "DEP-DEST" for flights, "SIM: {simReg}" for sims
  final String depCode;
  final String destCode;
  final String? aircraftReg;
  final String? simReg;         // Simulator registration (for sim duplicates)
  final String existingFlightId;
  final String reason;

  const ImportDuplicate({
    required this.rowIndex,
    required this.flightDate,
    required this.route,
    required this.depCode,
    required this.destCode,
    this.aircraftReg,
    this.simReg,
    required this.existingFlightId,
    required this.reason,
  });

  factory ImportDuplicate.fromJson(Map<String, dynamic> json) {
    return ImportDuplicate(
      rowIndex: json['rowIndex'] ?? 0,
      flightDate: json['flightDate'] ?? '',
      route: json['route'] ?? '',
      depCode: json['depCode'] ?? '',
      destCode: json['destCode'] ?? '',
      aircraftReg: json['aircraftReg'],
      simReg: json['simReg'],
      existingFlightId: json['existingFlightId'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}

/// A crew member that matched an existing saved pilot
class CrewMatch {
  final String importedName;
  final String matchedName;
  final int flightCount;

  const CrewMatch({
    required this.importedName,
    required this.matchedName,
    required this.flightCount,
  });

  factory CrewMatch.fromJson(Map<String, dynamic> json) {
    return CrewMatch(
      importedName: json['importedName'] ?? '',
      matchedName: json['matchedName'] ?? '',
      flightCount: json['flightCount'] ?? 0,
    );
  }
}

/// Summary of the import analysis
class ImportSummary {
  final int flightsToImport;
  final int totalFlightTime;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const ImportSummary({
    required this.flightsToImport,
    required this.totalFlightTime,
    this.dateFrom,
    this.dateTo,
  });

  factory ImportSummary.fromJson(Map<String, dynamic> json) {
    final dateRange = json['dateRange'] as Map<String, dynamic>?;
    return ImportSummary(
      flightsToImport: json['flightsToImport'] ?? 0,
      totalFlightTime: json['totalFlightTime'] ?? 0,
      dateFrom: dateRange?['from'] != null
          ? DateTime.parse(dateRange!['from'])
          : null,
      dateTo:
          dateRange?['to'] != null ? DateTime.parse(dateRange!['to']) : null,
    );
  }

  /// Formatted total flight time
  String get formattedFlightTime {
    final hours = totalFlightTime ~/ 60;
    final minutes = totalFlightTime % 60;
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }
}

/// Result of analyzing an import file
class ImportAnalysis {
  final ImportProvider provider;
  final int totalRows;
  final List<String> parseErrors;
  final List<ImportFlightPreview> ready;
  final List<ImportIssue> needsAttention;
  final List<ImportDuplicate> duplicates;
  final List<String> newCrewMembers;
  final List<CrewMatch> existingCrewMatches;
  final ImportSummary summary;

  const ImportAnalysis({
    required this.provider,
    required this.totalRows,
    required this.parseErrors,
    required this.ready,
    required this.needsAttention,
    required this.duplicates,
    required this.newCrewMembers,
    required this.existingCrewMatches,
    required this.summary,
  });

  factory ImportAnalysis.fromJson(Map<String, dynamic> json) {
    return ImportAnalysis(
      provider: ImportProvider.fromString(json['provider'] ?? 'flylog') ??
          ImportProvider.flylog,
      totalRows: json['totalRows'] ?? 0,
      parseErrors:
          (json['parseErrors'] as List<dynamic>?)?.cast<String>() ?? [],
      ready: (json['ready'] as List<dynamic>?)
              ?.map((e) => ImportFlightPreview.fromJson(e))
              .toList() ??
          [],
      needsAttention: (json['needsAttention'] as List<dynamic>?)
              ?.map((e) => ImportIssue.fromJson(e))
              .toList() ??
          [],
      duplicates: (json['duplicates'] as List<dynamic>?)
              ?.map((e) => ImportDuplicate.fromJson(e))
              .toList() ??
          [],
      newCrewMembers:
          (json['newCrewMembers'] as List<dynamic>?)?.cast<String>() ?? [],
      existingCrewMatches: (json['existingCrewMatches'] as List<dynamic>?)
              ?.map((e) => CrewMatch.fromJson(e))
              .toList() ??
          [],
      summary: ImportSummary.fromJson(json['summary'] ?? {}),
    );
  }

  /// True if there are errors that prevent import
  bool get hasErrors =>
      parseErrors.isNotEmpty ||
      needsAttention.any((i) => i.severity == IssueSeverity.error);

  /// True if there are warnings to review
  bool get hasWarnings =>
      needsAttention.any((i) => i.severity == IssueSeverity.warning);

  /// Count of issues by severity
  int issueCountBySeverity(IssueSeverity severity) =>
      needsAttention.where((i) => i.severity == severity).length;
}

/// Aggregated totals from imported flights for verification
class ImportTotals {
  final int totalMinutes;
  final int picMinutes;
  final int picusMinutes;
  final int sicMinutes;
  final int multiPilotMinutes;
  final int nightMinutes;
  final int ifrMinutes;
  final int ifrActualMinutes;
  final int ifrSimulatedMinutes;
  final int dualMinutes;
  final int instructorMinutes;
  final int xcMinutes;
  final int totalLandings;

  const ImportTotals({
    required this.totalMinutes,
    required this.picMinutes,
    required this.picusMinutes,
    required this.sicMinutes,
    required this.multiPilotMinutes,
    required this.nightMinutes,
    required this.ifrMinutes,
    required this.ifrActualMinutes,
    required this.ifrSimulatedMinutes,
    required this.dualMinutes,
    required this.instructorMinutes,
    required this.xcMinutes,
    required this.totalLandings,
  });

  /// Create totals by aggregating from a list of flights
  factory ImportTotals.fromFlights(List<ImportFlightPreview> flights) {
    int total = 0;
    int pic = 0;
    int picus = 0;
    int sic = 0;
    int multiPilot = 0;
    int night = 0;
    int ifr = 0;
    int ifrActual = 0;
    int ifrSimulated = 0;
    int dual = 0;
    int instructor = 0;
    int xc = 0;
    int landings = 0;

    for (final flight in flights) {
      total += flight.timeTotal;
      pic += flight.timePic;
      picus += flight.timePicus;
      sic += flight.timeSic;
      multiPilot += flight.timeMultiPilot;
      night += flight.timeNight;
      ifr += flight.timeIfr;
      ifrActual += flight.timeIfrActual;
      ifrSimulated += flight.timeIfrSimulated;
      dual += flight.timeDual;
      instructor += flight.timeInstructor;
      xc += flight.timeXc;
      landings += flight.landingsDay + flight.landingsNight;
    }

    return ImportTotals(
      totalMinutes: total,
      picMinutes: pic,
      picusMinutes: picus,
      sicMinutes: sic,
      multiPilotMinutes: multiPilot,
      nightMinutes: night,
      ifrMinutes: ifr,
      ifrActualMinutes: ifrActual,
      ifrSimulatedMinutes: ifrSimulated,
      dualMinutes: dual,
      instructorMinutes: instructor,
      xcMinutes: xc,
      totalLandings: landings,
    );
  }

  static String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins.toString().padLeft(2, '0')}m';
  }

  String get totalFormatted => _formatMinutes(totalMinutes);
  String get picFormatted => _formatMinutes(picMinutes);
  String get picusFormatted => _formatMinutes(picusMinutes);
  String get sicFormatted => _formatMinutes(sicMinutes);
  String get multiPilotFormatted => _formatMinutes(multiPilotMinutes);
  String get nightFormatted => _formatMinutes(nightMinutes);
  String get ifrFormatted => _formatMinutes(ifrMinutes);
  String get ifrActualFormatted => _formatMinutes(ifrActualMinutes);
  String get ifrSimulatedFormatted => _formatMinutes(ifrSimulatedMinutes);
  String get dualFormatted => _formatMinutes(dualMinutes);
  String get instructorFormatted => _formatMinutes(instructorMinutes);
  String get xcFormatted => _formatMinutes(xcMinutes);
  String get landingsFormatted => totalLandings.toString();
}

/// Result of executing an import
class ImportReport {
  final bool success;
  final int imported;
  final int skipped;
  final int crewCreated;
  final int totalFlightTime;
  final List<String> flightIds;
  final List<String> errors;
  // Aircraft stats (derived from imported flights)
  final int aircraftTypesCount;
  final int aircraftRegistrationsCount;
  // Simulator stats (derived from imported flights)
  final int simulatorSessionsCount;
  final int simulatorTypesCount;
  final int simulatorRegistrationsCount;
  final int simulatorTime;

  const ImportReport({
    required this.success,
    required this.imported,
    required this.skipped,
    required this.crewCreated,
    required this.totalFlightTime,
    required this.flightIds,
    required this.errors,
    this.aircraftTypesCount = 0,
    this.aircraftRegistrationsCount = 0,
    this.simulatorSessionsCount = 0,
    this.simulatorTypesCount = 0,
    this.simulatorRegistrationsCount = 0,
    this.simulatorTime = 0,
  });

  factory ImportReport.fromJson(Map<String, dynamic> json) {
    return ImportReport(
      success: json['success'] ?? false,
      imported: json['imported'] ?? 0,
      skipped: json['skipped'] ?? 0,
      crewCreated: json['crewCreated'] ?? 0,
      totalFlightTime: json['totalFlightTime'] ?? 0,
      flightIds: (json['flightIds'] as List<dynamic>?)?.cast<String>() ?? [],
      errors: (json['errors'] as List<dynamic>?)?.cast<String>() ?? [],
      aircraftTypesCount: json['aircraftTypesCount'] ?? 0,
      aircraftRegistrationsCount: json['aircraftRegistrationsCount'] ?? 0,
      simulatorSessionsCount: json['simulatorSessionsCount'] ?? 0,
      simulatorTypesCount: json['simulatorTypesCount'] ?? 0,
      simulatorRegistrationsCount: json['simulatorRegistrationsCount'] ?? 0,
      simulatorTime: json['simulatorTime'] ?? 0,
    );
  }

  /// Create report with stats derived from the imported flights
  factory ImportReport.fromJsonWithFlightStats(
    Map<String, dynamic> json,
    List<ImportFlightPreview> importedFlights,
  ) {
    // Calculate aircraft stats
    final aircraftTypes = <String>{};
    final aircraftRegs = <String>{};
    final simTypes = <String>{};
    final simRegs = <String>{};
    int simSessions = 0;
    int simTime = 0;

    for (final flight in importedFlights) {
      if (flight.isSimulator) {
        simSessions++;
        simTime += flight.timeTotal;
        // Simulator type is the aircraftType field (e.g., "FNPT II", "FTD FRASCA141")
        simTypes.add(flight.aircraftType);
        if (flight.simReg != null && flight.simReg!.isNotEmpty) {
          simRegs.add(flight.simReg!);
        }
      } else {
        aircraftTypes.add(flight.aircraftType);
        if (flight.aircraftReg != null && flight.aircraftReg!.isNotEmpty) {
          aircraftRegs.add(flight.aircraftReg!);
        }
      }
    }

    return ImportReport(
      success: json['success'] ?? false,
      imported: json['imported'] ?? 0,
      skipped: json['skipped'] ?? 0,
      crewCreated: json['crewCreated'] ?? 0,
      totalFlightTime: json['totalFlightTime'] ?? 0,
      flightIds: (json['flightIds'] as List<dynamic>?)?.cast<String>() ?? [],
      errors: (json['errors'] as List<dynamic>?)?.cast<String>() ?? [],
      aircraftTypesCount: aircraftTypes.length,
      aircraftRegistrationsCount: aircraftRegs.length,
      simulatorSessionsCount: simSessions,
      simulatorTypesCount: simTypes.length,
      simulatorRegistrationsCount: simRegs.length,
      simulatorTime: simTime,
    );
  }

  /// Formatted total flight time
  String get formattedFlightTime {
    final hours = totalFlightTime ~/ 60;
    final minutes = totalFlightTime % 60;
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  /// Formatted simulator time
  String get formattedSimulatorTime {
    final hours = simulatorTime ~/ 60;
    final minutes = simulatorTime % 60;
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  /// Number of actual flights (excluding simulators)
  int get flightsCount => imported - simulatorSessionsCount;
}
