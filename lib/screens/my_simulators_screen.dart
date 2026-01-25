import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_simulator.dart';
import '../models/aircraft_type.dart';
import '../services/simulator_service.dart';
import '../session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';
import 'aircraft_type_search_screen.dart';

class MySimulatorsScreen extends StatefulWidget {
  const MySimulatorsScreen({super.key});

  @override
  State<MySimulatorsScreen> createState() => _MySimulatorsScreenState();
}

class _MySimulatorsScreenState extends State<MySimulatorsScreen> {
  final SimulatorService _simulatorService = SimulatorService();

  List<UserSimulatorType> _types = [];
  List<UserSimulatorRegistration> _registrations = [];
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
      final types = await _simulatorService.getUserSimulatorTypes(userId);
      if (mounted) {
        setState(() {
          _types = types;
          _isLoadingTypes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load simulator types';
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
      final regs = await _simulatorService.getUserSimulatorRegistrations(userId);
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

  Future<void> _addSimulatorType() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddSimulatorTypeScreen(),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightRider,
      appBar: AppBar(
        backgroundColor: AppColors.nightRider,
        elevation: 0,
        title: Text('My Simulators', style: AppTypography.h3),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GlassContainer(
              borderRadius: 22,
              padding: EdgeInsets.zero,
              borderColor: AppColors.denim.withValues(alpha: 0.3),
              child: IconButton(
                onPressed: _addSimulatorType,
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
              Icons.desktop_windows_outlined,
              color: AppColors.whiteDarker,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No simulator types yet',
              style: AppTypography.h4.copyWith(color: AppColors.whiteDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a simulator type',
              style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.denim,
      backgroundColor: AppColors.nightRiderDark,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _types.length,
        itemBuilder: (context, index) {
          final type = _types[index];
          final regCount = type.registrationCount ??
              _registrations.where((r) => r.userSimulatorTypeId == type.id).length;
          return _SimulatorTypeCard(
            type: type,
            registrationCount: regCount,
            onTap: () => _openTypeDetail(type),
          );
        },
      ),
    );
  }

  Future<void> _openTypeDetail(UserSimulatorType type) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SimulatorTypeDetailScreen(
          simulatorType: type,
          registrations: _registrations.where((r) => r.userSimulatorTypeId == type.id).toList(),
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

class _SimulatorTypeCard extends StatelessWidget {
  final UserSimulatorType type;
  final int registrationCount;
  final VoidCallback onTap;

  const _SimulatorTypeCard({
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
                    Icons.desktop_windows_outlined,
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
                      // Category + Level + ICAO
                      Text(
                        type.displayName,
                        style: AppTypography.body.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Aircraft type name
                      Text(
                        type.aircraftTypeDisplay,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.whiteDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildTag(),
                    ],
                  ),
                ),
              ],
            ),
            // Registration count badge in top right
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

  Widget _buildTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.denim.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.fstdCategory.fullName,
        style: AppTypography.caption.copyWith(
          color: AppColors.denimLight,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final UserSimulatorRegistration registration;
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
              Icons.desktop_windows_outlined,
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
                Text(
                  registration.registration,
                  style: AppTypography.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (registration.trainingFacility != null &&
                    registration.trainingFacility!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '@ ${registration.trainingFacility}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.whiteDarker,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
// Simulator Type Detail Screen
// ===========================================================================

class SimulatorTypeDetailScreen extends StatefulWidget {
  final UserSimulatorType simulatorType;
  final List<UserSimulatorRegistration> registrations;
  final List<UserSimulatorType> allTypes;

  const SimulatorTypeDetailScreen({
    super.key,
    required this.simulatorType,
    required this.registrations,
    required this.allTypes,
  });

  @override
  State<SimulatorTypeDetailScreen> createState() => _SimulatorTypeDetailScreenState();
}

class _SimulatorTypeDetailScreenState extends State<SimulatorTypeDetailScreen> {
  final SimulatorService _simulatorService = SimulatorService();
  late UserSimulatorType _simulatorType;
  late List<UserSimulatorRegistration> _registrations;
  bool _hasChanges = false;

  String? get _userId {
    return Provider.of<SessionState>(context, listen: false).userId;
  }

  @override
  void initState() {
    super.initState();
    _simulatorType = widget.simulatorType;
    _registrations = List.from(widget.registrations);
  }

  Future<void> _editType() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditSimulatorTypeScreen(simulatorType: _simulatorType),
      ),
    );

    if (result == true) {
      _hasChanges = true;
      // Reload the type data
      final userId = _userId;
      if (userId != null) {
        try {
          final types = await _simulatorService.getUserSimulatorTypes(userId);
          final updatedType = types.firstWhere(
            (t) => t.id == _simulatorType.id,
            orElse: () => _simulatorType,
          );
          if (mounted) {
            setState(() => _simulatorType = updatedType);
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
          'Delete Simulator Type?',
          style: AppTypography.h4.copyWith(color: AppColors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${_simulatorType.displayName}"?',
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
                        'This will also delete ${_registrations.length} simulator${_registrations.length > 1 ? 's' : ''} linked to this type',
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
      await _simulatorService.deleteUserSimulatorType(userId, _simulatorType.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${_simulatorType.displayName}"'),
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
        builder: (_) => AddSimulatorRegistrationScreen(
          availableTypes: widget.allTypes,
          preSelectedType: _simulatorType,
        ),
      ),
    );

    if (result == true) {
      _hasChanges = true;
      // Reload registrations
      final userId = _userId;
      if (userId != null) {
        try {
          final regs = await _simulatorService.getUserSimulatorRegistrations(userId);
          final filteredRegs = regs.where((r) => r.userSimulatorTypeId == _simulatorType.id).toList();
          if (mounted) {
            setState(() => _registrations = filteredRegs);
          }
        } catch (_) {}
      }
    }
  }

  Future<void> _deleteRegistration(UserSimulatorRegistration reg) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text(
          'Delete Simulator?',
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
      await _simulatorService.deleteUserSimulatorRegistration(userId, reg.id);
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
          title: Text(_simulatorType.displayName, style: AppTypography.h3),
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
                              _simulatorType.categoryLevelDisplay,
                              style: AppTypography.h2(context),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _simulatorType.aircraftTypeDisplay,
                              style: AppTypography.body.copyWith(color: AppColors.whiteDark),
                            ),
                            if (_simulatorType.icaoDesignator.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                _simulatorType.icaoDesignator,
                                style: AppTypography.bodySmall.copyWith(color: AppColors.whiteDarker),
                              ),
                            ],
                            const SizedBox(height: 12),
                            _buildPropertyTag(),
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
                'SIMULATORS (${_registrations.length})',
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

  Widget _buildPropertyTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.denim.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _simulatorType.fstdCategory.fullName,
        style: AppTypography.caption.copyWith(
          color: AppColors.denimLight,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildEmptyRegistrations() {
    return GlassContainer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.desktop_windows_outlined,
              color: AppColors.whiteDarker,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No simulators registered',
              style: AppTypography.body.copyWith(color: AppColors.whiteDark),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to add a simulator',
              style: AppTypography.caption.copyWith(color: AppColors.whiteDarker),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Add Simulator Type Screen
// ===========================================================================

class AddSimulatorTypeScreen extends StatefulWidget {
  const AddSimulatorTypeScreen({super.key});

  @override
  State<AddSimulatorTypeScreen> createState() => _AddSimulatorTypeScreenState();
}

class _AddSimulatorTypeScreenState extends State<AddSimulatorTypeScreen> {
  final SimulatorService _simulatorService = SimulatorService();
  final TextEditingController _notesController = TextEditingController();

  AircraftType? _selectedAircraftType;
  FstdCategory _selectedCategory = FstdCategory.ffs;
  String? _selectedLevel;
  bool _isSaving = false;
  String? _error;

  String? get _userId {
    return Provider.of<SessionState>(context, listen: false).userId;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectAircraftType() async {
    final result = await AircraftTypeSearchScreen.show(context);
    if (result != null) {
      setState(() => _selectedAircraftType = result);
    }
  }

  Future<void> _save() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    if (_selectedAircraftType == null) {
      setState(() => _error = 'Select an aircraft type');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await _simulatorService.addUserSimulatorType(
        userId,
        _selectedAircraftType!.id,
        _selectedCategory,
        fstdLevel: _selectedLevel,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
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
        title: Text('Add Simulator Type', style: AppTypography.h3),
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
              _buildErrorBanner(),
              const SizedBox(height: 16),
            ],

            // Aircraft Type
            Text(
              'AIRCRAFT TYPE',
              style: AppTypography.label,
            ),
            const SizedBox(height: 8),
            _buildAircraftTypeSelector(),
            const SizedBox(height: 8),
            Text(
              'Select the aircraft type this simulator represents',
              style: AppTypography.caption.copyWith(color: AppColors.whiteDarker),
            ),
            const SizedBox(height: 24),

            // FSTD Category
            Text(
              'FSTD CATEGORY',
              style: AppTypography.label,
            ),
            const SizedBox(height: 12),
            _FstdCategorySelector(
              value: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  // Reset level if not valid for new category
                  if (_selectedLevel != null &&
                      !value.validLevels.contains(_selectedLevel)) {
                    _selectedLevel = null;
                  }
                });
              },
            ),
            const SizedBox(height: 24),

            // FSTD Level (if applicable)
            if (_selectedCategory.hasLevels) ...[
              Text(
                'QUALIFICATION LEVEL',
                style: AppTypography.label,
              ),
              const SizedBox(height: 12),
              _FstdLevelSelector(
                category: _selectedCategory,
                value: _selectedLevel,
                onChanged: (value) => setState(() => _selectedLevel = value),
              ),
              const SizedBox(height: 24),
            ],

            // Notes
            Text(
              'NOTES (OPTIONAL)',
              style: AppTypography.label,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              style: AppTypography.body.copyWith(color: AppColors.white),
              maxLines: 3,
              decoration: _inputDecoration(hintText: 'Any additional notes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
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
    );
  }

  Widget _buildAircraftTypeSelector() {
    return GestureDetector(
      onTap: _selectAircraftType,
      child: GlassContainer(
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
              child: _selectedAircraftType != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_selectedAircraftType!.manufacturer} ${_selectedAircraftType!.model}',
                          style: AppTypography.body.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedAircraftType!.icaoDesignator,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.whiteDark,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Select aircraft type',
                      style: AppTypography.body.copyWith(
                        color: AppColors.whiteDarker,
                      ),
                    ),
            ),
            Icon(
              Icons.search,
              color: AppColors.whiteDarker,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
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
    );
  }
}

// ===========================================================================
// Edit Simulator Type Screen
// ===========================================================================

class EditSimulatorTypeScreen extends StatefulWidget {
  final UserSimulatorType simulatorType;

  const EditSimulatorTypeScreen({
    super.key,
    required this.simulatorType,
  });

  @override
  State<EditSimulatorTypeScreen> createState() => _EditSimulatorTypeScreenState();
}

class _EditSimulatorTypeScreenState extends State<EditSimulatorTypeScreen> {
  final SimulatorService _simulatorService = SimulatorService();
  final TextEditingController _notesController = TextEditingController();

  late FstdCategory _selectedCategory;
  String? _selectedLevel;
  bool _isSaving = false;

  String? get _userId {
    return Provider.of<SessionState>(context, listen: false).userId;
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.simulatorType.fstdCategory;
    _selectedLevel = widget.simulatorType.fstdLevel;
    _notesController.text = widget.simulatorType.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      await _simulatorService.updateUserSimulatorType(
        userId,
        widget.simulatorType.id,
        fstdCategory: _selectedCategory,
        fstdLevel: _selectedLevel,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
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
        title: Text('Edit Simulator Type', style: AppTypography.h3),
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
            // Aircraft info header (read-only)
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.simulatorType.icaoDesignator,
                    style: AppTypography.h2(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.simulatorType.aircraftTypeDisplay,
                    style: AppTypography.body.copyWith(color: AppColors.whiteDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // FSTD Category
            Text(
              'FSTD CATEGORY',
              style: AppTypography.label,
            ),
            const SizedBox(height: 12),
            _FstdCategorySelector(
              value: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  if (_selectedLevel != null &&
                      !value.validLevels.contains(_selectedLevel)) {
                    _selectedLevel = null;
                  }
                });
              },
            ),
            const SizedBox(height: 24),

            // FSTD Level (if applicable)
            if (_selectedCategory.hasLevels) ...[
              Text(
                'QUALIFICATION LEVEL',
                style: AppTypography.label,
              ),
              const SizedBox(height: 12),
              _FstdLevelSelector(
                category: _selectedCategory,
                value: _selectedLevel,
                onChanged: (value) => setState(() => _selectedLevel = value),
              ),
              const SizedBox(height: 24),
            ],

            // Notes
            Text(
              'NOTES (OPTIONAL)',
              style: AppTypography.label,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              style: AppTypography.body.copyWith(color: AppColors.white),
              maxLines: 3,
              decoration: _inputDecoration(hintText: 'Any additional notes'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
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
    );
  }
}

// ===========================================================================
// Add Simulator Registration Screen
// ===========================================================================

class AddSimulatorRegistrationScreen extends StatefulWidget {
  final List<UserSimulatorType> availableTypes;
  final UserSimulatorType? preSelectedType;

  const AddSimulatorRegistrationScreen({
    super.key,
    required this.availableTypes,
    this.preSelectedType,
  });

  @override
  State<AddSimulatorRegistrationScreen> createState() => _AddSimulatorRegistrationScreenState();
}

class _AddSimulatorRegistrationScreenState extends State<AddSimulatorRegistrationScreen> {
  final SimulatorService _simulatorService = SimulatorService();
  final TextEditingController _regController = TextEditingController();
  final TextEditingController _facilityController = TextEditingController();

  UserSimulatorType? _selectedType;
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
    _facilityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    final reg = _regController.text.trim().toUpperCase();
    if (reg.isEmpty) {
      setState(() => _error = 'Device ID is required');
      return;
    }

    if (_selectedType == null) {
      setState(() => _error = 'Select a simulator type');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await _simulatorService.addUserSimulatorRegistration(
        userId,
        _selectedType!.id,
        reg,
        trainingFacility: _facilityController.text.trim().isEmpty
            ? null
            : _facilityController.text.trim(),
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
        title: Text('Add Simulator', style: AppTypography.h3),
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
              'DEVICE ID',
              style: AppTypography.label,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _regController,
              textCapitalization: TextCapitalization.characters,
              style: AppTypography.body.copyWith(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'e.g. FR-123, D-SIM01',
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
              'TRAINING FACILITY (OPTIONAL)',
              style: AppTypography.label,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _facilityController,
              style: AppTypography.body.copyWith(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'e.g. CAE London Gatwick, Sim Aero CDG',
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
              'SIMULATOR TYPE',
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
                        Icons.desktop_windows_outlined,
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
                            _selectedType!.displayName,
                            style: AppTypography.body.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedType!.aircraftTypeDisplay,
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
              DropdownButtonFormField<UserSimulatorType>(
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
                      type.displayName,
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
                  ? 'Adding simulator to this type.'
                  : 'The simulator will be linked to this type.',
              style: AppTypography.caption.copyWith(color: AppColors.whiteDarker),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// FSTD Category Selector Widget
// ===========================================================================

class _FstdCategorySelector extends StatelessWidget {
  final FstdCategory value;
  final ValueChanged<FstdCategory> onChanged;

  const _FstdCategorySelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: FstdCategory.values.map((category) {
        final isFirst = category == FstdCategory.values.first;
        final isLast = category == FstdCategory.values.last;
        final isSelected = category == value;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(category),
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
                category.displayName,
                style: AppTypography.button.copyWith(
                  color: isSelected ? AppColors.white : AppColors.whiteDark,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ===========================================================================
// FSTD Level Selector Widget
// ===========================================================================

class _FstdLevelSelector extends StatelessWidget {
  final FstdCategory category;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _FstdLevelSelector({
    required this.category,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final levels = category.validLevels;
    if (levels.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: levels.map((level) {
        final isSelected = level == value;
        return GestureDetector(
          onTap: () => onChanged(isSelected ? null : level),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.denim : AppColors.nightRiderDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.denim : AppColors.borderSubtle,
                width: 1,
              ),
            ),
            child: Text(
              level,
              style: AppTypography.button.copyWith(
                color: isSelected ? AppColors.white : AppColors.whiteDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
