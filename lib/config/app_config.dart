import 'package:flutter/foundation.dart' show kIsWeb;
import 'environment.dart';

/// Central app configuration - initialized once at startup
class AppConfig {
  static late final EnvironmentConfig _config;
  static bool _initialized = false;

  /// Initialize with environment from --dart-define
  /// Call this once in main() before runApp()
  static void initialize({required String environment}) {
    if (_initialized) return;

    _config = switch (environment.toLowerCase()) {
      'prod' || 'production' => EnvironmentConfig.prod,
      _ => EnvironmentConfig.dev, // Default to dev for safety
    };
    _initialized = true;
  }

  /// Get the current environment config
  static EnvironmentConfig get current {
    assert(_initialized, 'AppConfig.initialize() must be called first');
    return _config;
  }

  /// Get the API base URL for the current platform
  static String get apiBaseUrl {
    final baseUrl = current.apiBaseUrl;

    if (kIsWeb) {
      // Web browser: localhost for dev, prod URL for prod
      return current.isDev ? 'http://localhost:3001/api' : baseUrl;
    }

    // Mobile platforms use the configured URL
    // (Android emulator needs WSL2 IP for dev, prod uses VPS directly)
    return baseUrl;
  }

  // Connection timeout in seconds
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;

  // API endpoints
  static const String pilots = '/pilots';
  static const String flights = '/flights';
}
