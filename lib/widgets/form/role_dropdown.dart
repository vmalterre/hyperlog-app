import 'package:flutter/material.dart';
import '../../constants/role_standards.dart';
import '../../services/preferences_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Legacy PilotRoles class for backward compatibility
/// New code should use TimeFieldCodes and RoleStandards
class PilotRoles {
  static List<String> get values {
    return TimeFieldCodes.primaryRoles;
  }

  static String getDescription(String role) {
    final prefs = PreferencesService.instance;
    return RoleStandards.getLabel(prefs.getRoleStandard(), role);
  }

  /// Get list of roles including any custom role that might exist in data
  static List<String> getValuesWithCustom(String? customRole) {
    final currentValues = values;
    if (customRole == null || customRole.isEmpty || currentValues.contains(customRole)) {
      return currentValues;
    }
    return [...currentValues, customRole];
  }
}

/// Glass-styled dropdown for selecting pilot roles
class RoleDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;
  final bool enabled;
  final String? Function(String?)? validator;

  const RoleDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Role',
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final standard = PreferencesService.instance.getRoleStandard();
    final rolesWithLabels = RoleStandards.getPrimaryRolesWithLabels(standard);
    final roleCodes = rolesWithLabels.map((r) => r.code).toList();

    // Include custom role if value is not in standard list
    var displayRoles = rolesWithLabels;
    if (value != null && value!.isNotEmpty && !roleCodes.contains(value)) {
      displayRoles = [
        ...rolesWithLabels,
        (code: value!, label: value!),
      ];
    }

    final effectiveValue = displayRoles.any((r) => r.code == value)
        ? value
        : displayRoles.first.code;

    return DropdownButtonFormField<String>(
      value: effectiveValue,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          Icons.badge_outlined,
          color: AppColors.whiteDarker,
          size: 20,
        ),
      ),
      dropdownColor: AppColors.nightRiderDark,
      style: AppTypography.body.copyWith(color: AppColors.white),
      icon: Icon(
        Icons.expand_more,
        color: AppColors.whiteDarker,
      ),
      items: displayRoles.map((role) {
        return DropdownMenuItem<String>(
          value: role.code,
          child: Text(
            role.label,
            style: AppTypography.body.copyWith(
              color: AppColors.white,
            ),
          ),
        );
      }).toList(),
    );
  }
}
