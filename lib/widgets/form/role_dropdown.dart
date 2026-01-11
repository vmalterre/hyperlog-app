import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// EASA standard pilot roles for logbook entries
class PilotRoles {
  static const List<String> values = [
    'PIC',    // Pilot In Command
    'SIC',    // Second In Command / Co-Pilot
    'DUAL',   // Dual (receiving instruction)
    'SPIC',   // Student Pilot In Command
    'PICUS',  // Pilot In Command Under Supervision
    'FI',     // Flight Instructor
    'FE',     // Flight Examiner
    'SP',     // Single Pilot
    'RP',     // Relief Pilot
    'OBS',    // Observer
    'PU',     // Pilot Under training (legacy)
    'PUT',    // Pilot Under Training
  ];

  static String getDescription(String role) {
    return switch (role) {
      'PIC' => 'Pilot In Command',
      'SIC' => 'Second In Command',
      'DUAL' => 'Dual (Instruction)',
      'SPIC' => 'Student PIC',
      'PICUS' => 'PIC Under Supervision',
      'FI' => 'Flight Instructor',
      'FE' => 'Flight Examiner',
      'SP' => 'Single Pilot',
      'RP' => 'Relief Pilot',
      'OBS' => 'Observer',
      'PU' => 'Pilot Under Training',
      'PUT' => 'Pilot Under Training',
      _ => role,
    };
  }

  /// Get list of roles including any custom role that might exist in data
  static List<String> getValuesWithCustom(String? customRole) {
    if (customRole == null || customRole.isEmpty || values.contains(customRole)) {
      return values;
    }
    return [...values, customRole];
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
    return DropdownButtonFormField<String>(
      initialValue: value,
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
      items: PilotRoles.values.map((role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  role,
                  style: AppTypography.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                PilotRoles.getDescription(role),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.whiteDarker,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
