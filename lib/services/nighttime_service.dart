import '../config/app_config.dart';
import 'api_exception.dart';
import 'api_service.dart';

/// Result of a nighttime calculation
class NighttimeResult {
  final int nightMinutes;
  final int totalMinutes;
  final int nightPercentage;

  NighttimeResult({
    required this.nightMinutes,
    required this.totalMinutes,
    required this.nightPercentage,
  });

  factory NighttimeResult.fromJson(Map<String, dynamic> json) {
    return NighttimeResult(
      nightMinutes: json['nightMinutes'] ?? 0,
      totalMinutes: json['totalMinutes'] ?? 0,
      nightPercentage: json['nightPercentage'] ?? 0,
    );
  }
}

/// Service for calculating night flying time
class NighttimeService {
  final ApiService _api;

  /// Constructor with optional dependency injection for testing
  NighttimeService({ApiService? api}) : _api = api ?? ApiService();

  /// Calculate night flying time for a flight
  ///
  /// Returns null on error (graceful degradation - user can still manually enter)
  Future<NighttimeResult?> calculate({
    required String depCode,
    required String destCode,
    required DateTime blockOffUtc,
    required DateTime blockOnUtc,
  }) async {
    try {
      final response = await _api.post(
        '${AppConfig.nighttime}/calculate',
        {
          'depCode': depCode,
          'destCode': destCode,
          'blockOffUtc': blockOffUtc.toUtc().toIso8601String(),
          'blockOnUtc': blockOnUtc.toUtc().toIso8601String(),
        },
      );

      if (response['data'] != null) {
        return NighttimeResult.fromJson(response['data']);
      }
      return null;
    } on ApiException {
      // Return null on error - user can still manually enter night time
      return null;
    } catch (_) {
      // Return null on any error
      return null;
    }
  }
}
