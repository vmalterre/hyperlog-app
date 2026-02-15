import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/flight_fields.dart';
import '../models/screen_config.dart';

/// Service for managing custom screen configurations.
/// Persists screen configs to SharedPreferences.
class ScreenConfigService extends ChangeNotifier {
  static const String _keyScreenConfigs = 'screen_configs';
  static const String _keyDefaultScreenId = 'default_screen_id';

  static ScreenConfigService? _instance;
  SharedPreferences? _prefs;
  List<ScreenConfig> _configs = [];
  String? _defaultScreenId;
  final _random = Random();

  ScreenConfigService._();

  /// Generate a unique ID for a screen config
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = _random.nextInt(0xFFFF).toRadixString(16).padLeft(4, '0');
    return 'screen_${timestamp}_$randomPart';
  }

  /// Get singleton instance
  static ScreenConfigService get instance {
    _instance ??= ScreenConfigService._();
    return _instance!;
  }

  /// Initialize service (call once at app startup)
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _loadConfigs();
    _ensureBuiltInScreens();
  }

  /// Load configs from SharedPreferences
  void _loadConfigs() {
    final json = _prefs?.getString(_keyScreenConfigs);
    if (json != null && json.isNotEmpty) {
      try {
        final list = jsonDecode(json) as List<dynamic>;
        _configs = list
            .map((item) => ScreenConfig.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Error loading screen configs: $e');
        _configs = [];
      }
    }
    _defaultScreenId = _prefs?.getString(_keyDefaultScreenId);
  }

  /// Ensure built-in screens exist (called after loading configs)
  void _ensureBuiltInScreens() {
    bool changed = false;

    // Full Form: all fields visible, aircraft mode
    if (!_configs.any((c) => c.id == ScreenConfig.fullFormId)) {
      _configs.insert(0, ScreenConfig.allVisible(
        id: ScreenConfig.fullFormId,
        name: 'Full Form',
        isBuiltIn: true,
      ));
      changed = true;
    }

    // Simulator: sim mode, some fields pre-hidden
    if (!_configs.any((c) => c.id == ScreenConfig.simulatorId)) {
      final insertIndex = _configs.indexWhere((c) => c.id == ScreenConfig.fullFormId) + 1;
      _configs.insert(insertIndex, ScreenConfig(
        id: ScreenConfig.simulatorId,
        name: 'Simulator',
        isSimulatorMode: true,
        isBuiltIn: true,
        hiddenFields: {
          FlightField.flightNumber,
          FlightField.flightTime,
          FlightField.ifrActual,
          FlightField.ifrSimulated,
          FlightField.soloTime,
          FlightField.nightTime,
          FlightField.crossCountryTime,
          FlightField.multiEngineTime,
          FlightField.multiPilotTime,
          FlightField.pfPmToggle,
          FlightField.takeoffsLandings,
        },
      ));
      changed = true;
    }

    // Default to Full Form if no default is set
    if (_defaultScreenId == null) {
      _defaultScreenId = ScreenConfig.fullFormId;
      _saveDefaultScreenId();
      changed = true;
    }

    if (changed) {
      _saveConfigs();
    }
  }

  /// Save configs to SharedPreferences
  Future<void> _saveConfigs() async {
    final json = jsonEncode(_configs.map((c) => c.toJson()).toList());
    await _prefs?.setString(_keyScreenConfigs, json);
  }

  /// Save default screen ID to SharedPreferences
  Future<void> _saveDefaultScreenId() async {
    if (_defaultScreenId != null) {
      await _prefs?.setString(_keyDefaultScreenId, _defaultScreenId!);
    } else {
      await _prefs?.remove(_keyDefaultScreenId);
    }
  }

  /// Get all screen configs (built-ins first, then user screens)
  List<ScreenConfig> getAll() {
    final builtIns = _configs.where((c) => c.isBuiltIn).toList();
    final custom = _configs.where((c) => !c.isBuiltIn).toList();
    return List.unmodifiable([...builtIns, ...custom]);
  }

  /// Get a specific config by ID
  ScreenConfig? getById(String id) {
    return _configs.cast<ScreenConfig?>().firstWhere(
          (c) => c?.id == id,
          orElse: () => null,
        );
  }

  /// Get the default screen config
  ScreenConfig? getDefault() {
    if (_defaultScreenId == null) {
      // Fallback to built-in full form
      return getById(ScreenConfig.fullFormId);
    }
    return getById(_defaultScreenId!);
  }

  /// Get the default screen ID
  String? get defaultScreenId => _defaultScreenId;

  /// Create a new screen config with all fields visible
  Future<ScreenConfig> create(String name) async {
    final config = ScreenConfig.allVisible(
      id: _generateId(),
      name: name.trim(),
    );
    _configs.add(config);

    await _saveConfigs();
    notifyListeners();
    return config;
  }

  /// Update an existing screen config
  Future<void> update(ScreenConfig config) async {
    final index = _configs.indexWhere((c) => c.id == config.id);
    if (index != -1) {
      _configs[index] = config.copyWith(updatedAt: DateTime.now());
      await _saveConfigs();
      notifyListeners();
    }
  }

  /// Delete a screen config by ID (no-op for built-in screens)
  Future<void> delete(String id) async {
    final config = getById(id);
    if (config != null && config.isBuiltIn) return;

    _configs.removeWhere((c) => c.id == id);

    // Clear default if deleted screen was default
    if (_defaultScreenId == id) {
      _defaultScreenId = ScreenConfig.fullFormId;
      await _saveDefaultScreenId();
    }

    await _saveConfigs();
    notifyListeners();
  }

  /// Delete all screen configs (factory reset — built-ins recreated fresh)
  Future<void> deleteAll() async {
    _configs.clear();
    _defaultScreenId = null;
    _ensureBuiltInScreens();
    await _saveConfigs();
    await _saveDefaultScreenId();
    notifyListeners();
  }

  /// Set the default screen by ID
  Future<void> setDefault(String? id) async {
    if (id != null && !_configs.any((c) => c.id == id)) {
      return; // Invalid ID
    }
    _defaultScreenId = id ?? ScreenConfig.fullFormId;
    await _saveDefaultScreenId();
    notifyListeners();
  }

  /// Check if a field is visible for the current default screen
  bool isFieldVisible(FlightField field) {
    final defaultConfig = getDefault();
    if (defaultConfig == null) return true; // Full form shows all fields
    return defaultConfig.isFieldVisible(field);
  }

  /// Check if a field is hidden for the current default screen
  bool isFieldHidden(FlightField field) {
    return !isFieldVisible(field);
  }

  /// Get the count of visible fields for a config
  int getVisibleFieldCount(ScreenConfig config) {
    return FlightField.values.length - config.hiddenFields.length;
  }

  /// Get a summary description for a config (e.g., "12 of 14 fields" or "SIM • 5 of 6 fields")
  String getConfigSummary(ScreenConfig config) {
    final prefix = config.isSimulatorMode ? 'SIM \u2022 ' : '';

    // For Simulator built-in, count only toggleable (non-locked) fields
    if (config.id == ScreenConfig.simulatorId) {
      final locked = ScreenConfig.simulatorLockedFields;
      final total = FlightField.values.where((f) => !locked.contains(f)).length;
      final visible = FlightField.values.where((f) => !locked.contains(f) && !config.hiddenFields.contains(f)).length;
      return '$prefix$visible of $total fields';
    }

    final visible = getVisibleFieldCount(config);
    final total = FlightField.values.length;
    return '$prefix$visible of $total fields';
  }
}
