import 'package:hyperlog/models/pilot.dart';

/// App Identity - represents the user's identity in the app layer
/// Stored in Firebase Auth + PostgreSQL
/// Contains personal data that can be deleted per GDPR
class AppIdentity {
  final String id; // PostgreSQL UUID
  final String? firstName;
  final String? lastName;
  final String email;
  final String? photoUrl;
  final String? pilotLicense;
  final String? firebaseUid;
  final SubscriptionTier subscriptionTier;
  final DateTime? identityVerifiedAt;
  final DateTime? gdprDeletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppIdentity({
    required this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.photoUrl,
    this.pilotLicense,
    this.firebaseUid,
    this.subscriptionTier = SubscriptionTier.active,
    this.identityVerifiedAt,
    this.gdprDeletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Display name: firstName lastName, or email if no name
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return email;
  }

  /// Check if user has completed identity verification
  bool get isIdentityVerified => identityVerifiedAt != null;

  /// Check if user's data has been GDPR-deleted
  bool get isGdprDeleted => gdprDeletedAt != null;

  /// Check if user is eligible for blockchain identity
  bool get canEnrollBlockchainIdentity =>
      subscriptionTier == SubscriptionTier.active && isIdentityVerified;

  factory AppIdentity.fromJson(Map<String, dynamic> json) {
    return AppIdentity(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      pilotLicense: json['pilotLicense'],
      firebaseUid: json['firebaseUid'],
      subscriptionTier: _parseTier(json['subscriptionTier']),
      identityVerifiedAt: json['identityVerifiedAt'] != null
          ? DateTime.parse(json['identityVerifiedAt'])
          : null,
      gdprDeletedAt: json['gdprDeletedAt'] != null
          ? DateTime.parse(json['gdprDeletedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  static SubscriptionTier _parseTier(String? tier) {
    if (tier == 'expired') return SubscriptionTier.expired;
    return SubscriptionTier.active;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'photoUrl': photoUrl,
        'pilotLicense': pilotLicense,
        'subscriptionTier': subscriptionTier.name,
      };

  /// Create AppIdentity from legacy Pilot model (for migration)
  factory AppIdentity.fromPilot(Pilot pilot, {required String id}) {
    // Split name into first/last if possible
    final nameParts = pilot.name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : null;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;

    return AppIdentity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: pilot.email,
      pilotLicense: pilot.licenseNumber,
      subscriptionTier: pilot.subscriptionTier,
      createdAt: pilot.createdAt,
      updatedAt: pilot.updatedAt,
    );
  }
}
