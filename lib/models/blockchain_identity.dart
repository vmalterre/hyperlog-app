import 'package:hyperlog/models/attestation.dart';

/// Public key with validity timestamps
/// Used to track key rotation and verify signatures across device changes
class PublicKey {
  final String keyPem; // PEM-encoded public key
  final DateTime issuedAt;
  final DateTime? revokedAt; // null if active

  PublicKey({
    required this.keyPem,
    required this.issuedAt,
    this.revokedAt,
  });

  bool get isActive => revokedAt == null;

  factory PublicKey.fromJson(Map<String, dynamic> json) {
    return PublicKey(
      keyPem: json['keyPem'],
      issuedAt: DateTime.parse(json['issuedAt']),
      revokedAt: json['revokedAt'] != null && json['revokedAt'].isNotEmpty
          ? DateTime.parse(json['revokedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'keyPem': keyPem,
        'issuedAt': issuedAt.toIso8601String(),
        'revokedAt': revokedAt?.toIso8601String(),
      };
}

/// Blockchain Identity - represents a pilot's on-chain identity
/// Contains NO personal data - only UUID, public keys, and attestations
/// Personal data lives in PostgreSQL (AppIdentity) and is linked by UUID
class BlockchainIdentity {
  final String uuid; // Links to PostgreSQL user.id
  final String enrollmentId; // Fabric CA enrollment ID
  final String certificatePem; // Current X.509 certificate
  final List<Attestation> attestations;
  final List<PublicKey> publicKeys;
  final String status; // "active", "revoked", "gdpr_deleted"
  final DateTime issuedAt;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  BlockchainIdentity({
    required this.uuid,
    required this.enrollmentId,
    required this.certificatePem,
    required this.attestations,
    required this.publicKeys,
    required this.status,
    required this.issuedAt,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if identity is active
  bool get isActive => status == 'active';

  /// Check if certificate is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if certificate is expiring soon (within 30 days)
  bool get isExpiringSoon {
    final daysUntilExpiry = expiresAt.difference(DateTime.now()).inDays;
    return daysUntilExpiry > 0 && daysUntilExpiry <= 30;
  }

  /// Get the primary attestation (first one)
  Attestation? get primaryAttestation =>
      attestations.isNotEmpty ? attestations.first : null;

  /// Get display string for all attestations
  String get attestationSummary =>
      attestations.map((a) => '${a.issuingAuth} ${a.type}').join(', ');

  /// Get count of active public keys
  int get activeKeyCount => publicKeys.where((k) => k.isActive).length;

  factory BlockchainIdentity.fromJson(Map<String, dynamic> json) {
    return BlockchainIdentity(
      uuid: json['uuid'],
      enrollmentId: json['enrollmentId'],
      certificatePem: json['certificatePem'] ?? '',
      attestations: (json['attestations'] as List?)
              ?.map((a) => Attestation.fromJson(a))
              .toList() ??
          [],
      publicKeys: (json['publicKeys'] as List?)
              ?.map((k) => PublicKey.fromJson(k))
              .toList() ??
          [],
      status: json['status'] ?? 'active',
      issuedAt: DateTime.parse(json['issuedAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'enrollmentId': enrollmentId,
        'certificatePem': certificatePem,
        'attestations': attestations.map((a) => a.toJson()).toList(),
        'publicKeys': publicKeys.map((k) => k.toJson()).toList(),
        'status': status,
        'issuedAt': issuedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
