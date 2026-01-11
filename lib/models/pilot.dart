/// Subscription tier for HyperLog pricing
enum SubscriptionTier {
  standard, // 19/month - off-chain only
  official, // 29/month - blockchain features
}

/// Pilot model matching backend API response
class Pilot {
  final String id; // PostgreSQL UUID - primary identifier for all operations
  final String licenseNumber;
  final String name; // Deprecated: use firstName + lastName
  final String? firstName;
  final String? lastName;
  final String email;
  final String? photoUrl;
  final String status; // 'active', 'suspended', 'revoked'
  final SubscriptionTier subscriptionTier;
  final DateTime? identityVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pilot({
    required this.id,
    required this.licenseNumber,
    required this.name,
    this.firstName,
    this.lastName,
    required this.email,
    this.photoUrl,
    required this.status,
    this.subscriptionTier = SubscriptionTier.official,
    this.identityVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pilot.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] as String?;
    final lastName = json['lastName'] as String?;
    return Pilot(
      id: json['id'] ?? '', // UUID - primary identifier
      licenseNumber: json['licenseNumber'],
      name: json['name'] ?? [firstName, lastName].whereType<String>().join(' '),
      firstName: firstName,
      lastName: json['lastName'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      status: json['status'] ?? 'active',
      subscriptionTier: _parseTier(json['subscriptionTier']),
      identityVerifiedAt: json['identityVerifiedAt'] != null
          ? DateTime.parse(json['identityVerifiedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  static SubscriptionTier _parseTier(String? tier) {
    if (tier == 'standard') return SubscriptionTier.standard;
    return SubscriptionTier.official; // Default to official for existing pilots
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'licenseNumber': licenseNumber,
        'name': name,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'photoUrl': photoUrl,
        'subscriptionTier': subscriptionTier.name,
      };

  /// Display name: firstName lastName, or fallback to name field
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) {
      return firstName!;
    }
    return name;
  }

  bool get isActive => status == 'active';
  bool get isOfficialTier => subscriptionTier == SubscriptionTier.official;
  bool get isStandardTier => subscriptionTier == SubscriptionTier.standard;
  bool get isIdentityVerified => identityVerifiedAt != null;

  /// Check if pilot can enroll for blockchain identity
  bool get canEnrollBlockchainIdentity => isOfficialTier && isIdentityVerified;
}
