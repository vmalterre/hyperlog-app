import 'package:latlong2/latlong.dart';

/// Airport coordinate database for flight map visualization.
/// Maps ICAO codes to geographic coordinates.
class AirportCoordinates {
  static const Map<String, List<double>> _airports = {
    // United Kingdom
    'EGLL': [51.4700, -0.4543], // London Heathrow
    'EGKK': [51.1481, -0.1903], // London Gatwick
    'EGSS': [51.8850, 0.2350], // London Stansted
    'EGLC': [51.5053, 0.0553], // London City
    'EGCC': [53.3537, -2.2750], // Manchester
    'EGBB': [52.4539, -1.7480], // Birmingham
    'EGPH': [55.9500, -3.3725], // Edinburgh
    'EGPF': [55.8719, -4.4331], // Glasgow

    // France
    'LFPG': [49.0097, 2.5479], // Paris Charles de Gaulle
    'LFPO': [48.7233, 2.3794], // Paris Orly
    'LFML': [43.4393, 5.2214], // Marseille
    'LFLL': [45.7256, 5.0811], // Lyon
    'LFBO': [43.6291, 1.3678], // Toulouse
    'LFMN': [43.6584, 7.2159], // Nice

    // Germany
    'EDDF': [50.0379, 8.5622], // Frankfurt
    'EDDM': [48.3538, 11.7861], // Munich
    'EDDB': [52.3667, 13.5033], // Berlin Brandenburg
    'EDDH': [53.6304, 9.9882], // Hamburg
    'EDDK': [50.8659, 7.1427], // Cologne
    'EDDL': [51.2895, 6.7668], // Dusseldorf

    // Netherlands
    'EHAM': [52.3086, 4.7639], // Amsterdam Schiphol

    // Belgium
    'EBBR': [50.9014, 4.4844], // Brussels

    // Spain
    'LEMD': [40.4936, -3.5668], // Madrid
    'LEBL': [41.2971, 2.0785], // Barcelona
    'LEMG': [36.6749, -4.4991], // Malaga
    'LEPA': [39.5517, 2.7388], // Palma de Mallorca
    'LEAL': [38.2822, -0.5582], // Alicante
    'LEVC': [39.4893, -0.4816], // Valencia

    // Italy
    'LIRF': [41.8003, 12.2389], // Rome Fiumicino
    'LIMC': [45.6306, 8.7231], // Milan Malpensa
    'LIME': [45.6739, 9.7042], // Milan Bergamo
    'LIPZ': [45.5053, 12.3519], // Venice
    'LIRN': [40.8861, 14.2908], // Naples
    'LICC': [37.4668, 15.0664], // Catania

    // Portugal
    'LPPT': [38.7813, -9.1359], // Lisbon
    'LPPR': [41.2481, -8.6814], // Porto
    'LPFR': [37.0144, -7.9659], // Faro

    // Ireland
    'EIDW': [53.4213, -6.2701], // Dublin
    'EICK': [51.8413, -8.4911], // Cork

    // Switzerland
    'LSZH': [47.4647, 8.5492], // Zurich
    'LSGG': [46.2381, 6.1089], // Geneva

    // Austria
    'LOWW': [48.1103, 16.5697], // Vienna
    'LOWS': [47.7933, 13.0043], // Salzburg

    // Scandinavia
    'EKCH': [55.6180, 12.6508], // Copenhagen
    'ENGM': [60.1939, 11.1004], // Oslo
    'ESSA': [59.6519, 17.9186], // Stockholm Arlanda
    'EFHK': [60.3172, 24.9633], // Helsinki

    // Greece
    'LGAV': [37.9364, 23.9445], // Athens
    'LGSR': [36.3992, 25.4793], // Santorini
    'LGKR': [39.6019, 19.9117], // Corfu

    // Czech Republic
    'LKPR': [50.1008, 14.2600], // Prague

    // Poland
    'EPWA': [52.1657, 20.9671], // Warsaw
    'EPKK': [50.0777, 19.7848], // Krakow

    // Hungary
    'LHBP': [47.4369, 19.2556], // Budapest

    // Turkey
    'LTFM': [41.2753, 28.7519], // Istanbul
    'LTAI': [36.8987, 30.8005], // Antalya

    // Iceland
    'BIKF': [63.9850, -22.6056], // Keflavik

    // Croatia
    'LDDU': [42.5614, 18.2681], // Dubrovnik
    'LDZA': [45.7429, 16.0688], // Zagreb

    // Morocco
    'GMMN': [33.3675, -7.5897], // Casablanca
    'GMME': [34.0517, -6.7514], // Rabat

    // UAE
    'OMDB': [25.2528, 55.3644], // Dubai
    'OMAA': [24.4330, 54.6511], // Abu Dhabi

    // USA (Major hubs for transatlantic)
    'KJFK': [40.6413, -73.7781], // New York JFK
    'KEWR': [40.6895, -74.1745], // Newark
    'KLAX': [33.9416, -118.4085], // Los Angeles
    'KORD': [41.9742, -87.9073], // Chicago O'Hare
    'KATL': [33.6407, -84.4277], // Atlanta
    'KMIA': [25.7959, -80.2870], // Miami
    'KSFO': [37.6213, -122.3790], // San Francisco
    'KBOS': [42.3656, -71.0096], // Boston

    // Canada
    'CYYZ': [43.6777, -79.6248], // Toronto
    'CYVR': [49.1947, -123.1792], // Vancouver
    'CYUL': [45.4706, -73.7408], // Montreal
  };

  /// Get coordinates for an airport by ICAO code.
  /// Returns null if the airport is not in the database.
  static LatLng? getCoordinates(String icaoCode) {
    final coords = _airports[icaoCode.toUpperCase()];
    if (coords == null) return null;
    return LatLng(coords[0], coords[1]);
  }

  /// Check if coordinates are available for an airport.
  static bool hasCoordinates(String icaoCode) {
    return _airports.containsKey(icaoCode.toUpperCase());
  }

  /// Get all known airport codes.
  static Set<String> get knownAirports => _airports.keys.toSet();
}
