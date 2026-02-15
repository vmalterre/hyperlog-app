import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for device-level biometric authentication.
/// This is a local-only gate (not a Firebase MFA factor) used
/// to protect sensitive in-app actions like signing flights,
/// GDPR deletion, and disabling 2FA.
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _enabledKey = 'biometric_enabled';

  /// Check if biometric authentication is available on this device.
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Get the available biometric types on this device.
  Future<List<BiometricType>> getBiometricTypes() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Prompt the user for biometric authentication.
  /// Returns true if authentication succeeded.
  Future<bool> authenticate({String reason = 'Verify your identity'}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/pattern fallback
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Check if biometric is enabled in user preferences.
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  /// Set biometric enabled/disabled in user preferences.
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  /// Gate a sensitive action behind biometric if enabled.
  /// Returns true if the action should proceed (either biometric is
  /// disabled, or authentication succeeded).
  Future<bool> guardAction({String reason = 'Verify your identity'}) async {
    final enabled = await isEnabled();
    if (!enabled) return true;

    final available = await isAvailable();
    if (!available) return true; // Don't block if hardware unavailable

    return await authenticate(reason: reason);
  }
}
