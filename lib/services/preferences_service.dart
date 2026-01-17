import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/airport_format.dart';
import '../constants/role_standards.dart';

/// Service for managing user preferences using shared_preferences
class PreferencesService {
  static const String _keyRoleStandard = 'role_standard';
  static const String _keyDefaultRole = 'default_role';
  static const String _keyDefaultSecondaryRole = 'default_secondary_role';
  static const String _keyCustomTimeFields = 'custom_time_fields';
  static const String _keyAirportCodeFormat = 'airport_code_format';

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
    // Keep the same default role code when standard changes (labels change, code stays)
  }

  /// Get the user's default primary role
  String getDefaultRole() {
    final role = _prefs?.getString(_keyDefaultRole);
    if (role == null || role.isEmpty) {
      return RoleStandards.getDefaultRole(getRoleStandard());
    }
    return role;
  }

  /// Set the user's default primary role
  Future<void> setDefaultRole(String role) async {
    await _prefs?.setString(_keyDefaultRole, role);
  }

  /// Get the user's default secondary role (null if none)
  String? getDefaultSecondaryRole() {
    return _prefs?.getString(_keyDefaultSecondaryRole);
  }

  /// Set the user's default secondary role (null to clear)
  Future<void> setDefaultSecondaryRole(String? role) async {
    if (role == null || role.isEmpty) {
      await _prefs?.remove(_keyDefaultSecondaryRole);
    } else {
      await _prefs?.setString(_keyDefaultSecondaryRole, role);
    }
  }

  /// Get custom time fields (user-defined field names)
  List<String> getCustomTimeFields() {
    final json = _prefs?.getString(_keyCustomTimeFields);
    if (json == null || json.isEmpty) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.cast<String>();
    } catch (_) {
      return [];
    }
  }

  /// Set custom time fields
  Future<void> setCustomTimeFields(List<String> fields) async {
    await _prefs?.setString(_keyCustomTimeFields, jsonEncode(fields));
  }

  /// Add a custom time field
  Future<void> addCustomTimeField(String fieldName) async {
    final fields = getCustomTimeFields();
    if (!fields.contains(fieldName)) {
      fields.add(fieldName);
      await setCustomTimeFields(fields);
    }
  }

  /// Remove a custom time field
  Future<void> removeCustomTimeField(String fieldName) async {
    final fields = getCustomTimeFields();
    fields.remove(fieldName);
    await setCustomTimeFields(fields);
  }

  /// Rename a custom time field
  Future<void> renameCustomTimeField(String oldName, String newName) async {
    final fields = getCustomTimeFields();
    final index = fields.indexOf(oldName);
    if (index != -1) {
      fields[index] = newName;
      await setCustomTimeFields(fields);
    }
  }

  /// Get the user's preferred airport code format
  AirportCodeFormat getAirportCodeFormat() {
    final value = _prefs?.getString(_keyAirportCodeFormat);
    if (value == null) return AirportCodeFormat.iata;
    return AirportCodeFormat.values.firstWhere(
      (f) => f.name == value,
      orElse: () => AirportCodeFormat.iata,
    );
  }

  /// Set the user's preferred airport code format
  Future<void> setAirportCodeFormat(AirportCodeFormat format) async {
    await _prefs?.setString(_keyAirportCodeFormat, format.name);
  }
}
