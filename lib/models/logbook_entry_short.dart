import '../widgets/trust_badge.dart';

class LogbookEntryShort {
  final String id;
  final DateTime date;
  final String depIata;
  final String desIata;
  final String acftReg;
  final String acftType;
  final String? blockTime;
  final TrustLevel trustLevel;

  LogbookEntryShort({
    required this.id,
    required this.date,
    required this.depIata,
    required this.desIata,
    required this.acftReg,
    required this.acftType,
    this.blockTime,
    this.trustLevel = TrustLevel.logged,
  });

  factory LogbookEntryShort.fromJson(Map<String, dynamic> json) {
    return LogbookEntryShort(
      id: json['id'],
      date: DateTime.parse(json['date']),
      depIata: json['depIata'],
      desIata: json['desIata'],
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
      'depIata': depIata,
      'desIata': desIata,
      'acftReg': acftReg,
      'acftType': acftType,
      'blockTime': blockTime,
      'trustLevel': trustLevel.name,
    };
  }
}
