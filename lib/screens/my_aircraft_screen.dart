import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/aircraft_type.dart';
import '../models/user_aircraft_type.dart';
import '../models/user_aircraft_registration.dart';
import '../services/aircraft_service.dart';
import '../session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';
import '../widgets/glass_card.dart';
import 'aircraft_type_search_screen.dart';

/// View options for the aircraft screen
enum _AircraftView { types, registrations }

class MyAircraftScreen extends StatefulWidget {
  const MyAircraftScreen({super.key});

  @override
  State<MyAircraftScreen> createState() => _MyAircraftScreenState();
}

class _MyAircraftScreenState extends State<MyAircraftScreen> {
  final AircraftService _aircraftService = AircraftService();
  _AircraftView _selectedView = _AircraftView.types;

  List<UserAircraftType> _types = [];
  List<UserAircraftRegistration> _registrations = [];
  bool _isLoadingTypes = true;
  bool _isLoadingRegs = true;
  String? _errorMessage;

  String? get _userId {
    return Provider.of<SessionState>(context, listen: false).userId;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadTypes(), _loadRegistrations()]);
  }

  Future<void> _loadTypes() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      setState(() {
        _errorMessage = 'No pilot profile found';
        _isLoadingTypes = false;
      });
      return;
    }

    try {
      final types = await _aircraftService.getUserAircraftTypes(userId);
      if (mounted) {
        setState(() {
          _types = types;
          _isLoadingTypes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load aircraft types';
          _isLoadingTypes = false;
        });
      }
    }
  }

  Future<void> _loadRegistrations() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      setState(() {
        _isLoadingRegs = false;
      });
      return;
    }

    try {
      final regs = await _aircraftService.getUserAircraftRegistrations(userId);
      if (mounted) {
        setState(() {
          _registrations = regs;
          _isLoadingRegs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load registrations';
          _isLoadingRegs = false;
        });
      }
    }
  }

  Future<void> _addAircraftType() async {
    final result = await AircraftTypeSearchScreen.show(context);

    if (result == null) return;

    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    try {
      await _aircraftService.addUserAircraftType(userId, result.id);
      _loadTypes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${result.displayName}'),
            backgroundColor: AppColors.endorsedGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _editAircraftType(UserAircraftType type) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditAircraftTypeScreen(aircraftType: type),
      ),
    );

    if (result == true) {
      _loadTypes();
    }
  }

  Future<void> _deleteAircraftType(UserAircraftType type) async {
    final hasRegs = _registrations.any((r) => r.userAircraftTypeId == type.id);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text(
          'Delete Aircraft Type?',
          style: AppTypography.h4.copyWith(color: AppColors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${type.displayName}"?',
              style: AppTypography.body.copyWith(color: AppColors.whiteDark),
            ),
            if (hasRegs) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.errorRed.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: AppColors.errorRed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will also delete all registrations linked to this type',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.errorRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
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
              style: AppTypography.button.copyWith(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    try {
      await _aircraftService.deleteUserAircraftType(userId, type.id);
      _loadTypes();
      _loadRegistrations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${type.displayName}"'),
            backgroundColor: AppColors.nightRiderLight,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _addRegistration() async {
    if (_types.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add an aircraft type first'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddRegistrationScreen(availableTypes: _types),
      ),
    );

    if (result == true) {
      _loadRegistrations();
    }
  }

  Future<void> _deleteRegistration(UserAircraftRegistration reg) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text(
          'Delete Registration?',
          style: AppTypography.h4.copyWith(color: AppColors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${reg.registration}"?',
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
              style: AppTypography.button.copyWith(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    try {
      await _aircraftService.deleteUserAircraftRegistration(userId, reg.id);
      _loadRegistrations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${reg.registration}"'),
            backgroundColor: AppColors.nightRiderLight,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightRider,
      appBar: AppBar(
        backgroundColor: AppColors.nightRider,
        elevation: 0,
        title: Text('My Aircrafts', style: AppTypography.h3),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GlassContainer(
              borderRadius: 22,
              padding: EdgeInsets.zero,
              borderColor: AppColors.denim.withValues(alpha: 0.3),
              child: IconButton(
                onPressed: () {
                  if (_selectedView == _AircraftView.types) {
                    _addAircraftType();
                  } else {
                    _addRegistration();
                  }
                },
                icon: const Icon(Icons.add, color: AppColors.denimLight),
                iconSize: 24,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              children: [
                Expanded(
                  child: TabButton(
                    label: 'Types',
                    isActive: _selectedView == _AircraftView.types,
                    onPressed: () => setState(() => _selectedView = _AircraftView.types),
                    expand: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TabButton(
                    label: 'Registrations',
                    isActive: _selectedView == _AircraftView.registrations,
                    onPressed: () => setState(() => _selectedView = _AircraftView.registrations),
                    expand: true,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _selectedView == _AircraftView.types
                ? _buildTypesTab()
                : _buildRegistrationsTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypesTab() {
    if (_isLoadingTypes) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.denim),
      );
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_types.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight,
              color: AppColors.whiteDarker,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No aircraft types yet',
              style: AppTypography.h4.copyWith(color: AppColors.whiteDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add from the global database',
              style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTypes,
      color: AppColors.denim,
      backgroundColor: AppColors.nightRiderDark,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _types.length,
        itemBuilder: (context, index) {
          final type = _types[index];
          return _AircraftTypeCard(
            type: type,
            onEdit: () => _editAircraftType(type),
            onDelete: () => _deleteAircraftType(type),
          );
        },
      ),
    );
  }

  Widget _buildRegistrationsTab() {
    if (_isLoadingRegs) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.denim),
      );
    }

    if (_registrations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              color: AppColors.whiteDarker,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No registrations yet',
              style: AppTypography.h4.copyWith(color: AppColors.whiteDark),
            ),
            const SizedBox(height: 8),
            Text(
              _types.isEmpty
                  ? 'Add an aircraft type first,\nthen add registrations'
                  : 'Tap + to add a registration',
              style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRegistrations,
      color: AppColors.denim,
      backgroundColor: AppColors.nightRiderDark,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _registrations.length,
        itemBuilder: (context, index) {
          final reg = _registrations[index];
          return _RegistrationCard(
            registration: reg,
            onDelete: () => _deleteRegistration(reg),
          );
        },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.errorRed,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _loadData,
            child: Text(
              'Retry',
              style: AppTypography.button.copyWith(color: AppColors.denim),
            ),
          ),
        ],
      ),
    );
  }
}

class _AircraftTypeCard extends StatelessWidget {
  final UserAircraftType type;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AircraftTypeCard({
    required this.type,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.denim.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.flight,
              color: AppColors.denim,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Manufacturer + Model
                Text(
                  '${type.manufacturer} ${type.model}',
                  style: AppTypography.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                // ICAO - Variant (or just ICAO if no variant)
                Text(
                  type.variant != null && type.variant!.isNotEmpty
                      ? '${type.icaoDesignator} - ${type.variant}'
                      : type.icaoDesignator,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.whiteDark,
                  ),
                ),
                const SizedBox(height: 4),
                _buildTags(),
              ],
            ),
          ),

          // Edit button
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.denim, size: 20),
            onPressed: onEdit,
            tooltip: 'Edit properties',
          ),

          // Delete button
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.errorRed, size: 20),
            onPressed: onDelete,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    final tags = <String>[];
    if (type.multiEngine) tags.add('Multi-Engine');
    if (type.multiPilot) tags.add('Multi-Pilot');
    if (type.complex) tags.add('Complex');

    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.denim.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            tag,
            style: AppTypography.caption.copyWith(
              color: AppColors.denimLight,
              fontSize: 10,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final UserAircraftRegistration registration;
  final VoidCallback onDelete;

  const _RegistrationCard({
    required this.registration,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.denim.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: AppColors.denimLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registration.registration,
                  style: AppTypography.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  registration.aircraftTypeDisplay,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.whiteDark,
                  ),
                ),
              ],
            ),
          ),

          // Delete button
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.errorRed, size: 20),
            onPressed: onDelete,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Edit Aircraft Type Screen
// ===========================================================================

class EditAircraftTypeScreen extends StatefulWidget {
  final UserAircraftType aircraftType;

  const EditAircraftTypeScreen({
    super.key,
    required this.aircraftType,
  });

  @override
  State<EditAircraftTypeScreen> createState() => _EditAircraftTypeScreenState();
}

class _EditAircraftTypeScreenState extends State<EditAircraftTypeScreen> {
  final AircraftService _aircraftService = AircraftService();
  final TextEditingController _variantController = TextEditingController();
  late bool _multiEngine;
  late bool _multiPilot;
  late bool _complex;
  late bool _highPerformance;
  bool _isSaving = false;

  String? get _userId {
    return Provider.of<SessionState>(context, listen: false).userId;
  }

  @override
  void initState() {
    super.initState();
    _multiEngine = widget.aircraftType.multiEngine;
    _multiPilot = widget.aircraftType.multiPilot;
    _complex = widget.aircraftType.complex;
    _highPerformance = widget.aircraftType.highPerformance;
    _variantController.text = widget.aircraftType.variant ?? '';
  }

  @override
  void dispose() {
    _variantController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final variant = _variantController.text.trim();
      await _aircraftService.updateUserAircraftType(
        userId,
        widget.aircraftType.id,
        multiEngine: _multiEngine,
        multiPilot: _multiPilot,
        complex: _complex,
        highPerformance: _highPerformance,
        variant: variant.isEmpty ? null : variant,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightRider,
      appBar: AppBar(
        backgroundColor: AppColors.nightRider,
        elevation: 0,
        title: Text('Edit Aircraft Type', style: AppTypography.h3),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.denim,
                    ),
                  )
                : Text(
                    'Save',
                    style: AppTypography.button.copyWith(color: AppColors.denim),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aircraft info header
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.aircraftType.icaoDesignator,
                    style: AppTypography.h2(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.aircraftType.manufacturer} ${widget.aircraftType.model}',
                    style: AppTypography.body.copyWith(color: AppColors.whiteDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Variant (e.g., DR400/160 Chevalier)
            Text(
              'VARIANT (OPTIONAL)',
              style: AppTypography.label,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _variantController,
              style: AppTypography.body.copyWith(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'e.g. DR400/160 Chevalier',
                hintStyle: AppTypography.body.copyWith(color: AppColors.whiteDarker),
                filled: true,
                fillColor: AppColors.nightRiderDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.denim),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Specify the exact variant for your logbook (e.g., different horsepower versions)',
              style: AppTypography.caption.copyWith(color: AppColors.whiteDarker),
            ),
            const SizedBox(height: 24),

            // Properties
            Text(
              'PROPERTIES',
              style: AppTypography.label,
            ),
            const SizedBox(height: 12),
            GlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSwitch(
                    'Multi-Engine',
                    'Aircraft has multiple engines',
                    _multiEngine,
                    (v) => setState(() => _multiEngine = v),
                  ),
                  _buildDivider(),
                  _buildSwitch(
                    'Multi-Pilot',
                    'Requires 2 crew members',
                    _multiPilot,
                    (v) => setState(() => _multiPilot = v),
                  ),
                  _buildDivider(),
                  _buildSwitch(
                    'Complex',
                    'Retractable gear + controllable pitch + flaps',
                    _complex,
                    (v) => setState(() => _complex = v),
                  ),
                  _buildDivider(),
                  _buildSwitch(
                    'High Performance',
                    '>200hp (FAA definition)',
                    _highPerformance,
                    (v) => setState(() => _highPerformance = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'These properties affect how flight time is logged.',
              style: AppTypography.caption.copyWith(color: AppColors.whiteDarker),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(color: AppColors.whiteDarker),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.denim,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: AppColors.borderSubtle,
      indent: 16,
      endIndent: 16,
    );
  }
}

// ===========================================================================
// Add Registration Screen
// ===========================================================================

class AddRegistrationScreen extends StatefulWidget {
  final List<UserAircraftType> availableTypes;

  const AddRegistrationScreen({
    super.key,
    required this.availableTypes,
  });

  @override
  State<AddRegistrationScreen> createState() => _AddRegistrationScreenState();
}

class _AddRegistrationScreenState extends State<AddRegistrationScreen> {
  final AircraftService _aircraftService = AircraftService();
  final TextEditingController _regController = TextEditingController();
  UserAircraftType? _selectedType;
  bool _isSaving = false;
  String? _error;

  String? get _userId {
    return Provider.of<SessionState>(context, listen: false).userId;
  }

  @override
  void initState() {
    super.initState();
    if (widget.availableTypes.isNotEmpty) {
      _selectedType = widget.availableTypes.first;
    }
  }

  @override
  void dispose() {
    _regController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    final reg = _regController.text.trim().toUpperCase();
    if (reg.isEmpty) {
      setState(() => _error = 'Registration is required');
      return;
    }

    if (_selectedType == null) {
      setState(() => _error = 'Select an aircraft type');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await _aircraftService.addUserAircraftRegistration(
        userId,
        reg,
        _selectedType!.id,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightRider,
      appBar: AppBar(
        backgroundColor: AppColors.nightRider,
        elevation: 0,
        title: Text('Add Registration', style: AppTypography.h3),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.denim,
                    ),
                  )
                : Text(
                    'Save',
                    style: AppTypography.button.copyWith(color: AppColors.denim),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.errorRed.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.errorRed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.errorRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Text(
              'REGISTRATION',
              style: AppTypography.label,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _regController,
              textCapitalization: TextCapitalization.characters,
              style: AppTypography.body.copyWith(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'e.g. F-GZTP, N12345',
                hintStyle: AppTypography.body.copyWith(color: AppColors.whiteDarker),
                filled: true,
                fillColor: AppColors.nightRiderDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.denim),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'AIRCRAFT TYPE',
              style: AppTypography.label,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<UserAircraftType>(
              value: _selectedType,
              dropdownColor: AppColors.nightRiderDark,
              style: AppTypography.body.copyWith(color: AppColors.white),
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.whiteDarker),
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                filled: true,
                fillColor: AppColors.nightRiderDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.denim),
                ),
              ),
              items: widget.availableTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type.fullDisplayName,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: 16),
            Text(
              'The registration will inherit properties from this aircraft type.',
              style: AppTypography.caption.copyWith(color: AppColors.whiteDarker),
            ),
          ],
        ),
      ),
    );
  }
}
