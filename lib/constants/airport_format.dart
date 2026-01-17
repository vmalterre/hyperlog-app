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
}
