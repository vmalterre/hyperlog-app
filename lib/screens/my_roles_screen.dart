import 'package:flutter/material.dart';
import '../constants/role_standards.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';

class MyRolesScreen extends StatefulWidget {
  const MyRolesScreen({super.key});

  @override
  State<MyRolesScreen> createState() => _MyRolesScreenState();
}

class _MyRolesScreenState extends State<MyRolesScreen> {
  final PreferencesService _prefs = PreferencesService.instance;

  late RoleStandard _selectedStandard;
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    _selectedStandard = _prefs.getRoleStandard();
    _selectedRole = _prefs.getDefaultRole();
  }

  Future<void> _onStandardChanged(RoleStandard standard) async {
    await _prefs.setRoleStandard(standard);
    setState(() {
      _selectedStandard = standard;
      _selectedRole = RoleStandards.getDefaultRole(standard);
    });
  }

  Future<void> _onRoleChanged(String role) async {
    await _prefs.setDefaultRole(role);
    setState(() {
      _selectedRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightRider,
      appBar: AppBar(
        backgroundColor: AppColors.nightRider,
        elevation: 0,
        title: Text('My Roles', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explanation
            Text(
              'Configure how your flight roles are recorded in your logbook.',
              style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
            ),
            const SizedBox(height: 32),

            // Role Standard Section
            _buildSectionHeader('ROLE STANDARD'),
            const SizedBox(height: 12),
            GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: RoleStandard.values.map((standard) {
                  return _StandardOption(
                    standard: standard,
                    isSelected: _selectedStandard == standard,
                    onTap: () => _onStandardChanged(standard),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // Default Role Section
            _buildSectionHeader('DEFAULT ROLE'),
            const SizedBox(height: 12),
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This role will be pre-selected when creating new flights.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.whiteDarker,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _RoleSelector(
                    roles: RoleStandards.getRoles(_selectedStandard),
                    selectedRole: _selectedRole,
                    onChanged: _onRoleChanged,
                    isDescriptive: _selectedStandard == RoleStandard.descriptive,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTypography.label,
      ),
    );
  }
}

/// Radio option for role standard selection
class _StandardOption extends StatelessWidget {
  final RoleStandard standard;
  final bool isSelected;
  final VoidCallback onTap;

  const _StandardOption({
    required this.standard,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              // Radio indicator
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.denim : AppColors.whiteDarker,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.denim,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      RoleStandards.getDisplayName(standard),
                      style: AppTypography.body.copyWith(
                        color: AppColors.white,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      RoleStandards.getSubtitle(standard),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dropdown-style selector for roles
class _RoleSelector extends StatelessWidget {
  final List<Role> roles;
  final String selectedRole;
  final ValueChanged<String> onChanged;
  final bool isDescriptive;

  const _RoleSelector({
    required this.roles,
    required this.selectedRole,
    required this.onChanged,
    this.isDescriptive = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: roles.any((r) => r.code == selectedRole) ? selectedRole : roles.first.code,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.nightRiderDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      dropdownColor: AppColors.nightRiderDark,
      style: AppTypography.body.copyWith(color: AppColors.white),
      icon: Icon(
        Icons.expand_more,
        color: AppColors.whiteDarker,
      ),
      items: roles.map((role) {
        return DropdownMenuItem<String>(
          value: role.code,
          child: Text(
            isDescriptive ? role.code : '${role.code} - ${role.description}',
            style: AppTypography.body.copyWith(color: AppColors.white),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}
