import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/saved_pilot.dart';
import '../services/pilot_service.dart';
import '../session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';

class SavedPilotsScreen extends StatefulWidget {
  const SavedPilotsScreen({super.key});

  @override
  State<SavedPilotsScreen> createState() => _SavedPilotsScreenState();
}

class _SavedPilotsScreenState extends State<SavedPilotsScreen> {
  final PilotService _pilotService = PilotService();

  List<SavedPilot> _pilots = [];
  bool _isLoading = true;
  String? _errorMessage;

  String? get _pilotLicense {
    return Provider.of<SessionState>(context, listen: false).pilotLicense;
  }

  @override
  void initState() {
    super.initState();
    _loadPilots();
  }

  Future<void> _loadPilots() async {
    final license = _pilotLicense;
    if (license == null) {
      setState(() {
        _errorMessage = 'No pilot profile found';
        _isLoading = false;
      });
      return;
    }

    try {
      final pilots = await _pilotService.getSavedPilots(license);
      if (mounted) {
        setState(() {
          _pilots = pilots;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load pilots';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addPilot() async {
    final name = await _showNameDialog(title: 'Add Pilot');
    if (name == null || name.trim().isEmpty) return;

    final license = _pilotLicense;
    if (license == null) return;

    try {
      await _pilotService.createSavedPilot(license, name.trim());
      _loadPilots();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add pilot: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _editPilot(SavedPilot pilot) async {
    final newName = await _showNameDialog(
      title: 'Edit Pilot',
      initialValue: pilot.name,
    );
    if (newName == null || newName.trim().isEmpty || newName.trim() == pilot.name) {
      return;
    }

    final license = _pilotLicense;
    if (license == null) return;

    try {
      final updatedCount = await _pilotService.updateSavedPilotName(
        license,
        pilot.name,
        newName.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated $updatedCount flight${updatedCount == 1 ? '' : 's'}'),
            backgroundColor: AppColors.endorsedGreen,
          ),
        );
      }
      _loadPilots();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _deletePilot(SavedPilot pilot) async {
    final license = _pilotLicense;
    if (license == null) return;

    // Get flight count for confirmation
    final flightCount = await _pilotService.getFlightCountForPilot(
      license,
      pilot.name,
    );

    if (!mounted) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text(
          'Delete Pilot?',
          style: AppTypography.h4.copyWith(color: AppColors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${pilot.name}"?',
              style: AppTypography.body.copyWith(color: AppColors.whiteDark),
            ),
            if (flightCount > 0) ...[
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
                        'This will remove them from $flightCount flight${flightCount == 1 ? '' : 's'}',
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

    try {
      await _pilotService.deleteSavedPilot(license, pilot.name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${pilot.name}"'),
            backgroundColor: AppColors.nightRiderLight,
          ),
        );
      }
      _loadPilots();
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

  Future<String?> _showNameDialog({
    required String title,
    String? initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text(
          title,
          style: AppTypography.h4.copyWith(color: AppColors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: AppTypography.body.copyWith(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'Enter pilot name',
            hintStyle: AppTypography.body.copyWith(color: AppColors.whiteDarker),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderVisible),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.denim),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.button.copyWith(color: AppColors.whiteDarker),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(
              'Save',
              style: AppTypography.button.copyWith(color: AppColors.denim),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightRider,
      appBar: AppBar(
        backgroundColor: AppColors.nightRider,
        elevation: 0,
        title: Text('My Pilots', style: AppTypography.h3),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPilot,
        backgroundColor: AppColors.denim,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.denim),
      );
    }

    if (_errorMessage != null) {
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
              onPressed: _loadPilots,
              child: Text(
                'Retry',
                style: AppTypography.button.copyWith(color: AppColors.denim),
              ),
            ),
          ],
        ),
      );
    }

    if (_pilots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              color: AppColors.whiteDarker,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No pilots yet',
              style: AppTypography.h4.copyWith(color: AppColors.whiteDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a pilot, or they\'ll appear\nwhen you add them to flights',
              style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPilots,
      color: AppColors.denim,
      backgroundColor: AppColors.nightRiderDark,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pilots.length,
        itemBuilder: (context, index) {
          final pilot = _pilots[index];
          return _PilotCard(
            pilot: pilot,
            onEdit: () => _editPilot(pilot),
            onDelete: () => _deletePilot(pilot),
          );
        },
      ),
    );
  }
}

class _PilotCard extends StatelessWidget {
  final SavedPilot pilot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PilotCard({
    required this.pilot,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: AppColors.denim.withValues(alpha: 0.2),
            radius: 24,
            child: Text(
              pilot.name.isNotEmpty ? pilot.name[0].toUpperCase() : '?',
              style: AppTypography.h4.copyWith(color: AppColors.denim),
            ),
          ),
          const SizedBox(width: 16),

          // Name and flight count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pilot.name,
                  style: AppTypography.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pilot.flightCount > 0
                      ? '${pilot.flightCount} flight${pilot.flightCount == 1 ? '' : 's'}'
                      : 'No flights yet',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.whiteDarker,
                  ),
                ),
              ],
            ),
          ),

          // Edit button
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.denim, size: 20),
            onPressed: onEdit,
            tooltip: 'Edit',
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
