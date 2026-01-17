/// Supported airport code display formats
enum AirportCodeFormat {
  iata, // 3-letter codes (LHR, JFK)
  icao, // 4-letter codes (EGLL, KJFK)
}

/// Helper class for airport code format display
class AirportFormats {
  /// Get the display name for a format (e.g., "IATA" or "ICAO")
  static String getDisplayName(AirportCodeFormat format) {
    switch (format) {
      case AirportCodeFormat.iata:
        return 'IATA';
      case AirportCodeFormat.icao:
        return 'ICAO';
    }
  }

  /// Get the description for a format
  static String getDescription(AirportCodeFormat format) {
    switch (format) {
      case AirportCodeFormat.iata:
        return '3-letter codes (LHR, JFK)';
      case AirportCodeFormat.icao:
        return '4-letter codes (EGLL, KJFK)';
    }
  }

  /// Format an airport code based on user preference
  ///
  /// Returns the preferred code format (ICAO or IATA) if available,
  /// otherwise falls back to the other format or the primary code.
  ///
  /// [icaoCode] - 4-letter ICAO code (e.g., "EGLL")
  /// [iataCode] - 3-letter IATA code (e.g., "LHR")
  /// [fallbackCode] - Primary/fallback code if neither ICAO nor IATA available
  /// [format] - The user's preferred format
  static String formatCode({
    String? icaoCode,
    String? iataCode,
    required String fallbackCode,
    required AirportCodeFormat format,
  }) {
    switch (format) {
      case AirportCodeFormat.icao:
        // Prefer ICAO, fall back to IATA, then fallback code
        return icaoCode ?? iataCode ?? fallbackCode;
      case AirportCodeFormat.iata:
        // Prefer IATA, fall back to ICAO, then fallback code
        return iataCode ?? icaoCode ?? fallbackCode;
    }
  }
}
