import '../widgets/trust_badge.dart';
import 'logbook_entry_short.dart';

/// Flight time breakdown (values in minutes)
class FlightTime {
  final int total;
  final int night;
  final int ifr;
  final int pic;
  final int sic;
  final int dual;

  FlightTime({
    required this.total,
    this.night = 0,
    this.ifr = 0,
    this.pic = 0,
    this.sic = 0,
    this.dual = 0,
  });

  factory FlightTime.fromJson(Map<String, dynamic> json) {
    return FlightTime(
      total: json['total'] ?? 0,
      night: json['night'] ?? 0,
      ifr: json['ifr'] ?? 0,
      pic: json['pic'] ?? 0,
      sic: json['sic'] ?? 0,
      dual: json['dual'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'night': night,
        'ifr': ifr,
        'pic': pic,
        'sic': sic,
        'dual': dual,
      };

  /// Format total minutes as HH:MM
  String get formatted {
    final hours = total ~/ 60;
    final minutes = total % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
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

/// Full logbook entry matching backend API
class LogbookEntry {
  final String id;
  final String pilotLicense;
  final DateTime flightDate;
  final String? flightNumber;
  final String dep;
  final String dest;
  final DateTime blockOff;
  final DateTime blockOn;
  final String aircraftType;
  final String aircraftReg;
  final FlightTime flightTime;
  final Landings landings;
  final String role;
  final String? remarks;
  final TrustLevel trustLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  LogbookEntry({
    required this.id,
    required this.pilotLicense,
    required this.flightDate,
    this.flightNumber,
    required this.dep,
    required this.dest,
    required this.blockOff,
    required this.blockOn,
    required this.aircraftType,
    required this.aircraftReg,
    required this.flightTime,
    required this.landings,
    required this.role,
    this.remarks,
    this.trustLevel = TrustLevel.logged,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LogbookEntry.fromJson(Map<String, dynamic> json) {
    return LogbookEntry(
      id: json['id'],
      pilotLicense: json['pilotLicense'],
      flightDate: DateTime.parse(json['flightDate']),
      flightNumber: json['flightNumber'],
      dep: json['dep'],
      dest: json['dest'],
      blockOff: DateTime.parse(json['blockOff']),
      blockOn: DateTime.parse(json['blockOn']),
      aircraftType: json['aircraftType'],
      aircraftReg: json['aircraftReg'],
      flightTime: FlightTime.fromJson(json['flightTime']),
      landings: Landings.fromJson(json['landings']),
      role: json['role'],
      remarks: json['remarks'],
      trustLevel: _parseTrustLevel(json['trustLevel']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Convert backend trust level string to enum
  static TrustLevel _parseTrustLevel(String? level) {
    switch (level?.toUpperCase()) {
      case 'TRACKED':
        return TrustLevel.tracked;
      case 'ENDORSED':
        return TrustLevel.endorsed;
      case 'LOGGED':
      default:
        return TrustLevel.logged;
    }
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

  Map<String, dynamic> toJson() => {
        'pilotLicense': pilotLicense,
        'flightDate': flightDate.toUtc().toIso8601String(),
        'flightNumber': flightNumber ?? '',
        'dep': dep,
        'dest': dest,
        'blockOff': blockOff.toUtc().toIso8601String(),
        'blockOn': blockOn.toUtc().toIso8601String(),
        'aircraftType': aircraftType,
        'aircraftReg': aircraftReg,
        'flightTime': flightTime.toJson(),
        'landings': landings.toJson(),
        'role': role,
        'remarks': remarks ?? '',
      };
}
