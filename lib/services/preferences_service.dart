import 'package:shared_preferences/shared_preferences.dart';
import '../constants/role_standards.dart';

/// Service for managing user preferences using shared_preferences
class PreferencesService {
  static const String _keyRoleStandard = 'role_standard';
  static const String _keyDefaultRole = 'default_role';

  static PreferencesService? _instance;
  SharedPreferences? _prefs;

  PreferencesService._();

  /// Get singleton instance
  static PreferencesService get instance {
    _instance ??= PreferencesService._();
    return _instance!;
  }

  /// Initialize preferences (call once at app startup)
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get the user's preferred role standard
  RoleStandard getRoleStandard() {
    final value = _prefs?.getString(_keyRoleStandard);
    if (value == null) return RoleStandard.easa;
    return RoleStandard.values.firstWhere(
      (s) => s.name == value,
      orElse: () => RoleStandard.easa,
    );
  }

  /// Set the user's preferred role standard
  Future<void> setRoleStandard(RoleStandard standard) async {
    await _prefs?.setString(_keyRoleStandard, standard.name);
    // Reset default role when standard changes
    await setDefaultRole(RoleStandards.getDefaultRole(standard));
  }

  /// Get the user's default role
  String getDefaultRole() {
    final role = _prefs?.getString(_keyDefaultRole);
    if (role == null || role.isEmpty) {
      return RoleStandards.getDefaultRole(getRoleStandard());
    }
    return role;
  }

  /// Set the user's default role
  Future<void> setDefaultRole(String role) async {
    await _prefs?.setString(_keyDefaultRole, role);
  }
}
