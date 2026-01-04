import 'dart:math';
import 'package:latlong2/latlong.dart';

/// Calculates points along a great circle arc between two coordinates.
/// Used for drawing curved flight routes on a map.
class GreatCircleArc {
  /// Generate intermediate points along a great circle arc.
  ///
  /// [start] - Starting coordinate
  /// [end] - Ending coordinate
  /// [numPoints] - Number of points to generate (default: 50)
  ///
  /// Returns a list of [LatLng] points forming a smooth arc.
  static List<LatLng> calculateArcPoints(
    LatLng start,
    LatLng end, {
    int numPoints = 50,
  }) {
    final points = <LatLng>[];

    // Convert to radians
    final lat1 = _toRadians(start.latitude);
    final lon1 = _toRadians(start.longitude);
    final lat2 = _toRadians(end.latitude);
    final lon2 = _toRadians(end.longitude);

    // Calculate angular distance using haversine formula
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // If points are very close, just return start and end
    if (c < 0.0001) {
      return [start, end];
    }

    // Generate intermediate points using spherical linear interpolation
    for (int i = 0; i <= numPoints; i++) {
      final fraction = i / numPoints;

      final A = sin((1 - fraction) * c) / sin(c);
      final B = sin(fraction * c) / sin(c);

      final x = A * cos(lat1) * cos(lon1) + B * cos(lat2) * cos(lon2);
      final y = A * cos(lat1) * sin(lon1) + B * cos(lat2) * sin(lon2);
      final z = A * sin(lat1) + B * sin(lat2);

      final lat = atan2(z, sqrt(x * x + y * y));
      final lon = atan2(y, x);

      points.add(LatLng(_toDegrees(lat), _toDegrees(lon)));
    }

    return points;
  }

  /// Calculate the great circle distance between two points in kilometers.
  static double distanceKm(LatLng start, LatLng end) {
    const earthRadiusKm = 6371.0;

    final lat1 = _toRadians(start.latitude);
    final lon1 = _toRadians(start.longitude);
    final lat2 = _toRadians(end.latitude);
    final lon2 = _toRadians(end.longitude);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
  static double _toDegrees(double radians) => radians * 180 / pi;
}
