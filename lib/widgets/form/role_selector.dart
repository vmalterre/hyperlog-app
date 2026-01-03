import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Three-button selector for PIC/SIC/Dual roles
class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final void Function(String) onRoleSelected;

  static const List<String> roles = ['PIC', 'SIC', 'Dual'];

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
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
            final isSelected = role == selectedRole;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: role != roles.last ? 8 : 0,
                ),
                child: _RoleButton(
                  label: role,
                  isSelected: isSelected,
                  onPressed: () => onRoleSelected(role),
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
