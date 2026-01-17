import 'package:flutter/material.dart';
import '../../constants/role_standards.dart';
import '../../services/preferences_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Selector for primary and optional secondary roles
/// Primary roles: PIC, SIC, PICUS (seat position - mutually exclusive)
/// Secondary roles: DUAL, INSTRUCTOR (activity - optional)
class RoleSelector extends StatelessWidget {
  final String selectedPrimaryRole;
  final String? selectedSecondaryRole;
  final void Function(String primaryRole, String? secondaryRole) onRoleSelected;

  const RoleSelector({
    super.key,
    required this.selectedPrimaryRole,
    this.selectedSecondaryRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final standard = PreferencesService.instance.getRoleStandard();
    final primaryRoles = [
      (code: TimeFieldCodes.pic, label: RoleStandards.getLabel(standard, TimeFieldCodes.pic)),
      (code: TimeFieldCodes.sic, label: RoleStandards.getLabel(standard, TimeFieldCodes.sic)),
      (code: TimeFieldCodes.picus, label: RoleStandards.getLabel(standard, TimeFieldCodes.picus)),
    ];
    final secondaryRoles = [
      (code: TimeFieldCodes.dual, label: RoleStandards.getLabel(standard, TimeFieldCodes.dual)),
      (code: TimeFieldCodes.instructor, label: RoleStandards.getLabel(standard, TimeFieldCodes.instructor)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary Role label
        Text(
          'PRIMARY ROLE',
          style: AppTypography.label.copyWith(
            fontSize: 11,
            color: AppColors.whiteDarker,
          ),
        ),
        const SizedBox(height: 12),
        // Primary role buttons
        Row(
          children: primaryRoles.map((role) {
            final isSelected = role.code == selectedPrimaryRole;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: role != primaryRoles.last ? 8 : 0,
                ),
                child: _RoleButton(
                  label: role.label,
                  isSelected: isSelected,
                  onPressed: () => onRoleSelected(role.code, selectedSecondaryRole),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        // Secondary Role section
        if (selectedSecondaryRole == null)
          TextButton.icon(
            onPressed: () => onRoleSelected(selectedPrimaryRole, TimeFieldCodes.dual),
            icon: Icon(Icons.add, color: AppColors.denim, size: 18),
            label: Text(
              'Add Secondary Role',
              style: AppTypography.body.copyWith(color: AppColors.denim),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
          )
        else ...[
          Row(
            children: [
              Text(
                'SECONDARY ROLE',
                style: AppTypography.label.copyWith(
                  fontSize: 11,
                  color: AppColors.whiteDarker,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => onRoleSelected(selectedPrimaryRole, null),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, color: AppColors.whiteDarker, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        'Remove',
                        style: AppTypography.caption.copyWith(color: AppColors.whiteDarker),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: secondaryRoles.map((role) {
              final isSelected = role.code == selectedSecondaryRole;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: role != secondaryRoles.last ? 8 : 0,
                  ),
                  child: _RoleButton(
                    label: role.label,
                    isSelected: isSelected,
                    onPressed: () => onRoleSelected(selectedPrimaryRole, role.code),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

/// Simple three-button selector for primary roles only
/// Use this for compact UI where secondary role isn't needed
class PrimaryRoleSelector extends StatelessWidget {
  final String selectedRole;
  final void Function(String) onRoleSelected;

  const PrimaryRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final standard = PreferencesService.instance.getRoleStandard();
    final roles = [
      (code: TimeFieldCodes.pic, label: RoleStandards.getLabel(standard, TimeFieldCodes.pic)),
      (code: TimeFieldCodes.sic, label: RoleStandards.getLabel(standard, TimeFieldCodes.sic)),
      (code: TimeFieldCodes.picus, label: RoleStandards.getLabel(standard, TimeFieldCodes.picus)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ROLE',
          style: AppTypography.label.copyWith(
            fontSize: 11,
            color: AppColors.whiteDarker,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: roles.map((role) {
            final isSelected = role.code == selectedRole;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: role != roles.last ? 8 : 0,
                ),
                child: _RoleButton(
                  label: role.label,
                  isSelected: isSelected,
                  onPressed: () => onRoleSelected(role.code),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _RoleButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: isSelected ? AppColors.denim : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.denim : AppColors.borderVisible,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTypography.button.copyWith(
                color: isSelected ? AppColors.white : AppColors.whiteDarker,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
