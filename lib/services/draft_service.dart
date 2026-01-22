import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';

/// Service for managing flight draft persistence.
///
/// Handles auto-saving form state to recover from app crashes or accidental closure.
/// Drafts are stored in local SQLite database and persist across app restarts.
class DraftService {
  final HyperlogDatabase _db;
  final _uuid = const Uuid();

  Timer? _autoSaveTimer;
  String? _currentDraftId;

  /// Debounce duration for auto-save (30 seconds)
  static const _autoSaveDuration = Duration(seconds: 30);

  DraftService({required HyperlogDatabase db}) : _db = db;

  /// Start auto-save for a draft session
  /// Returns the draft ID for this session
  String startDraftSession() {
    _currentDraftId = _uuid.v4();
    return _currentDraftId!;
  }

  /// Schedule an auto-save (debounced)
  void scheduleAutoSave(FlightDraftData data) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(_autoSaveDuration, () {
      if (_currentDraftId != null) {
        saveDraft(_currentDraftId!, data);
      }
    });
  }

  /// Save draft immediately (call on app background)
  Future<void> saveDraft(String draftId, FlightDraftData data) async {
    final json = jsonEncode(data.toJson());
    await _db.saveDraft(draftId, json);
  }

  /// Check if there's a draft to restore
  Future<bool> hasDraft() async {
    final draft = await _db.getLatestDraft();
    return draft != null;
  }

  /// Get the latest draft for restoration
  Future<FlightDraftData?> getLatestDraft() async {
    final draft = await _db.getLatestDraft();
    if (draft == null) return null;

    try {
      final json = jsonDecode(draft.formData) as Map<String, dynamic>;
      final data = FlightDraftData.fromJson(json);
      _currentDraftId = draft.id;
      return data;
    } catch (e) {
      // Corrupted draft - delete it
      await _db.deleteDraft(draft.id);
      return null;
    }
  }

  /// Delete the current draft (call after successful save)
  Future<void> deleteDraft() async {
    _autoSaveTimer?.cancel();
    if (_currentDraftId != null) {
      await _db.deleteDraft(_currentDraftId!);
      _currentDraftId = null;
    }
  }

  /// Delete all drafts
  Future<void> deleteAllDrafts() async {
    _autoSaveTimer?.cancel();
    await _db.deleteAllDrafts();
    _currentDraftId = null;
  }

  /// Stop auto-save timer
  void dispose() {
    _autoSaveTimer?.cancel();
  }
}

/// Data model for flight draft
class FlightDraftData {
  // Basic info
  final String? flightNumber;
  final String depCode;
  final String destCode;
  final String? depIcao;
  final String? depIata;
  final String? destIcao;
  final String? destIata;
  final String aircraftType;
  final String aircraftReg;
  final String remarks;

  // Date and time
  final DateTime flightDate;
  final int blockOffHour;
  final int blockOffMinute;
  final int blockOnHour;
  final int blockOnMinute;

  // Role and flying
  final String role;
  final String? secondaryRole;
  final bool isPilotFlying;

  // Takeoffs and landings
  final int dayTakeoffs;
  final int nightTakeoffs;
  final int dayLandings;
  final int nightLandings;

  // Time details
  final int nightMinutes;
  final int ifrMinutes;
  final int soloMinutes;
  final int multiEngineMinutes;
  final int crossCountryMinutes;
  final int roleTimeMinutes;
  final Map<String, int> customTimeFields;

  // Approaches
  final int visualApproaches;
  final int ilsCatIApproaches;
  final int ilsCatIIApproaches;
  final int ilsCatIIIApproaches;
  final int rnpApproaches;
  final int rnpArApproaches;
  final int vorApproaches;
  final int ndbApproaches;
  final int ilsBackCourseApproaches;
  final int localizerApproaches;

  // Crew members (excluding pilot)
  final List<CrewEntryDraft> additionalCrew;

  // Metadata
  final DateTime savedAt;

  FlightDraftData({
    this.flightNumber,
    required this.depCode,
    required this.destCode,
    this.depIcao,
    this.depIata,
    this.destIcao,
    this.destIata,
    required this.aircraftType,
    required this.aircraftReg,
    required this.remarks,
    required this.flightDate,
    required this.blockOffHour,
    required this.blockOffMinute,
    required this.blockOnHour,
    required this.blockOnMinute,
    required this.role,
    this.secondaryRole,
    required this.isPilotFlying,
    required this.dayTakeoffs,
    required this.nightTakeoffs,
    required this.dayLandings,
    required this.nightLandings,
    required this.nightMinutes,
    required this.ifrMinutes,
    required this.soloMinutes,
    required this.multiEngineMinutes,
    required this.crossCountryMinutes,
    required this.roleTimeMinutes,
    required this.customTimeFields,
    required this.visualApproaches,
    required this.ilsCatIApproaches,
    required this.ilsCatIIApproaches,
    required this.ilsCatIIIApproaches,
    required this.rnpApproaches,
    required this.rnpArApproaches,
    required this.vorApproaches,
    required this.ndbApproaches,
    required this.ilsBackCourseApproaches,
    required this.localizerApproaches,
    required this.additionalCrew,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();

  /// Create from form state
  factory FlightDraftData.fromFormState({
    required TextEditingController flightNumberController,
    required TextEditingController depController,
    required TextEditingController destController,
    required TextEditingController aircraftTypeController,
    required TextEditingController aircraftRegController,
    required TextEditingController remarksController,
    String? depIcao,
    String? depIata,
    String? destIcao,
    String? destIata,
    required DateTime flightDate,
    required TimeOfDay blockOff,
    required TimeOfDay blockOn,
    required String role,
    String? secondaryRole,
    required bool isPilotFlying,
    required int dayTakeoffs,
    required int nightTakeoffs,
    required int dayLandings,
    required int nightLandings,
    required int nightMinutes,
    required int ifrMinutes,
    required int soloMinutes,
    required int multiEngineMinutes,
    required int crossCountryMinutes,
    required int roleTimeMinutes,
    required Map<String, int> customTimeFields,
    required int visualApproaches,
    required int ilsCatIApproaches,
    required int ilsCatIIApproaches,
    required int ilsCatIIIApproaches,
    required int rnpApproaches,
    required int rnpArApproaches,
    required int vorApproaches,
    required int ndbApproaches,
    required int ilsBackCourseApproaches,
    required int localizerApproaches,
    required List<CrewEntryDraft> additionalCrew,
  }) {
    return FlightDraftData(
      flightNumber: flightNumberController.text.isNotEmpty
          ? flightNumberController.text
          : null,
      depCode: depController.text,
      destCode: destController.text,
      depIcao: depIcao,
      depIata: depIata,
      destIcao: destIcao,
      destIata: destIata,
      aircraftType: aircraftTypeController.text,
      aircraftReg: aircraftRegController.text,
      remarks: remarksController.text,
      flightDate: flightDate,
      blockOffHour: blockOff.hour,
      blockOffMinute: blockOff.minute,
      blockOnHour: blockOn.hour,
      blockOnMinute: blockOn.minute,
      role: role,
      secondaryRole: secondaryRole,
      isPilotFlying: isPilotFlying,
      dayTakeoffs: dayTakeoffs,
      nightTakeoffs: nightTakeoffs,
      dayLandings: dayLandings,
      nightLandings: nightLandings,
      nightMinutes: nightMinutes,
      ifrMinutes: ifrMinutes,
      soloMinutes: soloMinutes,
      multiEngineMinutes: multiEngineMinutes,
      crossCountryMinutes: crossCountryMinutes,
      roleTimeMinutes: roleTimeMinutes,
      customTimeFields: customTimeFields,
      visualApproaches: visualApproaches,
      ilsCatIApproaches: ilsCatIApproaches,
      ilsCatIIApproaches: ilsCatIIApproaches,
      ilsCatIIIApproaches: ilsCatIIIApproaches,
      rnpApproaches: rnpApproaches,
      rnpArApproaches: rnpArApproaches,
      vorApproaches: vorApproaches,
      ndbApproaches: ndbApproaches,
      ilsBackCourseApproaches: ilsBackCourseApproaches,
      localizerApproaches: localizerApproaches,
      additionalCrew: additionalCrew,
    );
  }

  Map<String, dynamic> toJson() => {
        'flightNumber': flightNumber,
        'depCode': depCode,
        'destCode': destCode,
        'depIcao': depIcao,
        'depIata': depIata,
        'destIcao': destIcao,
        'destIata': destIata,
        'aircraftType': aircraftType,
        'aircraftReg': aircraftReg,
        'remarks': remarks,
        'flightDate': flightDate.toIso8601String(),
        'blockOffHour': blockOffHour,
        'blockOffMinute': blockOffMinute,
        'blockOnHour': blockOnHour,
        'blockOnMinute': blockOnMinute,
        'role': role,
        'secondaryRole': secondaryRole,
        'isPilotFlying': isPilotFlying,
        'dayTakeoffs': dayTakeoffs,
        'nightTakeoffs': nightTakeoffs,
        'dayLandings': dayLandings,
        'nightLandings': nightLandings,
        'nightMinutes': nightMinutes,
        'ifrMinutes': ifrMinutes,
        'soloMinutes': soloMinutes,
        'multiEngineMinutes': multiEngineMinutes,
        'crossCountryMinutes': crossCountryMinutes,
        'roleTimeMinutes': roleTimeMinutes,
        'customTimeFields': customTimeFields,
        'visualApproaches': visualApproaches,
        'ilsCatIApproaches': ilsCatIApproaches,
        'ilsCatIIApproaches': ilsCatIIApproaches,
        'ilsCatIIIApproaches': ilsCatIIIApproaches,
        'rnpApproaches': rnpApproaches,
        'rnpArApproaches': rnpArApproaches,
        'vorApproaches': vorApproaches,
        'ndbApproaches': ndbApproaches,
        'ilsBackCourseApproaches': ilsBackCourseApproaches,
        'localizerApproaches': localizerApproaches,
        'additionalCrew': additionalCrew.map((c) => c.toJson()).toList(),
        'savedAt': savedAt.toIso8601String(),
      };

  factory FlightDraftData.fromJson(Map<String, dynamic> json) {
    return FlightDraftData(
      flightNumber: json['flightNumber'] as String?,
      depCode: json['depCode'] as String? ?? '',
      destCode: json['destCode'] as String? ?? '',
      depIcao: json['depIcao'] as String?,
      depIata: json['depIata'] as String?,
      destIcao: json['destIcao'] as String?,
      destIata: json['destIata'] as String?,
      aircraftType: json['aircraftType'] as String? ?? '',
      aircraftReg: json['aircraftReg'] as String? ?? '',
      remarks: json['remarks'] as String? ?? '',
      flightDate: DateTime.parse(json['flightDate'] as String),
      blockOffHour: json['blockOffHour'] as int? ?? 0,
      blockOffMinute: json['blockOffMinute'] as int? ?? 0,
      blockOnHour: json['blockOnHour'] as int? ?? 0,
      blockOnMinute: json['blockOnMinute'] as int? ?? 0,
      role: json['role'] as String? ?? 'PIC',
      secondaryRole: json['secondaryRole'] as String?,
      isPilotFlying: json['isPilotFlying'] as bool? ?? true,
      dayTakeoffs: json['dayTakeoffs'] as int? ?? 0,
      nightTakeoffs: json['nightTakeoffs'] as int? ?? 0,
      dayLandings: json['dayLandings'] as int? ?? 0,
      nightLandings: json['nightLandings'] as int? ?? 0,
      nightMinutes: json['nightMinutes'] as int? ?? 0,
      ifrMinutes: json['ifrMinutes'] as int? ?? 0,
      soloMinutes: json['soloMinutes'] as int? ?? 0,
      multiEngineMinutes: json['multiEngineMinutes'] as int? ?? 0,
      crossCountryMinutes: json['crossCountryMinutes'] as int? ?? 0,
      roleTimeMinutes: json['roleTimeMinutes'] as int? ?? 0,
      customTimeFields: (json['customTimeFields'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      visualApproaches: json['visualApproaches'] as int? ?? 0,
      ilsCatIApproaches: json['ilsCatIApproaches'] as int? ?? 0,
      ilsCatIIApproaches: json['ilsCatIIApproaches'] as int? ?? 0,
      ilsCatIIIApproaches: json['ilsCatIIIApproaches'] as int? ?? 0,
      rnpApproaches: json['rnpApproaches'] as int? ?? 0,
      rnpArApproaches: json['rnpArApproaches'] as int? ?? 0,
      vorApproaches: json['vorApproaches'] as int? ?? 0,
      ndbApproaches: json['ndbApproaches'] as int? ?? 0,
      ilsBackCourseApproaches: json['ilsBackCourseApproaches'] as int? ?? 0,
      localizerApproaches: json['localizerApproaches'] as int? ?? 0,
      additionalCrew: (json['additionalCrew'] as List<dynamic>?)
              ?.map((c) => CrewEntryDraft.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  /// Get TimeOfDay for block off
  TimeOfDay get blockOff => TimeOfDay(hour: blockOffHour, minute: blockOffMinute);

  /// Get TimeOfDay for block on
  TimeOfDay get blockOn => TimeOfDay(hour: blockOnHour, minute: blockOnMinute);
}

/// Crew entry draft data
class CrewEntryDraft {
  final String name;
  final String role;
  final String? secondaryRole;

  CrewEntryDraft({
    required this.name,
    required this.role,
    this.secondaryRole,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'secondaryRole': secondaryRole,
      };

  factory CrewEntryDraft.fromJson(Map<String, dynamic> json) {
    return CrewEntryDraft(
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'PIC',
      secondaryRole: json['secondaryRole'] as String?,
    );
  }
}
