import 'package:latlong2/latlong.dart';
import 'package:hyperlog/models/logbook_entry.dart';
import 'package:hyperlog/data/airport_coordinates.dart';

/// Represents a unique route between two airports with aggregated flight data.
class FlightRoute {
  final String departureCode;
  final String destinationCode;
  final LatLng? departureCoords;
  final LatLng? destinationCoords;
  final int flightCount;

  const FlightRoute({
    required this.departureCode,
    required this.destinationCode,
    this.departureCoords,
    this.destinationCoords,
    required this.flightCount,
  });

  /// Whether this route has valid coordinates for both endpoints.
  bool get hasValidCoordinates =>
      departureCoords != null && destinationCoords != null;

  /// Unique key for this route (direction-independent).
  String get routeKey {
    final codes = [departureCode, destinationCode]..sort();
    return '${codes[0]}-${codes[1]}';
  }

  /// Extract unique routes from a list of flights.
  /// Routes are deduplicated (A->B and B->A count as the same route).
  static List<FlightRoute> fromFlights(List<LogbookEntry> flights) {
    // Group flights by route (direction-independent)
    final routeMap = <String, _RouteData>{};

    for (final flight in flights) {
      final codes = [flight.dep, flight.dest]..sort();
      final key = '${codes[0]}-${codes[1]}';

      if (routeMap.containsKey(key)) {
        routeMap[key]!.count++;
      } else {
        routeMap[key] = _RouteData(
          dep: codes[0],
          dest: codes[1],
          count: 1,
        );
      }
    }

    // Convert to FlightRoute objects with coordinates
    return routeMap.values.map((data) {
      return FlightRoute(
        departureCode: data.dep,
        destinationCode: data.dest,
        departureCoords: AirportCoordinates.getCoordinates(data.dep),
        destinationCoords: AirportCoordinates.getCoordinates(data.dest),
        flightCount: data.count,
      );
    }).toList();
  }

  /// Get all unique airports from a list of flights.
  static Set<String> uniqueAirports(List<LogbookEntry> flights) {
    final airports = <String>{};
    for (final flight in flights) {
      airports.add(flight.dep);
      airports.add(flight.dest);
    }
    return airports;
  }

  /// Get airports with their coordinates and visit counts.
  static List<AirportMarkerData> airportMarkers(List<LogbookEntry> flights) {
    final visitCounts = <String, int>{};

    for (final flight in flights) {
      visitCounts[flight.dep] = (visitCounts[flight.dep] ?? 0) + 1;
      visitCounts[flight.dest] = (visitCounts[flight.dest] ?? 0) + 1;
    }

    return visitCounts.entries.map((entry) {
      return AirportMarkerData(
        icaoCode: entry.key,
        coords: AirportCoordinates.getCoordinates(entry.key),
        visitCount: entry.value,
      );
    }).where((m) => m.coords != null).toList();
  }
}

/// Helper class for route aggregation.
class _RouteData {
  final String dep;
  final String dest;
  int count;

  _RouteData({
    required this.dep,
    required this.dest,
    required this.count,
  });
}

/// Data for an airport marker on the map.
class AirportMarkerData {
  final String icaoCode;
  final LatLng? coords;
  final int visitCount;

  const AirportMarkerData({
    required this.icaoCode,
    this.coords,
    required this.visitCount,
  });
}
