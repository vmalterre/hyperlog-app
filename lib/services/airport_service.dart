import '../config/app_config.dart';
import '../models/airport.dart';
import 'api_exception.dart';
import 'api_service.dart';
import 'error_service.dart';

/// Service for airport-related API operations
class AirportService {
  final ApiService _api;
  final ErrorService _errorService;

  /// Constructor with optional dependency injection for testing
  AirportService({ApiService? api, ErrorService? errorService})
      : _api = api ?? ApiService(),
        _errorService = errorService ?? ErrorService();

  /// Search airports by query string (ICAO, IATA, or name)
  /// Returns up to [limit] results (default 10)
  Future<List<Airport>> search(String query, {int limit = 10}) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final response = await _api.get(
        '${AppConfig.airports}/search?q=${Uri.encodeComponent(query)}&limit=$limit',
      );

      final List<dynamic> airportsJson = response['data'] ?? [];
      return airportsJson
          .map((json) => Airport.fromJson(json))
          .toList();
    } on ApiException catch (e) {
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to search airports',
          metadata: {'query': query, 'limit': limit},
        );
      }
      rethrow;
    }
  }

  /// Lookup a single airport by code (ICAO, IATA, or ident)
  Future<Airport?> lookup(String code) async {
    if (code.trim().isEmpty) {
      return null;
    }

    try {
      final response = await _api.get(
        '${AppConfig.airports}/${Uri.encodeComponent(code)}',
      );

      if (response['data'] != null) {
        return Airport.fromJson(response['data']);
      }
      return null;
    } on ApiException catch (e) {
      // 404 means airport not found - return null instead of throwing
      if (e.statusCode == 404) {
        return null;
      }
      if (e.isServerError) {
        _errorService.reporter.reportError(
          e,
          StackTrace.current,
          message: 'Failed to lookup airport',
          metadata: {'code': code},
        );
      }
      rethrow;
    }
  }
}
