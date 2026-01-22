import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity status.
///
/// Provides:
/// - Current connectivity status
/// - Stream of connectivity changes
/// - Convenience methods for checking online state
class ConnectivityService {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Stream controller for connectivity changes
  final _connectivityController = StreamController<bool>.broadcast();

  /// Current connectivity status
  bool _isOnline = true;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Whether the device currently has network connectivity
  bool get isOnline => _isOnline;

  /// Whether the device is currently offline
  bool get isOffline => !_isOnline;

  /// Stream of connectivity changes (true = online, false = offline)
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  /// Alias for onConnectivityChanged for simpler UI access
  Stream<bool> get onlineStream => _connectivityController.stream;

  /// Initialize the service and start listening for changes
  Future<void> initialize() async {
    // Get initial status
    final result = await _connectivity.checkConnectivity();
    _isOnline = _hasConnectivity(result);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = _hasConnectivity(result);

      // Only emit if status actually changed
      if (wasOnline != _isOnline) {
        _connectivityController.add(_isOnline);
      }
    });
  }

  /// Check current connectivity (does not rely on cached value)
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = _hasConnectivity(result);
    return _isOnline;
  }

  /// Wait until online (returns immediately if already online)
  /// Useful for operations that require connectivity
  Future<void> waitUntilOnline({Duration? timeout}) async {
    if (_isOnline) return;

    final completer = Completer<void>();
    StreamSubscription<bool>? subscription;

    subscription = onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    if (timeout != null) {
      Future.delayed(timeout, () {
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.completeError(
            TimeoutException('Timed out waiting for connectivity'),
          );
        }
      });
    }

    return completer.future;
  }

  /// Dispose of resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }

  /// Check if the result list indicates connectivity
  bool _hasConnectivity(List<ConnectivityResult> results) {
    // No results or only none means offline
    if (results.isEmpty) return false;
    if (results.length == 1 && results.first == ConnectivityResult.none) {
      return false;
    }
    // Any other result means some form of connectivity
    return true;
  }
}

/// Singleton instance for easy access
ConnectivityService? _instance;

ConnectivityService get connectivityService {
  _instance ??= ConnectivityService();
  return _instance!;
}

/// Initialize the connectivity service (call once at app startup)
Future<void> initConnectivityService() async {
  await connectivityService.initialize();
}
