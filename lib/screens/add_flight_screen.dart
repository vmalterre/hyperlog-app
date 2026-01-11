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

  // Date/Time state
  late DateTime _flightDate;
  late TimeOfDay _blockOff;
  late TimeOfDay _blockOn;

  // Selection state
  late String _role;
  late int _dayLandings;
  late int _nightLandings;

  // Loading state
  bool _isLoading = false;
  String? _errorMessage;

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
      _dayLandings = entry.totalLandings.day;
      _nightLandings = entry.totalLandings.night;

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

  /// Build FlightTime (role-based time is now computed from crew roles)
  FlightTime get _calculatedFlightTime {
    final total = _totalFlightMinutes;
    return FlightTime(
      total: total,
      night: 0,
      ifr: 0,
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
    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    // Check departure != destination
    if (_depController.text.toUpperCase() ==
        _destController.text.toUpperCase()) {
      setState(() {
        _errorMessage = 'Destination must differ from departure';
      });
      return false;
    }

    // Check at least one landing
    if (_dayLandings + _nightLandings < 1) {
      setState(() {
        _errorMessage = 'At least one landing is required';
      });
      return false;
    }

    // Check positive flight time
    if (_totalFlightMinutes <= 0) {
      setState(() {
        _errorMessage = 'Flight time must be positive';
      });
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
      setState(() {
        _errorMessage = 'No pilot profile found. Please complete registration.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Catch any unexpected errors (parsing, network, etc.)
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
          _isLoading = false;
        });
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
                    // Error message
                    if (_errorMessage != null) ...[
                      _ErrorBanner(message: _errorMessage!),
                      const SizedBox(height: 16),
                    ],

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
                                  'Flight Time: ',
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
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          NumberStepper(
                            label: 'Day Landings',
                            value: _dayLandings,
                            minValue: 0,
                            maxValue: 99,
                            onChanged: (value) {
                              setState(() {
                                _dayLandings = value;
                                _hasChanges = true;
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
                              });
                            },
                          ),
                        ],
                      ),
                    ),

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

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFEF4444),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
