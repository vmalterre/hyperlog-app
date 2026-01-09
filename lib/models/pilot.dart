/// Subscription tier for HyperLog pricing
enum SubscriptionTier {
  standard, // 19/month - off-chain only
  official, // 29/month - blockchain features
}

/// Pilot model matching backend API response
class Pilot {
  final String licenseNumber;
  final String name;
  final String email;
  final String status; // 'active', 'suspended', 'revoked'
  final SubscriptionTier subscriptionTier;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pilot({
    required this.licenseNumber,
    required this.name,
    required this.email,
    required this.status,
    this.subscriptionTier = SubscriptionTier.official,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pilot.fromJson(Map<String, dynamic> json) {
    return Pilot(
      licenseNumber: json['licenseNumber'],
      name: json['name'],
      email: json['email'],
      status: json['status'] ?? 'active',
      subscriptionTier: _parseTier(json['subscriptionTier']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  static SubscriptionTier _parseTier(String? tier) {
    if (tier == 'standard') return SubscriptionTier.standard;
    return SubscriptionTier.official; // Default to official for existing pilots
  }

  Map<String, dynamic> toJson() => {
        'licenseNumber': licenseNumber,
        'name': name,
        'email': email,
        'subscriptionTier': subscriptionTier.name,
      };

  bool get isActive => status == 'active';
  bool get isOfficialTier => subscriptionTier == SubscriptionTier.official;
  bool get isStandardTier => subscriptionTier == SubscriptionTier.standard;
}
