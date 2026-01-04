import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hyperlog/models/logbook_entry.dart';
import 'package:hyperlog/models/flight_route.dart';
import 'package:hyperlog/utils/great_circle_arc.dart';
import 'package:hyperlog/theme/app_colors.dart';
import 'package:hyperlog/theme/app_typography.dart';

/// Time filter options for the map view.
enum MapTimeFilter {
  last30Days,
  thisYear,
  lastYear,
  allTime,
}

extension MapTimeFilterExtension on MapTimeFilter {
  String get displayName {
    switch (this) {
      case MapTimeFilter.last30Days:
        return '30 Days';
      case MapTimeFilter.thisYear:
        return 'This Year';
      case MapTimeFilter.lastYear:
        return 'Last Year';
      case MapTimeFilter.allTime:
        return 'All Time';
    }
  }
}

/// Map widget displaying flight routes as curved arcs.
class FlightMapView extends StatefulWidget {
  final List<LogbookEntry> flights;
  final MapTimeFilter filter;

  const FlightMapView({
    super.key,
    required this.flights,
    required this.filter,
  });

  @override
  State<FlightMapView> createState() => _FlightMapViewState();
}

class _FlightMapViewState extends State<FlightMapView> {
  final MapController _mapController = MapController();

  List<LogbookEntry> get _filteredFlights {
    final now = DateTime.now();
    switch (widget.filter) {
      case MapTimeFilter.last30Days:
        final cutoff = now.subtract(const Duration(days: 30));
        return widget.flights
            .where((f) => f.flightDate.isAfter(cutoff))
            .toList();
      case MapTimeFilter.thisYear:
        return widget.flights
            .where((f) => f.flightDate.year == now.year)
            .toList();
      case MapTimeFilter.lastYear:
        return widget.flights
            .where((f) => f.flightDate.year == now.year - 1)
            .toList();
      case MapTimeFilter.allTime:
        return widget.flights;
    }
  }

  @override
  Widget build(BuildContext context) {
    final flights = _filteredFlights;

    if (flights.isEmpty) {
      return _buildEmptyState();
    }

    final routes = FlightRoute.fromFlights(flights)
        .where((r) => r.hasValidCoordinates)
        .toList();
    final markers = FlightRoute.airportMarkers(flights);

    // Calculate bounds to fit all airports
    final bounds = _calculateBounds(markers);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: bounds?.center ?? const LatLng(48.0, 10.0),
          initialZoom: 4.0,
          backgroundColor: AppColors.nightRiderDark,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
          onMapReady: () {
            if (bounds != null) {
              _mapController.fitCamera(
                CameraFit.bounds(
                  bounds: bounds,
                  padding: const EdgeInsets.all(50),
                ),
              );
            }
          },
        ),
        children: [
          // Dark tile layer
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.hyperlog.app',
            retinaMode: true,
          ),

          // Route arcs
          PolylineLayer(
            polylines: routes.map((route) {
              final arcPoints = GreatCircleArc.calculateArcPoints(
                route.departureCoords!,
                route.destinationCoords!,
                numPoints: 50,
              );
              return Polyline(
                points: arcPoints,
                color: AppColors.denim.withValues(alpha: 0.7),
                strokeWidth: 2.0,
              );
            }).toList(),
          ),

          // Airport markers
          MarkerLayer(
            markers: markers.map((airport) {
              return Marker(
                point: airport.coords!,
                width: 60,
                height: 28,
                child: _AirportMarker(
                  code: airport.icaoCode,
                  visitCount: airport.visitCount,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  LatLngBounds? _calculateBounds(List<AirportMarkerData> markers) {
    final validMarkers = markers.where((m) => m.coords != null).toList();
    if (validMarkers.isEmpty) return null;

    double minLat = validMarkers.first.coords!.latitude;
    double maxLat = validMarkers.first.coords!.latitude;
    double minLng = validMarkers.first.coords!.longitude;
    double maxLng = validMarkers.first.coords!.longitude;

    for (final marker in validMarkers) {
      final lat = marker.coords!.latitude;
      final lng = marker.coords!.longitude;
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    // Add some padding
    const padding = 2.0;
    return LatLngBounds(
      LatLng(minLat - padding, minLng - padding),
      LatLng(maxLat + padding, maxLng + padding),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.nightRiderDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderVisible),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: AppColors.whiteDarker,
            ),
            const SizedBox(height: 16),
            Text(
              'No flights to display',
              style: AppTypography.h4,
            ),
            const SizedBox(height: 8),
            Text(
              'Log some flights to see your routes on the map',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom airport marker widget with glass-morphism styling.
class _AirportMarker extends StatelessWidget {
  final String code;
  final int visitCount;

  const _AirportMarker({
    required this.code,
    required this.visitCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.nightRiderDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.denim.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        code,
        style: AppTypography.dataSmall.copyWith(
          fontSize: 11,
          color: AppColors.white,
        ),
      ),
    );
  }
}
