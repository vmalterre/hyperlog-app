import 'package:flutter/material.dart';
import '../../models/saved_pilot.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'role_dropdown.dart';

/// Data class for crew member input
class CrewEntry {
  String name;
  String role;

  CrewEntry({this.name = '', this.role = 'SIC'});

  bool get isValid => name.trim().isNotEmpty && role.isNotEmpty;
}

/// Card widget for entering a crew member (name + role)
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
  void _onRoleChanged(String? value) {
    if (value != null) {
      widget.entry.role = value;
      widget.onChanged?.call(widget.entry);
    }
  }

  void _selectSuggestion(SavedPilot pilot) {
    widget.entry.name = pilot.name;
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

          // Name field with autocomplete
          Autocomplete<SavedPilot>(
            initialValue: TextEditingValue(text: widget.entry.name),
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return widget.suggestions;
              }
              final query = textEditingValue.text.toLowerCase();
              return widget.suggestions.where(
                (pilot) => pilot.name.toLowerCase().contains(query),
              );
            },
            displayStringForOption: (pilot) => pilot.name,
            onSelected: _selectSuggestion,
            fieldViewBuilder: (
              context,
              controller,
              focusNode,
              onFieldSubmitted,
            ) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                style: AppTypography.body.copyWith(color: AppColors.white),
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter pilot name',
                  prefixIcon: Icon(
                    Icons.badge,
                    color: AppColors.whiteDarker,
                    size: 20,
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                onChanged: (value) {
                  widget.entry.name = value;
                  // Don't call onChanged here to avoid setState during build
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: AppColors.nightRiderDark,
                  borderRadius: BorderRadius.circular(8),
                  elevation: 4,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 200,
                      maxWidth: MediaQuery.of(context).size.width - 64,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final pilot = options.elementAt(index);
                        return ListTile(
                          title: Text(
                            pilot.name,
                            style: AppTypography.body.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          subtitle: pilot.flightCount > 0
                              ? Text(
                                  '${pilot.flightCount} flight${pilot.flightCount == 1 ? '' : 's'}',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.whiteDarker,
                                  ),
                                )
                              : null,
                          dense: true,
                          onTap: () => onSelected(pilot),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
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
