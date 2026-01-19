import 'package:flutter/material.dart';
import '../../constants/role_standards.dart';
import '../../models/saved_pilot.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'pilot_search_modal.dart';
import 'role_dropdown.dart';

/// Data class for crew member input
class CrewEntry {
  String name;
  String role;

  CrewEntry({this.name = '', String? role})
      : role = role ?? TimeFieldCodes.sic; // Default to SIC for crew members

  bool get isValid => name.trim().isNotEmpty && role.isNotEmpty;
}

/// Card widget for entering a crew member (name + role)
/// Tapping the name field opens a full-screen modal for pilot selection
class CrewEntryCard extends StatefulWidget {
  final CrewEntry entry;
  final List<SavedPilot> suggestions;
  final VoidCallback onRemove;
  final ValueChanged<CrewEntry>? onChanged;
  final bool canRemove;

  const CrewEntryCard({
    super.key,
    required this.entry,
    required this.suggestions,
    required this.onRemove,
    this.onChanged,
    this.canRemove = true,
  });

  @override
  State<CrewEntryCard> createState() => _CrewEntryCardState();
}

class _CrewEntryCardState extends State<CrewEntryCard> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CrewEntryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller if entry name changed externally
    if (widget.entry.name != _nameController.text) {
      _nameController.text = widget.entry.name;
    }
  }

  void _onRoleChanged(String? value) {
    if (value != null) {
      widget.entry.role = value;
      widget.onChanged?.call(widget.entry);
    }
  }

  Future<void> _openPilotSearch() async {
    final result = await PilotSearchModal.show(
      context,
      title: 'Select Pilot',
      savedPilots: widget.suggestions,
      initialValue: widget.entry.name,
    );

    if (result == null) return;

    setState(() {
      widget.entry.name = result.name;
      _nameController.text = result.name;
    });
    widget.onChanged?.call(widget.entry);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassDark50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderVisible),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with remove button
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppColors.denim,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Crew Member',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.whiteDarker,
                ),
              ),
              const Spacer(),
              if (widget.canRemove)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppColors.errorRed,
                    size: 20,
                  ),
                  onPressed: widget.onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Remove crew member',
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Name field - tappable to open modal
          GestureDetector(
            onTap: _openPilotSearch,
            child: AbsorbPointer(
              child: TextFormField(
                controller: _nameController,
                readOnly: true,
                style: AppTypography.body.copyWith(color: AppColors.white),
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Tap to select pilot',
                  prefixIcon: Icon(
                    Icons.badge,
                    color: AppColors.whiteDarker,
                    size: 20,
                  ),
                  suffixIcon: Icon(
                    Icons.search,
                    color: AppColors.whiteDarker,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Role dropdown
          RoleDropdown(
            value: widget.entry.role,
            onChanged: _onRoleChanged,
            label: 'Role',
          ),
        ],
      ),
    );
  }
}
