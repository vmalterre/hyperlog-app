import '../constants/flight_fields.dart';

/// A custom screen configuration that defines which flight fields are visible.
/// Stores hidden fields (smaller set) rather than visible fields.
class ScreenConfig {
  final String id;
  final String name;
  final Set<FlightField> hiddenFields;
  final bool isSimulatorMode;
  final DateTime createdAt;
  final DateTime updatedAt;

  ScreenConfig({
    required this.id,
    required this.name,
    Set<FlightField>? hiddenFields,
    this.isSimulatorMode = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : hiddenFields = hiddenFields ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a new screen config with all fields visible
  factory ScreenConfig.allVisible({
    required String id,
    required String name,
    bool isSimulatorMode = false,
  }) {
    final now = DateTime.now();
    return ScreenConfig(
      id: id,
      name: name,
      hiddenFields: {},
      isSimulatorMode: isSimulatorMode,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Check if a specific field is visible
  bool isFieldVisible(FlightField field) => !hiddenFields.contains(field);

  /// Check if a specific field is hidden
  bool isFieldHidden(FlightField field) => hiddenFields.contains(field);

  /// Create a copy with updated fields
  ScreenConfig copyWith({
    String? id,
    String? name,
    Set<FlightField>? hiddenFields,
    bool? isSimulatorMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScreenConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      hiddenFields: hiddenFields ?? this.hiddenFields,
      isSimulatorMode: isSimulatorMode ?? this.isSimulatorMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hiddenFields': hiddenFields.map((f) => f.name).toList(),
      'isSimulatorMode': isSimulatorMode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ScreenConfig.fromJson(Map<String, dynamic> json) {
    final hiddenFieldNames = (json['hiddenFields'] as List<dynamic>?) ?? [];
    final hiddenFields = hiddenFieldNames
        .map((name) {
          try {
            return FlightField.values.firstWhere((f) => f.name == name);
          } catch (_) {
            return null;
          }
        })
        .whereType<FlightField>()
        .toSet();

    return ScreenConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      hiddenFields: hiddenFields,
      isSimulatorMode: json['isSimulatorMode'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScreenConfig &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ScreenConfig(id: $id, name: $name, hidden: ${hiddenFields.length} fields, sim: $isSimulatorMode)';
}
