/// Pilot model matching backend API response
class Pilot {
  final String licenseNumber;
  final String name;
  final String email;
  final String status; // 'active', 'suspended', 'revoked'
  final DateTime createdAt;
  final DateTime updatedAt;

  Pilot({
    required this.licenseNumber,
    required this.name,
    required this.email,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pilot.fromJson(Map<String, dynamic> json) {
    return Pilot(
      licenseNumber: json['licenseNumber'],
      name: json['name'],
      email: json['email'],
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'licenseNumber': licenseNumber,
        'name': name,
        'email': email,
      };

  bool get isActive => status == 'active';
}
