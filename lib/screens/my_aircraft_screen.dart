import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_aircraft_type.dart';
import '../models/user_aircraft_registration.dart';
import '../services/aircraft_service.dart';
import '../session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';
import 'aircraft_type_search_screen.dart';

class MyAircraftScreen extends StatefulWidget {
  const MyAircraftScreen({super.key});

  @override
  State<MyAircraftScreen> createState() => _MyAircraftScreenState();
}

class _MyAircraftScreenState extends State<MyAircraftScreen> {
  final AircraftService _aircraftService = AircraftService();

  List<UserAircraftType> _types = [];
  List<UserAircraftRegistration> _registrations = [];
  bool _isLoadingTypes = true;
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
      return;
    }

    try {
      final regs = await _aircraftService.getUserAircraftRegistrations(userId);
      if (mounted) {
        setState(() {
          _registrations = regs;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load registrations';
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
                onPressed: _addAircraftType,
                icon: const Icon(Icons.add, color: AppColors.denimLight),
                iconSize: 24,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            ),
          ),
        ],
      ),
      body: _buildTypesTab(),
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
          final regCount = _registrations.where((r) => r.userAircraftTypeId == type.id).length;
          return _AircraftTypeCard(
            type: type,
            registrationCount: regCount,
            onTap: () => _openTypeDetail(type),
          );
        },
      ),
    );
  }

  Future<void> _openTypeDetail(UserAircraftType type) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AircraftTypeDetailScreen(
          aircraftType: type,
          registrations: _registrations.where((r) => r.userAircraftTypeId == type.id).toList(),
          allTypes: _types,
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
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
  final int registrationCount;
  final VoidCallback onTap;

  const _AircraftTypeCard({
    required this.type,
    required this.registrationCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Row(
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
              ],
            ),
            // Aircraft count badge in top right
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: registrationCount > 0
                      ? AppColors.denim.withValues(alpha: 0.2)
                      : AppColors.whiteDarker.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$registrationCount',
                  style: AppTypography.caption.copyWith(
                    color: registrationCount > 0
                        ? AppColors.denimLight
                        : AppColors.whiteDarker,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Chevron icon in bottom right
            Positioned(
              bottom: 0,
              right: 0,
              child: Icon(
                Icons.chevron_right,
                color: AppColors.whiteDarker,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags() {
    final tags = <String>[];

    // Flight rules tag
    switch (type.flightRules) {
      case FlightRulesCapability.vfr:
        tags.add('VFR');
        break;
      case FlightRulesCapability.ifr:
        tags.add('IFR');
        break;
      case FlightRulesCapability.both:
        tags.add('IFR/VFR');
        break;
    }

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
              Icons.flight,
              color: AppColors.denim,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Text(
              registration.registration,
              style: AppTypography.body.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
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
  late FlightRulesCapability _flightRules;
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
    _flightRules = widget.aircraftType.flightRules;
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
        flightRules: _flightRules,
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

            // Flight Rules section
            Text(
              'FLIGHT RULES',
              style: AppTypography.label,
            ),
            const SizedBox(height: 12),
            _FlightRulesSelector(
              value: _flightRules,
              onChanged: (value) => setState(() => _flightRules = value),
            ),
            const SizedBox(height: 8),
            Text(
              _flightRules == FlightRulesCapability.ifr
                  ? 'IFR time will auto-populate to total flight time'
                  : _flightRules == FlightRulesCapability.vfr
                      ? 'IFR field will be disabled when logging flights'
                      : 'IFR time can be entered manually',
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
// Aircraft Type Detail Screen
// ===========================================================================

class AircraftTypeDetailScreen extends StatefulWidget {
  final UserAircraftType aircraftType;
  final List<UserAircraftRegistration> registrations;
  final List<UserAircraftType> allTypes;

  const AircraftTypeDetailScreen({
    super.key,
    required this.aircraftType,
    required this.registrations,
    required this.allTypes,
  });

  @override
  State<AircraftTypeDetailScreen> createState() => _AircraftTypeDetailScreenState();
}

class _AircraftTypeDetailScreenState extends State<AircraftTypeDetailScreen> {
  final AircraftService _aircraftService = AircraftService();
  late UserAircraftType _aircraftType;
  late List<UserAircraftRegistration> _registrations;
  bool _hasChanges = false;

  String? get _userId {
    return Provider.of<SessionState>(context, listen: false).userId;
  }

  @override
  void initState() {
    super.initState();
    _aircraftType = widget.aircraftType;
    _registrations = List.from(widget.registrations);
  }

  Future<void> _editType() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditAircraftTypeScreen(aircraftType: _aircraftType),
      ),
    );

    if (result == true) {
      _hasChanges = true;
      // Reload the type data
      final userId = _userId;
      if (userId != null) {
        try {
          final types = await _aircraftService.getUserAircraftTypes(userId);
          final updatedType = types.firstWhere(
            (t) => t.id == _aircraftType.id,
            orElse: () => _aircraftType,
          );
          if (mounted) {
            setState(() => _aircraftType = updatedType);
          }
        } catch (_) {}
      }
    }
  }

  Future<void> _deleteType() async {
    final hasRegs = _registrations.isNotEmpty;

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
              'Are you sure you want to delete "${_aircraftType.displayName}"?',
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
                        'This will also delete ${_registrations.length} registration${_registrations.length > 1 ? 's' : ''} linked to this type',
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
      await _aircraftService.deleteUserAircraftType(userId, _aircraftType.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${_aircraftType.displayName}"'),
            backgroundColor: AppColors.nightRiderLight,
          ),
        );
        Navigator.pop(context, true);
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
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddRegistrationScreen(
          availableTypes: widget.allTypes,
          preSelectedType: _aircraftType,
        ),
      ),
    );

    if (result == true) {
      _hasChanges = true;
      // Reload registrations
      final userId = _userId;
      if (userId != null) {
        try {
          final regs = await _aircraftService.getUserAircraftRegistrations(userId);
          final filteredRegs = regs.where((r) => r.userAircraftTypeId == _aircraftType.id).toList();
          if (mounted) {
            setState(() => _registrations = filteredRegs);
          }
        } catch (_) {}
      }
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
      _hasChanges = true;
      if (mounted) {
        setState(() {
          _registrations.removeWhere((r) => r.id == reg.id);
        });
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.pop(context, _hasChanges);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.nightRider,
        appBar: AppBar(
          backgroundColor: AppColors.nightRider,
          elevation: 0,
          title: Text(_aircraftType.displayName, style: AppTypography.h3),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _hasChanges),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.errorRed),
              onPressed: _deleteType,
              tooltip: 'Delete type',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addRegistration,
          backgroundColor: AppColors.denim,
          child: const Icon(Icons.add, color: AppColors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type header card
              SizedBox(
                width: double.infinity,
                child: GlassContainer(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _aircraftType.icaoDesignator,
                              style: AppTypography.h2(context),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_aircraftType.manufacturer} ${_aircraftType.model}',
                              style: AppTypography.body.copyWith(color: AppColors.whiteDark),
                            ),
                            if (_aircraftType.variant != null && _aircraftType.variant!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                _aircraftType.variant!,
                                style: AppTypography.bodySmall.copyWith(color: AppColors.whiteDarker),
                              ),
                            ],
                            const SizedBox(height: 12),
                            _buildPropertyTags(),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.denim, size: 20),
                        onPressed: _editType,
                        tooltip: 'Edit properties',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Registrations section header
              Text(
                'AIRCRAFT (${_registrations.length})',
                style: AppTypography.label,
              ),
              const SizedBox(height: 12),

              // Registrations list
              if (_registrations.isEmpty)
                _buildEmptyRegistrations()
              else
                ..._registrations.map((reg) => _RegistrationCard(
                  registration: reg,
                  onDelete: () => _deleteRegistration(reg),
                )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyTags() {
    final tags = <String>[];
    if (_aircraftType.multiEngine) tags.add('Multi-Engine');
    if (_aircraftType.multiPilot) tags.add('Multi-Pilot');
    if (_aircraftType.complex) tags.add('Complex');
    if (_aircraftType.highPerformance) tags.add('High Perf');

    if (tags.isEmpty) {
      return Text(
        'Single-engine, single-pilot',
        style: AppTypography.caption.copyWith(color: AppColors.whiteDarker),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.denim.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            tag,
            style: AppTypography.caption.copyWith(
              color: AppColors.denimLight,
              fontSize: 11,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyRegistrations() {
    return GlassContainer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight,
              color: AppColors.whiteDarker,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No aircraft registered',
              style: AppTypography.body.copyWith(color: AppColors.whiteDark),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to add a registration',
              style: AppTypography.caption.copyWith(color: AppColors.whiteDarker),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Add Registration Screen
// ===========================================================================

class AddRegistrationScreen extends StatefulWidget {
  final List<UserAircraftType> availableTypes;
  final UserAircraftType? preSelectedType;

  const AddRegistrationScreen({
    super.key,
    required this.availableTypes,
    this.preSelectedType,
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

  bool get _isPreSelected => widget.preSelectedType != null;

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedType != null) {
      _selectedType = widget.preSelectedType;
    } else if (widget.availableTypes.isNotEmpty) {
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
            if (_isPreSelected)
              // Show read-only type when pre-selected
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.denim.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.flight,
                        color: AppColors.denim,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedType!.fullDisplayName,
                            style: AppTypography.body.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedType!.icaoDesignator,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.whiteDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              // Show dropdown when not pre-selected
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
              _isPreSelected
                  ? 'Adding registration to this aircraft type.'
                  : 'The registration will inherit properties from this aircraft type.',
              style: AppTypography.caption.copyWith(color: AppColors.whiteDarker),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Flight Rules Selector Widget
// ===========================================================================

class _FlightRulesSelector extends StatelessWidget {
  final FlightRulesCapability value;
  final ValueChanged<FlightRulesCapability> onChanged;

  const _FlightRulesSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FlightRulesButton(
            label: 'VFR',
            isSelected: value == FlightRulesCapability.vfr,
            onTap: () => onChanged(FlightRulesCapability.vfr),
            isFirst: true,
          ),
        ),
        Expanded(
          child: _FlightRulesButton(
            label: 'IFR',
            isSelected: value == FlightRulesCapability.ifr,
            onTap: () => onChanged(FlightRulesCapability.ifr),
          ),
        ),
        Expanded(
          child: _FlightRulesButton(
            label: 'Both',
            isSelected: value == FlightRulesCapability.both,
            onTap: () => onChanged(FlightRulesCapability.both),
            isLast: true,
          ),
        ),
      ],
    );
  }
}

class _FlightRulesButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _FlightRulesButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.denim : AppColors.nightRiderDark,
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(12) : Radius.zero,
            right: isLast ? const Radius.circular(12) : Radius.zero,
          ),
          border: Border.all(
            color: isSelected ? AppColors.denim : AppColors.borderSubtle,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.button.copyWith(
            color: isSelected ? AppColors.white : AppColors.whiteDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
