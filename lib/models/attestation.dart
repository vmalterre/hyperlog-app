/// Attestation - represents a verified credential on the blockchain
/// Contains NO personal data - only credential type and validity
/// Example: "EASA ATPL License, Valid From: 2024-01-15"
class Attestation {
  final String type; // "EASA_ATPL", "FAA_CPL", "UK_PPL"
  final String issuingAuth; // "EASA", "FAA", "UK_CAA"
  final DateTime validFrom;
  final DateTime? validTo; // null if perpetual
  final String verifiedBy; // "HyperLog Trust Engine"
  final DateTime verifiedAt;

  Attestation({
    required this.type,
    required this.issuingAuth,
    required this.validFrom,
    this.validTo,
    required this.verifiedBy,
    required this.verifiedAt,
  });

  /// Human-readable display name for this attestation
  /// e.g., "EASA ATPL Holder"
  String get displayName => '$issuingAuth ${_formatType(type)} Holder';

  /// Format license type for display
  /// e.g., "EASA_ATPL" -> "ATPL"
  String _formatType(String type) {
    // Remove authority prefix if present
    final parts = type.split('_');
    return parts.length > 1 ? parts.sublist(1).join(' ') : type;
  }

  /// Check if attestation is currently valid
  bool get isValid {
    final now = DateTime.now();
    if (now.isBefore(validFrom)) return false;
    if (validTo != null && now.isAfter(validTo!)) return false;
    return true;
  }

  /// Check if attestation is expiring soon (within 30 days)
  bool get isExpiringSoon {
    if (validTo == null) return false;
    final daysUntilExpiry = validTo!.difference(DateTime.now()).inDays;
    return daysUntilExpiry > 0 && daysUntilExpiry <= 30;
  }

  factory Attestation.fromJson(Map<String, dynamic> json) {
    return Attestation(
      type: json['type'],
      issuingAuth: json['issuingAuth'],
      validFrom: DateTime.parse(json['validFrom']),
      validTo: json['validTo'] != null && json['validTo'].isNotEmpty
          ? DateTime.parse(json['validTo'])
          : null,
      verifiedBy: json['verifiedBy'],
      verifiedAt: DateTime.parse(json['verifiedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'issuingAuth': issuingAuth,
        'validFrom': validFrom.toIso8601String(),
        'validTo': validTo?.toIso8601String(),
        'verifiedBy': verifiedBy,
        'verifiedAt': verifiedAt.toIso8601String(),
      };
}
