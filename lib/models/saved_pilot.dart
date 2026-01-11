/// Saved pilot for crew autocomplete and management
class SavedPilot {
  final String? id;
  final String name;
  final int flightCount;
  final bool isManuallyAdded;

  SavedPilot({
    this.id,
    required this.name,
    required this.flightCount,
    required this.isManuallyAdded,
  });

  factory SavedPilot.fromJson(Map<String, dynamic> json) {
    return SavedPilot(
      id: json['id'] as String?,
      name: json['name'] as String,
      flightCount: json['flightCount'] as int? ?? 0,
      isManuallyAdded: json['isManuallyAdded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'flightCount': flightCount,
        'isManuallyAdded': isManuallyAdded,
      };

  @override
  String toString() => 'SavedPilot(name: $name, flightCount: $flightCount)';
}
