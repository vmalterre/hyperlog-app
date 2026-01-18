/// Airport model matching the backend API response
class Airport {
  final int id;
  final String ident;
  final String? icaoCode;  // 4-letter (e.g., EGLL)
  final String? iataCode;  // 3-letter (e.g., LHR)
  final String name;
  final String? municipality;
  final String? isoCountry;

  Airport({
    required this.id,
    required this.ident,
    this.icaoCode,
    this.iataCode,
    required this.name,
    this.municipality,
    this.isoCountry,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      id: json['id'],
      ident: json['ident'] ?? '',
      icaoCode: json['icaoCode'],
      iataCode: json['iataCode'],
      name: json['name'] ?? '',
      municipality: json['municipality'],
      isoCountry: json['isoCountry'],
    );
  }

  /// Display code: ICAO preferred, then IATA, then ident
  String get displayCode => icaoCode ?? iataCode ?? ident;

  /// Display label for dropdown: "Airport Name, City"
  String get displayLabel => '$name${municipality != null ? ', $municipality' : ''}';

  /// Short code for display (e.g., "LHR / EGLL" or just "EGLL")
  String get codeDisplay {
    if (iataCode != null && icaoCode != null) {
      return '$iataCode / $icaoCode';
    }
    return icaoCode ?? iataCode ?? ident;
  }

  @override
  String toString() => 'Airport($displayCode: $name)';
}
