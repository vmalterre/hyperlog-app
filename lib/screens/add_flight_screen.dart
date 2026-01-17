import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/logbook_entry.dart';
import '../models/saved_pilot.dart';
import '../services/api_exception.dart';
import '../services/flight_service.dart';
import '../services/pilot_service.dart';
import '../services/preferences_service.dart';
import '../session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/form/glass_text_field.dart';
import '../widgets/form/glass_date_picker.dart';
import '../widgets/form/glass_time_picker.dart';
import '../widgets/form/number_stepper.dart';
import '../widgets/form/duration_stepper.dart';
import '../widgets/form/crew_entry_card.dart';

class AddFlightScreen extends StatefulWidget {
  /// Entry to edit. If null, creates a new flight.
  final LogbookEntry? entry;

  const AddFlightScreen({super.key, this.entry});

  /// Whether we're editing an existing entry
  bool get isEditMode => entry != null;

  @override
  State<AddFlightScreen> createState() => _AddFlightScreenState();
}

class _AddFlightScreenState extends State<AddFlightScreen> {
  final _formKey = GlobalKey<FormState>();
  final FlightService _flightService = FlightService();
  final PilotService _pilotService = PilotService();

  // Crew members - first entry is always the current pilot
  late CrewEntry _pilotCrewEntry;
  final List<CrewEntry> _additionalCrewEntries = [];
  List<SavedPilot> _savedPilots = [];

  // Text controllers
  late TextEditingController _flightNumberController;
  late TextEditingController _depController;
  late TextEditingController _destController;
  late TextEditingController _aircraftTypeController;
  late TextEditingController _aircraftRegController;
  late TextEditingController _remarksController;

  // Keys for validation scrolling
  final _depKey = GlobalKey();
  final _destKey = GlobalKey();
  final _aircraftTypeKey = GlobalKey();
  final _aircraftRegKey = GlobalKey();
  final _landingsKey = GlobalKey();
  final _timesKey = GlobalKey();

  // Date/Time state
  late DateTime _flightDate;
  late TimeOfDay _blockOff;
  late TimeOfDay _blockOn;

  // Selection state
  late String _role;
  late bool _isPilotFlying;
  late int _dayLandings;
  late int _nightLandings;

  // Loading state
  bool _isLoading = false;

  // Validation error state for non-text fields
  String? _landingsError;

  // Approaches state
  int _visualApproaches = 0;
  int _ilsCatIApproaches = 0;
  int _ilsCatIIApproaches = 0;
  int _ilsCatIIIApproaches = 0;
  int _rnpApproaches = 0;
  int _rnpArApproaches = 0;
  int _vorApproaches = 0;
  int _ndbApproaches = 0;
  int _ilsBackCourseApproaches = 0;
  int _localizerApproaches = 0;
  bool _approachesExpanded = false;

  // Details section state
  bool _detailsExpanded = false;
  int _nightMinutes = 0;
  int _ifrMinutes = 0;
  int _soloMinutes = 0;
  int _multiEngineMinutes = 0;
  int _crossCountryMinutes = 0;
  Map<String, int> _customTimeFields = {};

  // Track changes for confirmation dialog
  bool _hasChanges = false;

  String? get _userId {
    return Provider.of<SessionState>(context, listen: false).userId;
  }

  String get _tier {
    return Provider.of<SessionState>(context, listen: false)
        .currentPilot?.subscriptionTier.name ?? 'standard';
  }

  @override
  void initState() {
    super.initState();
    _initializeFields();

    // Listen for changes on all text controllers
    _flightNumberController.addListener(_onFormChanged);
    _depController.addListener(_onFormChanged);
    _destController.addListener(_onFormChanged);
    _aircraftTypeController.addListener(_onFormChanged);
    _aircraftRegController.addListener(_onFormChanged);
    _remarksController.addListener(_onFormChanged);

    // Load saved pilots for autocomplete
    _loadSavedPilots();
  }

  void _initializeFields() {
    final entry = widget.entry;

    if (entry != null) {
      // Edit mode - populate from existing entry
      final creatorCrew = entry.creatorCrew;

      _flightNumberController = TextEditingController(text: entry.flightNumber ?? '');
      _depController = TextEditingController(text: entry.dep);
      _destController = TextEditingController(text: entry.dest);
      _aircraftTypeController = TextEditingController(text: entry.aircraftType);
      _aircraftRegController = TextEditingController(text: entry.aircraftReg);
      _remarksController = TextEditingController(text: creatorCrew?.remarks ?? '');

      _flightDate = entry.flightDate;
      _blockOff = TimeOfDay(hour: entry.blockOff.hour, minute: entry.blockOff.minute);
      _blockOn = TimeOfDay(hour: entry.blockOn.hour, minute: entry.blockOn.minute);

      _role = creatorCrew?.primaryRole ?? PreferencesService.instance.getDefaultRole();
      _isPilotFlying = entry.isPilotFlying;
      _dayLandings = entry.totalLandings.day;
      _nightLandings = entry.totalLandings.night;

      // Initialize detail time fields from existing entry
      final ft = entry.flightTime;
      _nightMinutes = ft.night;
      _ifrMinutes = ft.ifr;
      _soloMinutes = ft.solo;
      _multiEngineMinutes = ft.multiEngine;
      _crossCountryMinutes = ft.crossCountry;
      _customTimeFields = Map.from(ft.customFields);

      // Initialize approaches from existing entry
      final ap = entry.approaches;
      _visualApproaches = ap.visual;
      _ilsCatIApproaches = ap.ilsCatI;
      _ilsCatIIApproaches = ap.ilsCatII;
      _ilsCatIIIApproaches = ap.ilsCatIII;
      _rnpApproaches = ap.rnp;
      _rnpArApproaches = ap.rnpAr;
      _vorApproaches = ap.vor;
      _ndbApproaches = ap.ndb;
      _ilsBackCourseApproaches = ap.ilsBackCourse;
      _localizerApproaches = ap.localizer;

      // Auto-expand if any detail values are set
      if (ft.night > 0 || ft.ifr > 0 || ft.solo > 0 ||
          ft.multiEngine > 0 || ft.crossCountry > 0 ||
          ft.customFields.values.any((v) => v > 0)) {
        _detailsExpanded = true;
      }

      // Auto-expand approaches if any are set
      if (ap.hasAny) {
        _approachesExpanded = true;
      }

      // Initialize pilot crew entry
      _pilotCrewEntry = CrewEntry(name: '', role: _role);

      // Initialize additional crew from existing entry (excluding creator)
      for (final crew in entry.crew) {
        if (crew.pilotUUID != entry.creatorUUID && crew.pilotName != null) {
          _additionalCrewEntries.add(CrewEntry(
            name: crew.pilotName!,
            role: crew.primaryRole,
          ));
        }
      }
    } else {
      // Add mode - use defaults
      _flightNumberController = TextEditingController();
      _depController = TextEditingController();
      _destController = TextEditingController();
      _aircraftTypeController = TextEditingController();
      _aircraftRegController = TextEditingController();
      _remarksController = TextEditingController();

      _flightDate = DateTime.now();
      _blockOff = const TimeOfDay(hour: 8, minute: 0);
      _blockOn = const TimeOfDay(hour: 10, minute: 0);

      _role = PreferencesService.instance.getDefaultRole();
      _isPilotFlying = true;
      _dayLandings = 1;
      _nightLandings = 0;

      // Initialize pilot crew entry with default role (name set in didChangeDependencies)
      _pilotCrewEntry = CrewEntry(name: '', role: _role);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set pilot name from session (can't access context in initState)
    final pilot = Provider.of<SessionState>(context, listen: false).currentPilot;
    if (pilot != null && _pilotCrewEntry.name.isEmpty) {
      _pilotCrewEntry.name = pilot.name;
    }
  }

  Future<void> _loadSavedPilots() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    try {
      final pilots = await _pilotService.getSavedPilotsByUserId(userId);
      if (mounted) {
        setState(() {
          _savedPilots = pilots;
        });
      }
    } catch (e) {
      // Silently fail - autocomplete won't work but that's OK
    }
  }

  Future<void> _saveNewCrewNames() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    final existingNames = _savedPilots.map((p) => p.name.toLowerCase()).toSet();

    for (final crew in _additionalCrewEntries) {
      final name = crew.name.trim();
      if (name.isNotEmpty && !existingNames.contains(name.toLowerCase())) {
        try {
          await _pilotService.createSavedPilotByUserId(userId, name);
          existingNames.add(name.toLowerCase());
        } catch (e) {
          // Silently fail - pilot won't be saved but that's OK
        }
      }
    }
  }

  @override
  void dispose() {
    _flightNumberController.dispose();
    _depController.dispose();
    _destController.dispose();
    _aircraftTypeController.dispose();
    _aircraftRegController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  /// Scrolls to a widget by its GlobalKey and triggers form validation
  void _scrollToField(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.3, // Position field 30% from top
      );
    }
    // Trigger inline error display on all fields
    _formKey.currentState?.validate();
  }

  /// Shows error snackbar for API/system errors (not field validation)
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Calculate total flight time in minutes from block times
  int get _totalFlightMinutes {
    final offMinutes = _blockOff.hour * 60 + _blockOff.minute;
    final onMinutes = _blockOn.hour * 60 + _blockOn.minute;

    // Handle overnight flights
    if (onMinutes <= offMinutes) {
      return (24 * 60 - offMinutes) + onMinutes;
    }
    return onMinutes - offMinutes;
  }

  String get _formattedFlightTime {
    final hours = _totalFlightMinutes ~/ 60;
    final minutes = _totalFlightMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  /// Build FlightTime with role-based time auto-populated from primary role
  FlightTime get _calculatedFlightTime {
    final total = _totalFlightMinutes;
    // Auto-populate time fields based on the selected primary role
    // Detail times are clamped to not exceed total flight time
    return FlightTime.fromPrimaryRole(
      _role.toUpperCase(),
      total,
      night: _nightMinutes.clamp(0, total),
      ifr: _ifrMinutes.clamp(0, total),
      solo: _soloMinutes.clamp(0, total),
      multiEngine: _multiEngineMinutes.clamp(0, total),
      crossCountry: _crossCountryMinutes.clamp(0, total),
      customFields: _customTimeFields,
    );
  }

  String? _validateIataCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    if (value.length != 3) {
      return '3 letters';
    }
    return null;
  }

  String? _validateAircraftType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    if (value.length < 2) {
      return 'Min 2 chars';
    }
    return null;
  }

  String? _validateAircraftReg(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    if (value.length < 4) {
      return 'Min 4 chars';
    }
    return null;
  }

  bool _validateForm() {
    // Check departure
    final dep = _depController.text.trim();
    if (dep.isEmpty || dep.length != 3) {
      _scrollToField(_depKey);
      return false;
    }

    // Check destination
    final dest = _destController.text.trim();
    if (dest.isEmpty || dest.length != 3) {
      _scrollToField(_destKey);
      return false;
    }

    // Check aircraft type
    final aircraftType = _aircraftTypeController.text.trim();
    if (aircraftType.isEmpty || aircraftType.length < 2) {
      _scrollToField(_aircraftTypeKey);
      return false;
    }

    // Check aircraft registration
    final aircraftReg = _aircraftRegController.text.trim();
    if (aircraftReg.isEmpty || aircraftReg.length < 4) {
      _scrollToField(_aircraftRegKey);
      return false;
    }

    // Check positive flight time
    if (_totalFlightMinutes <= 0) {
      _scrollToField(_timesKey);
      return false;
    }

    // Check at least one landing (only for Pilot Flying)
    if (_isPilotFlying && _dayLandings + _nightLandings < 1) {
      setState(() => _landingsError = 'At least one landing is required');
      _scrollToField(_landingsKey);
      return false;
    } else {
      if (_landingsError != null) {
        setState(() => _landingsError = null);
      }
    }

    // Run form validators for any remaining validation
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    return true;
  }

  Future<void> _saveEntry() async {
    if (!_validateForm()) {
      return;
    }

    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      _showErrorSnackBar('No pilot profile found. Please complete registration.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Build DateTime for block off/on
      final blockOffDateTime = DateTime(
        _flightDate.year,
        _flightDate.month,
        _flightDate.day,
        _blockOff.hour,
        _blockOff.minute,
      );

      var blockOnDateTime = DateTime(
        _flightDate.year,
        _flightDate.month,
        _flightDate.day,
        _blockOn.hour,
        _blockOn.minute,
      );

      // Handle overnight flights
      if (blockOnDateTime.isBefore(blockOffDateTime) ||
          blockOnDateTime.isAtSameMomentAs(blockOffDateTime)) {
        blockOnDateTime = blockOnDateTime.add(const Duration(days: 1));
      }

      // Build the creator's crew entry
      final creatorCrew = CrewMember(
        pilotUUID: userId, // UUID for API
        roles: [
          RoleSegment(
            role: _pilotCrewEntry.role.toUpperCase(),
            start: blockOffDateTime,
            end: blockOnDateTime,
          ),
        ],
        landings: Landings(day: _dayLandings, night: _nightLandings),
        remarks: _remarksController.text,
        joinedAt: DateTime.now(),
      );

      // Build additional crew members from the crew entries
      final additionalCrew = _additionalCrewEntries
          .where((e) => e.isValid)
          .map((e) => CrewMember(
                pilotUUID: 'standard-crew', // Marker for non-registered crew
                pilotName: e.name.trim(),
                roles: [
                  RoleSegment(
                    role: e.role.toUpperCase(),
                    start: blockOffDateTime,
                    end: blockOnDateTime,
                  ),
                ],
                landings: Landings(), // No landings for additional crew
                joinedAt: DateTime.now(),
              ))
          .toList();

      // Build approaches object (only when PF)
      final approaches = _isPilotFlying
          ? Approaches(
              visual: _visualApproaches,
              ilsCatI: _ilsCatIApproaches,
              ilsCatII: _ilsCatIIApproaches,
              ilsCatIII: _ilsCatIIIApproaches,
              rnp: _rnpApproaches,
              rnpAr: _rnpArApproaches,
              vor: _vorApproaches,
              ndb: _ndbApproaches,
              ilsBackCourse: _ilsBackCourseApproaches,
              localizer: _localizerApproaches,
            )
          : const Approaches();

      final entry = LogbookEntry(
        id: widget.entry?.id ?? '', // Use existing ID in edit mode
        creatorUUID: userId, // UUID for API
        flightDate: _flightDate,
        flightNumber: _flightNumberController.text.isEmpty
            ? null
            : _flightNumberController.text.toUpperCase(),
        dep: _depController.text.toUpperCase(),
        dest: _destController.text.toUpperCase(),
        blockOff: blockOffDateTime,
        blockOn: blockOnDateTime,
        aircraftType: _aircraftTypeController.text.toUpperCase(),
        aircraftReg: _aircraftRegController.text.toUpperCase(),
        flightTime: _calculatedFlightTime,
        isPilotFlying: _isPilotFlying,
        approaches: approaches,
        crew: [creatorCrew, ...additionalCrew],
        createdAt: widget.entry?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.isEditMode) {
        await _flightService.updateFlight(widget.entry!.id, entry, tier: _tier);
      } else {
        await _flightService.createFlight(entry);
      }

      // Auto-save new crew names to "My Pilots" (don't block on errors)
      try {
        await _saveNewCrewNames();
      } catch (_) {
        // Ignore errors - crew names not being saved is non-critical
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to refresh list
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(e.message);
      }
    } catch (e) {
      // Catch any unexpected errors (parsing, network, etc.)
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('An unexpected error occurred. Please try again.');
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text(
          'Discard changes?',
          style: AppTypography.h4.copyWith(color: AppColors.white),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to discard them?',
          style: AppTypography.body.copyWith(color: AppColors.whiteDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.button.copyWith(color: AppColors.whiteDarker),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Discard',
              style: AppTypography.button.copyWith(color: AppColors.denim),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.nightRider,
        appBar: AppBar(
          backgroundColor: AppColors.nightRider,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.whiteDark),
            onPressed: () async {
              final navigator = Navigator.of(context);
              if (_hasChanges) {
                final shouldPop = await _onWillPop();
                if (shouldPop && mounted) {
                  navigator.pop();
                }
              } else {
                navigator.pop();
              }
            },
          ),
          title: Text(widget.isEditMode ? 'Amend Flight' : 'Log Flight', style: AppTypography.h3),
          centerTitle: true,
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flight Details Section
                    _SectionHeader(title: 'FLIGHT DETAILS'),
                    const SizedBox(height: 12),
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          GlassDatePicker(
                            label: 'DATE',
                            selectedDate: _flightDate,
                            lastDate: DateTime.now(),
                            onDateSelected: (date) {
                              setState(() {
                                _flightDate = date;
                                _hasChanges = true;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          GlassTextField(
                            controller: _flightNumberController,
                            label: 'Flight Number',
                            hint: 'e.g. BA 123',
                            prefixIcon: Icons.flight,
                            textCapitalization: TextCapitalization.characters,
                            maxLength: 10,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: GlassTextField(
                                  key: _depKey,
                                  controller: _depController,
                                  label: 'From',
                                  hint: 'LHR',
                                  monospace: true,
                                  textCapitalization: TextCapitalization.characters,
                                  maxLength: 3,
                                  validator: _validateIataCode,
                                  inputFormatters: [
                                    UpperCaseTextFormatter(),
                                    LettersOnlyFormatter(),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: AppColors.denimLight,
                                  size: 24,
                                ),
                              ),
                              Expanded(
                                child: GlassTextField(
                                  key: _destKey,
                                  controller: _destController,
                                  label: 'To',
                                  hint: 'JFK',
                                  monospace: true,
                                  textCapitalization: TextCapitalization.characters,
                                  maxLength: 3,
                                  validator: _validateIataCode,
                                  inputFormatters: [
                                    UpperCaseTextFormatter(),
                                    LettersOnlyFormatter(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Aircraft Section
                    _SectionHeader(title: 'AIRCRAFT'),
                    const SizedBox(height: 12),
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: GlassTextField(
                              key: _aircraftTypeKey,
                              controller: _aircraftTypeController,
                              label: 'Type',
                              hint: 'B777',
                              monospace: true,
                              textCapitalization: TextCapitalization.characters,
                              maxLength: 10,
                              validator: _validateAircraftType,
                              inputFormatters: [UpperCaseTextFormatter()],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GlassTextField(
                              key: _aircraftRegKey,
                              controller: _aircraftRegController,
                              label: 'Registration',
                              hint: 'G-STBA',
                              monospace: true,
                              textCapitalization: TextCapitalization.characters,
                              maxLength: 10,
                              validator: _validateAircraftReg,
                              inputFormatters: [AircraftRegFormatter()],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Times Section
                    _SectionHeader(title: 'TIMES'),
                    const SizedBox(height: 12),
                    GlassContainer(
                      key: _timesKey,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GlassTimePicker(
                                  label: 'BLOCK OFF',
                                  selectedTime: _blockOff,
                                  onTimeSelected: (time) {
                                    setState(() {
                                      _blockOff = time;
                                      _hasChanges = true;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GlassTimePicker(
                                  label: 'BLOCK ON',
                                  selectedTime: _blockOn,
                                  onTimeSelected: (time) {
                                    setState(() {
                                      _blockOn = time;
                                      _hasChanges = true;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.denim.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.denim.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  color: AppColors.denimLight,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Block Time: ',
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.whiteDark,
                                  ),
                                ),
                                Text(
                                  _formattedFlightTime,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.denimLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Expandable Details section
                          const SizedBox(height: 16),
                          Divider(
                            color: AppColors.borderSubtle,
                            height: 1,
                          ),
                          const SizedBox(height: 12),
                          // Tappable header to expand/collapse
                          GestureDetector(
                            onTap: () => setState(() => _detailsExpanded = !_detailsExpanded),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Details',
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.whiteDarker,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                AnimatedRotation(
                                  turns: _detailsExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.expand_more,
                                    color: AppColors.whiteDarker,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_detailsExpanded) ...[
                            const SizedBox(height: 16),
                            DurationStepper(
                              label: 'Night',
                              minutes: _nightMinutes,
                              maxMinutes: _totalFlightMinutes,
                              onChanged: (value) {
                                setState(() {
                                  _nightMinutes = value;
                                  _hasChanges = true;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            DurationStepper(
                              label: 'IFR',
                              minutes: _ifrMinutes,
                              maxMinutes: _totalFlightMinutes,
                              onChanged: (value) {
                                setState(() {
                                  _ifrMinutes = value;
                                  _hasChanges = true;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            DurationStepper(
                              label: 'Solo',
                              minutes: _soloMinutes,
                              maxMinutes: _totalFlightMinutes,
                              onChanged: (value) {
                                setState(() {
                                  _soloMinutes = value;
                                  _hasChanges = true;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            DurationStepper(
                              label: 'Multi-Engine',
                              minutes: _multiEngineMinutes,
                              maxMinutes: _totalFlightMinutes,
                              onChanged: (value) {
                                setState(() {
                                  _multiEngineMinutes = value;
                                  _hasChanges = true;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            DurationStepper(
                              label: 'Cross-Country',
                              minutes: _crossCountryMinutes,
                              maxMinutes: _totalFlightMinutes,
                              onChanged: (value) {
                                setState(() {
                                  _crossCountryMinutes = value;
                                  _hasChanges = true;
                                });
                              },
                            ),
                            // Custom time fields from preferences
                            ...PreferencesService.instance.getCustomTimeFields().map((fieldName) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: DurationStepper(
                                  label: fieldName,
                                  minutes: _customTimeFields[fieldName] ?? 0,
                                  maxMinutes: _totalFlightMinutes,
                                  onChanged: (value) {
                                    setState(() {
                                      _customTimeFields[fieldName] = value;
                                      _hasChanges = true;
                                    });
                                  },
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Crew Section
                    _SectionHeader(title: 'CREW'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Current pilot (you) - always first, not removable
                            CrewEntryCard(
                              entry: _pilotCrewEntry,
                              suggestions: _savedPilots,
                              onRemove: () {}, // Can't remove yourself
                              canRemove: false,
                              onChanged: (entry) {
                                setState(() {
                                  _role = entry.role;
                                  _hasChanges = true;
                                });
                              },
                            ),
                            if (_additionalCrewEntries.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  'Additional crew members',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.whiteDarker,
                                  ),
                                ),
                              ),
                            ],
                            // Additional crew entry cards
                            ..._additionalCrewEntries.asMap().entries.map((entry) {
                              final index = entry.key;
                              final crewEntry = entry.value;
                              return CrewEntryCard(
                                entry: crewEntry,
                                suggestions: _savedPilots,
                                onRemove: () {
                                  setState(() {
                                    _additionalCrewEntries.removeAt(index);
                                    _hasChanges = true;
                                  });
                                },
                              );
                            }),
                            // Add crew button
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _additionalCrewEntries.add(CrewEntry());
                                  _hasChanges = true;
                                });
                              },
                              icon: Icon(
                                Icons.add,
                                color: AppColors.denim,
                                size: 20,
                              ),
                              label: Text(
                                'Add Crew Member',
                                style: AppTypography.body.copyWith(
                                  color: AppColors.denim,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Landings Section
                    _SectionHeader(title: 'LANDINGS'),
                    const SizedBox(height: 12),
                    Container(
                      key: _landingsKey,
                      decoration: _landingsError != null
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFEF4444),
                                width: 1.5,
                              ),
                            )
                          : null,
                      child: GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // PF/PM Toggle
                            _PfPmToggle(
                              isPilotFlying: _isPilotFlying,
                              onChanged: (value) {
                                setState(() {
                                  _isPilotFlying = value;
                                  _hasChanges = true;
                                  // Reset landings to 0 when switching to PM
                                  if (!value) {
                                    _dayLandings = 0;
                                    _nightLandings = 0;
                                  }
                                  _landingsError = null;
                                });
                              },
                            ),
                            // Show landing steppers only for PF
                            if (_isPilotFlying) ...[
                              const SizedBox(height: 16),
                              NumberStepper(
                                label: 'Day Landings',
                                value: _dayLandings,
                                minValue: 0,
                                maxValue: 99,
                                onChanged: (value) {
                                  setState(() {
                                    _dayLandings = value;
                                    _hasChanges = true;
                                    _landingsError = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              NumberStepper(
                                label: 'Night Landings',
                                value: _nightLandings,
                                minValue: 0,
                                maxValue: 99,
                                onChanged: (value) {
                                  setState(() {
                                    _nightLandings = value;
                                    _hasChanges = true;
                                    _landingsError = null;
                                  });
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (_landingsError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          _landingsError!,
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ),

                    // Approaches Section (only for PF)
                    if (_isPilotFlying) ...[
                      const SizedBox(height: 24),
                      _SectionHeader(title: 'APPROACHES'),
                      const SizedBox(height: 12),
                      GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Expandable header
                            GestureDetector(
                              onTap: () => setState(() => _approachesExpanded = !_approachesExpanded),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _approachesExpanded ? 'Hide approach types' : 'Add approaches',
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.whiteDarker,
                                    ),
                                  ),
                                  AnimatedRotation(
                                    turns: _approachesExpanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      Icons.expand_more,
                                      color: AppColors.whiteDarker,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_approachesExpanded) ...[
                              const SizedBox(height: 16),
                              NumberStepper(
                                label: 'Visual',
                                value: _visualApproaches,
                                minValue: 0,
                                maxValue: 99,
                                onChanged: (value) {
                                  setState(() {
                                    _visualApproaches = value;
                                    _hasChanges = true;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              NumberStepper(
                                label: 'ILS CAT I',
                                value: _ilsCatIApproaches,
                                minValue: 0,
                                maxValue: 99,
                                onChanged: (value) {
                                  setState(() {
                                    _ilsCatIApproaches = value;
                                    _hasChanges = true;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              NumberStepper(
                                label: 'ILS CAT II',
                                value: _ilsCatIIApproaches,
                                minValue: 0,
                                maxValue: 99,
                                onChanged: (value) {
                                  setState(() {
                                    _ilsCatIIApproaches = value;
                                    _hasChanges = true;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              NumberStepper(
                                label: 'ILS CAT III',
                                value: _ilsCatIIIApproaches,
                                minValue: 0,
                                maxValue: 99,
                                onChanged: (value) {
                                  setState(() {
                                    _ilsCatIIIApproaches = value;
                                    _hasChanges = true;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              NumberStepper(
                                label: 'RNP',
                                value: _rnpApproaches,
                                minValue: 0,
                                maxValue: 99,
                                onChanged: (value) {
                                  setState(() {
                                    _rnpApproaches = value;
                                    _hasChanges = true;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              NumberStepper(
                                label: 'RNP AR',
                                value: _rnpArApproaches,
                                minValue: 0,
                                maxValue: 99,
                                onChanged: (value) {
                                  setState(() {
                                    _rnpArApproaches = value;
                                    _hasChanges = true;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              NumberStepper(
                                label: 'VOR',
                                value: _vorApproaches,
                                minValue: 0,
                                maxValue: 99,
                                onChanged: (value) {
                                  setState(() {
                                    _vorApproaches = value;
                                    _hasChanges = true;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              NumberStepper(
                                label: 'NDB',
                                value: _ndbApproaches,
                                minValue: 0,
                                maxValue: 99,
                                onChanged: (value) {
                                  setState(() {
                                    _ndbApproaches = value;
                                    _hasChanges = true;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              NumberStepper(
                                label: 'ILS Back Course',
                                value: _ilsBackCourseApproaches,
                                minValue: 0,
                                maxValue: 99,
                                onChanged: (value) {
                                  setState(() {
                                    _ilsBackCourseApproaches = value;
                                    _hasChanges = true;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              NumberStepper(
                                label: 'Localizer',
                                value: _localizerApproaches,
                                minValue: 0,
                                maxValue: 99,
                                onChanged: (value) {
                                  setState(() {
                                    _localizerApproaches = value;
                                    _hasChanges = true;
                                  });
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Remarks Section
                    _SectionHeader(title: 'REMARKS'),
                    const SizedBox(height: 12),
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: GlassTextField(
                        controller: _remarksController,
                        label: 'Remarks',
                        hint: 'Add any notes about this flight...',
                        maxLines: 3,
                        maxLength: 500,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    PrimaryButton(
                      label: widget.isEditMode ? 'Save Changes' : 'Save Flight',
                      icon: Icons.check,
                      onPressed: _isLoading ? null : _saveEntry,
                      isLoading: _isLoading,
                      fullWidth: true,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.label.copyWith(
        color: AppColors.denim,
        letterSpacing: 1.5,
      ),
    );
  }
}

/// Toggle for Pilot Flying (PF) vs Pilot Monitoring (PM)
class _PfPmToggle extends StatelessWidget {
  final bool isPilotFlying;
  final ValueChanged<bool> onChanged;

  const _PfPmToggle({
    required this.isPilotFlying,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ToggleButton(
            label: 'PF',
            isSelected: isPilotFlying,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ToggleButton(
            label: 'PM',
            isSelected: !isPilotFlying,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.denim.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.denim
                : AppColors.whiteDarker.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.h4.copyWith(
              color: isSelected ? AppColors.denim : AppColors.whiteDarker,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

