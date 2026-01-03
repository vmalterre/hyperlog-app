import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// API configuration for connecting to the backend
class ApiConfig {
  // WSL2 IP address - update this if WSL2 restarts
  // Run `hostname -I | awk '{print $1}'` in WSL2 to get current IP
  static const String _wsl2Ip = '192.168.137.186';

  /// Get the base URL for the current platform
  static String get baseUrl {
    if (kIsWeb) {
      // Web browser: localhost works directly
      return 'http://localhost:3001/api';
    }

    // Mobile platforms
    try {
      if (Platform.isAndroid) {
        // Android emulator on Windows: use WSL2 IP directly
        // (10.0.2.2 only reaches Windows host, not WSL2)
        return 'http://$_wsl2Ip:3001/api';
      }
    } catch (_) {
      // Platform not available (web), fallback to localhost
    }

    // iOS simulator and other platforms: localhost works
    return 'http://localhost:3001/api';
  }

  // Connection timeout in seconds
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;

  // API endpoints
  static const String pilots = '/pilots';
  static const String flights = '/flights';
}
