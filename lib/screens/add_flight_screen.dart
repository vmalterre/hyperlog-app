import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/airport.dart';
import '../models/logbook_entry.dart';
import '../models/saved_pilot.dart';
import '../models/user_aircraft_registration.dart';
import '../services/aircraft_service.dart';
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
import '../widgets/form/duration_quick_set.dart';
import '../widgets/form/duration_display.dart';
import '../widgets/form/crew_entry_card.dart';
import '../widgets/form/airport_route_fields.dart';

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
  final AircraftService _aircraftService = AircraftService();

  // Crew members - first entry is always the current pilot
  late CrewEntry _pilotCrewEntry;
  final List<CrewEntry> _additionalCrewEntries = [];
  List<SavedPilot> _savedPilots = [];

  // User aircraft registrations
  List<UserAircraftRegistration> _userAircraft = [];
  UserAircraftRegistration? _selectedAircraft;
  bool _isLoadingAircraft = true;

  // Selected airports (for ICAO/IATA extraction)
  Airport? _selectedDepAirport;
  Airport? _selectedDestAirport;

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
  String? _aircraftError;

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
  // Automatic fields (calculated based on aircraft/times)
  int _nightMinutes = 0;
  int _multiEngineMinutes = 0;
  int _multiPilotMinutes = 0;
  // Manual fields (user-entered)
  int _ifrMinutes = 0;
  int _soloMinutes = 0;
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
    _remarksController.addListener(_onFormChanged);

    // Load saved pilots for autocomplete
    _loadSavedPilots();

    // Load user's saved aircraft
    _loadUserAircraft();
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
      _multiPilotMinutes = 0; // TODO: load from model when field is added
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

  Future<void> _loadUserAircraft() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      setState(() => _isLoadingAircraft = false);
      return;
    }

    try {
      final aircraft = await _aircraftService.getUserAircraftRegistrations(userId);
      if (mounted) {
        setState(() {
          _userAircraft = aircraft;
          _isLoadingAircraft = false;
        });

        // In edit mode, try to match existing registration to user's aircraft
        if (widget.entry != null) {
          _matchExistingAircraft();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAircraft = false);
      }
    }
  }

  /// In edit mode, try to match the existing aircraft registration to user's saved aircraft
  void _matchExistingAircraft() {
    final entry = widget.entry;
    if (entry == null) return;

    final existingReg = entry.aircraftReg.toUpperCase();

    // Find matching registration in user's aircraft list
    final match = _userAircraft.cast<UserAircraftRegistration?>().firstWhere(
      (a) => a?.registration.toUpperCase() == existingReg,
      orElse: () => null,
    );

    if (match != null) {
      setState(() {
        _selectedAircraft = match;
        _aircraftTypeController.text = match.icaoDesignator;
        _aircraftRegController.text = match.registration;
      });
    }
  }

  /// Shows the aircraft picker bottom sheet
  void _showAircraftPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AircraftPickerSheet(
        aircraft: _userAircraft,
        selectedAircraft: _selectedAircraft,
        onSelect: _onAircraftSelected,
      ),
    );
  }

  /// Called when an aircraft is selected from the picker
  void _onAircraftSelected(UserAircraftRegistration aircraft) {
    setState(() {
      _selectedAircraft = aircraft;
      _aircraftTypeController.text = aircraft.icaoDesignator;
      _aircraftRegController.text = aircraft.registration;
      _aircraftError = null;
      _hasChanges = true;
    });

    // Auto-set multi-engine time if aircraft is multi-engine
    if (aircraft.isMultiEngine && _multiEngineMinutes == 0) {
      setState(() {
        _multiEngineMinutes = _totalFlightMinutes;
        if (!_detailsExpanded) {
          _detailsExpanded = true;
        }
      });
    }
  }

  /// Build empty state when user has no saved aircraft
  Widget _buildNoAircraftState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.airplanemode_inactive,
          color: AppColors.whiteDarker,
          size: 32,
        ),
        const SizedBox(height: 12),
        Text(
          'No aircraft saved',
          style: AppTypography.body.copyWith(
            color: AppColors.whiteDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Add aircraft in My Aircraft first',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.whiteDarker,
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/my-aircraft');
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Aircraft'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.denim,
          ),
        ),
      ],
    );
  }

  /// Build the aircraft picker field
  Widget _buildAircraftPicker() {
    // Display text: "REG - Type" or empty for hint
    final displayText = _selectedAircraft != null
        ? '${_selectedAircraft!.registration} - ${_selectedAircraft!.aircraftTypeDisplay}'
        : '';

    return GestureDetector(
      onTap: _showAircraftPicker,
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          controller: TextEditingController(text: displayText),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          ),
          validator: (_) => _aircraftError,
          decoration: InputDecoration(
            labelText: 'Aircraft',
            hintText: 'G-ABCD',
            counterText: '',
            suffixIcon: Icon(
              Icons.search,
              color: AppColors.whiteDarker,
            ),
          ),
        ),
      ),
    );
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

  String? _validateAirportCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    // Allow any non-empty input (codes, names, unknown airfields)
    return null;
  }

  bool _validateForm() {
    // Check departure (any non-empty value for codes, names, unknown airfields)
    final dep = _depController.text.trim();
    if (dep.isEmpty) {
      _scrollToField(_depKey);
      return false;
    }

    // Check destination (any non-empty value)
    final dest = _destController.text.trim();
    if (dest.isEmpty) {
      _scrollToField(_destKey);
      return false;
    }

    // Check aircraft selection
    if (_selectedAircraft == null) {
      setState(() => _aircraftError = 'Please select an aircraft');
      _scrollToField(_aircraftRegKey);
      return false;
    } else {
      if (_aircraftError != null) {
        setState(() => _aircraftError = null);
      }
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
        // Include ICAO/IATA codes when airport was selected from autocomplete
        depIcao: _selectedDepAirport?.icaoCode,
        depIata: _selectedDepAirport?.iataCode,
        destIcao: _selectedDestAirport?.icaoCode,
        destIata: _selectedDestAirport?.iataCode,
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

  Future<void> _deleteEntry() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text(
          'Delete Flight?',
          style: AppTypography.h4.copyWith(color: AppColors.white),
        ),
        content: Text(
          'This will permanently delete this flight and all associated crew records. This action cannot be undone.',
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
              'Delete',
              style: AppTypography.button.copyWith(color: const Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _flightService.deleteFlight(widget.entry!.id);

      if (mounted) {
        // Pop back to logbook screen (skip flight detail since flight no longer exists)
        // LogbookScreen refreshes automatically when returning from FlightDetailScreen
        final navigator = Navigator.of(context);
        navigator.pop(); // Pop AddFlightScreen
        navigator.pop(); // Pop FlightDetailScreen back to LogbookScreen
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Failed to delete flight. Please try again.');
      }
    }
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
                          AirportRouteFields(
                            depController: _depController,
                            destController: _destController,
                            initialDepAirport: _selectedDepAirport,
                            initialDestAirport: _selectedDestAirport,
                            depKey: _depKey,
                            destKey: _destKey,
                            depValidator: _validateAirportCode,
                            destValidator: _validateAirportCode,
                            onDepAirportSelected: (airport) {
                              setState(() {
                                _selectedDepAirport = airport;
                                _hasChanges = true;
                              });
                            },
                            onDestAirportSelected: (airport) {
                              setState(() {
                                _selectedDestAirport = airport;
                                _hasChanges = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Aircraft Section
                    _SectionHeader(title: 'AIRCRAFT'),
                    const SizedBox(height: 12),
                    GlassContainer(
                      key: _aircraftRegKey,
                      padding: const EdgeInsets.all(20),
                      child: _isLoadingAircraft
                          ? const Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.denim,
                                ),
                              ),
                            )
                          : _userAircraft.isEmpty
                              ? _buildNoAircraftState()
                              : _buildAircraftPicker(),
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
                            // Automatic fields (calculated based on aircraft/times)
                            const SizedBox(height: 16),
                            DurationDisplay(
                              label: 'Night',
                              minutes: _nightMinutes,
                            ),
                            const SizedBox(height: 12),
                            DurationDisplay(
                              label: 'Multi-Engine',
                              minutes: _multiEngineMinutes,
                            ),
                            const SizedBox(height: 12),
                            DurationDisplay(
                              label: 'Multi-Pilot',
                              minutes: _multiPilotMinutes,
                            ),

                            // Divider between automatic and manual fields
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Divider(
                                color: AppColors.borderSubtle,
                                height: 1,
                              ),
                            ),

                            // Manual fields (user-entered)
                            DurationQuickSet(
                              label: 'IFR',
                              minutes: _ifrMinutes,
                              maxMinutes: _totalFlightMinutes,
                              blockOff: _blockOff,
                              blockOn: _blockOn,
                              onChanged: (value) {
                                setState(() {
                                  _ifrMinutes = value;
                                  _hasChanges = true;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            DurationQuickSet(
                              label: 'Solo',
                              minutes: _soloMinutes,
                              maxMinutes: _totalFlightMinutes,
                              blockOff: _blockOff,
                              blockOn: _blockOn,
                              onChanged: (value) {
                                setState(() {
                                  _soloMinutes = value;
                                  _hasChanges = true;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            DurationQuickSet(
                              label: 'Cross-Country',
                              minutes: _crossCountryMinutes,
                              maxMinutes: _totalFlightMinutes,
                              blockOff: _blockOff,
                              blockOn: _blockOn,
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
                                child: DurationQuickSet(
                                  label: fieldName,
                                  minutes: _customTimeFields[fieldName] ?? 0,
                                  maxMinutes: _totalFlightMinutes,
                                  blockOff: _blockOff,
                                  blockOn: _blockOn,
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

                    // Delete Button (edit mode only)
                    if (widget.isEditMode) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _deleteEntry,
                          icon: const Icon(Icons.delete_outline, size: 20),
                          label: const Text('Delete Flight'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

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

/// Bottom sheet for selecting aircraft from user's saved registrations
class _AircraftPickerSheet extends StatefulWidget {
  final List<UserAircraftRegistration> aircraft;
  final UserAircraftRegistration? selectedAircraft;
  final ValueChanged<UserAircraftRegistration> onSelect;

  const _AircraftPickerSheet({
    required this.aircraft,
    required this.selectedAircraft,
    required this.onSelect,
  });

  @override
  State<_AircraftPickerSheet> createState() => _AircraftPickerSheetState();
}

class _AircraftPickerSheetState extends State<_AircraftPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<UserAircraftRegistration> _filteredAircraft = [];

  @override
  void initState() {
    super.initState();
    _filteredAircraft = widget.aircraft;
    _searchController.addListener(_onSearchChanged);
    // Auto-focus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredAircraft = widget.aircraft;
      } else {
        _filteredAircraft = widget.aircraft.where((a) {
          final reg = a.registration.toLowerCase();
          final type = a.aircraftTypeDisplay.toLowerCase();
          final icao = a.icaoDesignator.toLowerCase();
          return reg.contains(query) || type.contains(query) || icao.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: AppColors.nightRiderDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.whiteDarker,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Text(
                  'Select Aircraft',
                  style: AppTypography.h4,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: AppColors.whiteDarker),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Search registration or type...',
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.whiteDarker,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.whiteDarker,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: Icon(Icons.clear, color: AppColors.whiteDarker),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.nightRider,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderVisible),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderVisible),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.denim, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Aircraft list
          Expanded(
            child: _filteredAircraft.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _searchController.text.isEmpty
                                ? Icons.flight
                                : Icons.search_off,
                            color: AppColors.whiteDarker,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Search for an aircraft'
                                : 'No aircraft found',
                            style: AppTypography.body.copyWith(
                              color: AppColors.whiteDarker,
                            ),
                          ),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Enter registration or type'
                                : 'Try a different search',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredAircraft.length,
                    itemBuilder: (context, index) {
                      final item = _filteredAircraft[index];
                      final isSelected = widget.selectedAircraft?.id == item.id;
                      return _AircraftListItem(
                        aircraft: item,
                        isSelected: isSelected,
                        onTap: () {
                          widget.onSelect(item);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Individual aircraft item in the picker list
class _AircraftListItem extends StatelessWidget {
  final UserAircraftRegistration aircraft;
  final bool isSelected;
  final VoidCallback onTap;

  const _AircraftListItem({
    required this.aircraft,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.denim.withValues(alpha: 0.15)
              : AppColors.glass50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.denim : AppColors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.flight,
              color: isSelected ? AppColors.denim : AppColors.whiteDarker,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aircraft.registration,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.denim : AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    aircraft.aircraftTypeDisplay,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.whiteDark,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.denim,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

