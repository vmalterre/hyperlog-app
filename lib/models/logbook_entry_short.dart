import '../widgets/trust_badge.dart';

class LogbookEntryShort {
  final String id;
  final DateTime date;
  // Primary display codes (for backward compatibility)
  final String depCode;     // Primary code (ICAO preferred, fallback to IATA)
  final String destCode;    // Primary code (ICAO preferred, fallback to IATA)
  // Separate ICAO/IATA codes for display format preference
  final String? depIcao;    // 4-letter ICAO code (e.g., "EGLL")
  final String? depIata;    // 3-letter IATA code (e.g., "LHR")
  final String? destIcao;   // 4-letter ICAO code (e.g., "KJFK")
  final String? destIata;   // 3-letter IATA code (e.g., "JFK")
  final String acftReg;
  final String acftType;
  final String? blockTime;
  final TrustLevel trustLevel;

  LogbookEntryShort({
    required this.id,
    required this.date,
    required this.depCode,
    required this.destCode,
    this.depIcao,
    this.depIata,
    this.destIcao,
    this.destIata,
    required this.acftReg,
    required this.acftType,
    this.blockTime,
    this.trustLevel = TrustLevel.logged,
  });

  factory LogbookEntryShort.fromJson(Map<String, dynamic> json) {
    return LogbookEntryShort(
      id: json['id'],
      date: DateTime.parse(json['date']),
      depCode: json['depCode'] ?? json['depIata'] ?? '',  // Backward compatibility
      destCode: json['destCode'] ?? json['desIata'] ?? '', // Backward compatibility
      depIcao: json['depIcao'],
      depIata: json['depIata'],
      destIcao: json['destIcao'],
      destIata: json['destIata'],
      acftReg: json['acftReg'],
      acftType: json['acftType'],
      blockTime: json['blockTime'],
      trustLevel: TrustLevel.values.firstWhere(
        (e) => e.name == json['trustLevel'],
        orElse: () => TrustLevel.logged,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'depCode': depCode,
      'destCode': destCode,
      'depIcao': depIcao,
      'depIata': depIata,
      'destIcao': destIcao,
      'destIata': destIata,
      'acftReg': acftReg,
      'acftType': acftType,
      'blockTime': blockTime,
      'trustLevel': trustLevel.name,
    };
  }
}
