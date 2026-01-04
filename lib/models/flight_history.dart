import 'logbook_entry.dart';

/// Represents a single version in the flight history from blockchain
class HistoryEntry {
  final String txId;
  final DateTime timestamp;
  final bool isDelete;
  final LogbookEntry? entry;

  HistoryEntry({
    required this.txId,
    required this.timestamp,
    required this.isDelete,
    this.entry,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      txId: json['txId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isDelete: json['isDelete'] as bool,
      entry: json['entry'] != null
          ? LogbookEntry.fromJson(json['entry'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Complete history of a flight entry from blockchain
class FlightHistory {
  final String flightId;
  final List<HistoryEntry> history;

  FlightHistory({
    required this.flightId,
    required this.history,
  });

  factory FlightHistory.fromJson(Map<String, dynamic> json) {
    return FlightHistory(
      flightId: json['flightId'] as String,
      history: (json['history'] as List<dynamic>)
          .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Represents a single field change between versions
class FieldChange {
  final String fieldName;
  final String displayName;
  final String? oldValue;
  final String? newValue;

  FieldChange({
    required this.fieldName,
    required this.displayName,
    this.oldValue,
    this.newValue,
  });
}

/// Computed diff between two consecutive versions
class VersionDiff {
  final String txId;
  final DateTime timestamp;
  final List<FieldChange> changes;
  final bool isCreation;
  final bool isDeletion;
  final String? pilotLicense;
  final String? pilotName;
  final List<Verification> verifications;
  final List<Endorsement> endorsements;

  VersionDiff({
    required this.txId,
    required this.timestamp,
    required this.changes,
    this.isCreation = false,
    this.isDeletion = false,
    this.pilotLicense,
    this.pilotName,
    this.verifications = const [],
    this.endorsements = const [],
  });

  /// Check if this diff represents a trust level upgrade via external verification
  bool get isVerificationUpgrade {
    final trustChange = changes.firstWhere(
      (c) => c.fieldName == 'trustLevel',
      orElse: () => FieldChange(fieldName: '', displayName: ''),
    );
    return trustChange.oldValue == 'LOGGED' && trustChange.newValue == 'TRACKED';
  }

  /// Check if this diff represents a trust level upgrade via endorsement
  bool get isEndorsementUpgrade {
    final trustChange = changes.firstWhere(
      (c) => c.fieldName == 'trustLevel',
      orElse: () => FieldChange(fieldName: '', displayName: ''),
    );
    return trustChange.newValue == 'ENDORSED';
  }

  /// Get the latest verification (for display purposes)
  Verification? get latestVerification =>
      verifications.isNotEmpty ? verifications.last : null;

  /// Get the latest endorsement (for display purposes)
  Endorsement? get latestEndorsement =>
      endorsements.isNotEmpty ? endorsements.last : null;
}
