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
  late String _selectedDefaultRole;
  String? _selectedDefaultSecondaryRole;
  late List<String> _customFields;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    _selectedStandard = _prefs.getRoleStandard();
    _selectedDefaultRole = _prefs.getDefaultRole();
    _selectedDefaultSecondaryRole = _prefs.getDefaultSecondaryRole();
    _customFields = _prefs.getCustomTimeFields();
  }

  Future<void> _onStandardChanged(RoleStandard standard) async {
    await _prefs.setRoleStandard(standard);
    setState(() {
      _selectedStandard = standard;
      // Default role code stays the same, only labels change
    });
  }

  Future<void> _onDefaultRoleChanged(String role) async {
    await _prefs.setDefaultRole(role);
    setState(() {
      _selectedDefaultRole = role;
    });
  }

  Future<void> _onDefaultSecondaryRoleChanged(String? role) async {
    await _prefs.setDefaultSecondaryRole(role);
    setState(() {
      _selectedDefaultSecondaryRole = role;
    });
  }

  Future<void> _addCustomField() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text(
          'Add Custom Field',
          style: AppTypography.h4.copyWith(color: AppColors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTypography.body.copyWith(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'e.g. Check Pilot, Safety Pilot',
            hintStyle: AppTypography.body.copyWith(color: AppColors.whiteDarker),
          ),
          textCapitalization: TextCapitalization.words,
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
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              }
            },
            child: Text(
              'Add',
              style: AppTypography.button.copyWith(color: AppColors.denim),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _prefs.addCustomTimeField(result);
      setState(() {
        _customFields = _prefs.getCustomTimeFields();
      });
    }
  }

  Future<void> _editCustomField(String oldName) async {
    final controller = TextEditingController(text: oldName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text(
          'Edit Custom Field',
          style: AppTypography.h4.copyWith(color: AppColors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTypography.body.copyWith(color: AppColors.white),
          textCapitalization: TextCapitalization.words,
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
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              }
            },
            child: Text(
              'Save',
              style: AppTypography.button.copyWith(color: AppColors.denim),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != oldName) {
      await _prefs.renameCustomTimeField(oldName, result);
      setState(() {
        _customFields = _prefs.getCustomTimeFields();
      });
    }
  }

  Future<void> _deleteCustomField(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text(
          'Delete Custom Field?',
          style: AppTypography.h4.copyWith(color: AppColors.white),
        ),
        content: Text(
          'Are you sure you want to delete "$name"? This will not affect existing flight entries.',
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

    if (confirmed == true) {
      await _prefs.removeCustomTimeField(name);
      setState(() {
        _customFields = _prefs.getCustomTimeFields();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryRoles = RoleStandards.getPrimaryRolesWithLabels(_selectedStandard);
    final secondaryRoles = RoleStandards.getSecondaryRolesWithLabels(_selectedStandard);

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
              'Configure how your flight roles and time categories are recorded in your logbook.',
              style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
            ),
            const SizedBox(height: 32),

            // Role Standard Section
            _buildSectionHeader('ROLE STANDARD'),
            const SizedBox(height: 12),
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose the terminology used for roles and time categories.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.whiteDarker,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StandardDropdown(
                    selectedStandard: _selectedStandard,
                    onChanged: _onStandardChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Required Time Fields (read-only display)
            _buildSectionHeader('REQUIRED TIME FIELDS'),
            const SizedBox(height: 12),
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'These time categories are always available. '
                    'Labels shown are based on your selected standard.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.whiteDarker,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Primary roles section
                  Text(
                    'Primary Roles',
                    style: AppTypography.label.copyWith(
                      color: AppColors.whiteDark,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...primaryRoles.map((field) => _TimeFieldRow(
                        code: field.code,
                        label: field.label,
                      )),
                  const SizedBox(height: 16),
                  // Secondary roles section
                  Text(
                    'Secondary Roles',
                    style: AppTypography.label.copyWith(
                      color: AppColors.whiteDark,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...secondaryRoles.map((field) => _TimeFieldRow(
                        code: field.code,
                        label: field.label,
                      )),
                ],
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
                    'These roles will be pre-selected when creating new flights.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.whiteDarker,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Primary Role dropdown
                  Text(
                    'Primary Role',
                    style: AppTypography.label.copyWith(
                      color: AppColors.whiteDark,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _RoleDropdown(
                    roles: primaryRoles,
                    selectedRole: _selectedDefaultRole,
                    onChanged: _onDefaultRoleChanged,
                  ),
                  const SizedBox(height: 16),
                  // Secondary Role (optional)
                  if (_selectedDefaultSecondaryRole == null)
                    TextButton.icon(
                      onPressed: () => _onDefaultSecondaryRoleChanged(TimeFieldCodes.dual),
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
                    Text(
                      'Secondary Role',
                      style: AppTypography.label.copyWith(
                        color: AppColors.whiteDark,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _RoleDropdown(
                      roles: secondaryRoles,
                      selectedRole: _selectedDefaultSecondaryRole!,
                      onChanged: (role) => _onDefaultSecondaryRoleChanged(role),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => _onDefaultSecondaryRoleChanged(null),
                      icon: Icon(Icons.remove_circle_outline, color: AppColors.whiteDarker, size: 16),
                      label: Text(
                        'Remove Secondary Role',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.whiteDarker),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Custom Fields Section
            _buildSectionHeader('MY CUSTOM FIELDS'),
            const SizedBox(height: 12),
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create your own time fields for personal tracking '
                    '(e.g. Check Pilot, Safety Pilot).',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.whiteDarker,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_customFields.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'No custom fields yet.',
                        style: AppTypography.body.copyWith(
                          color: AppColors.whiteDarker,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else
                    ..._customFields.map((field) => _CustomFieldRow(
                          name: field,
                          onEdit: () => _editCustomField(field),
                          onDelete: () => _deleteCustomField(field),
                        )),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _addCustomField,
                    icon: Icon(Icons.add, color: AppColors.denim, size: 20),
                    label: Text(
                      'Add Custom Field',
                      style: AppTypography.body.copyWith(color: AppColors.denim),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
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

/// Dropdown for role standard selection
class _StandardDropdown extends StatelessWidget {
  final RoleStandard selectedStandard;
  final ValueChanged<RoleStandard> onChanged;

  const _StandardDropdown({
    required this.selectedStandard,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<RoleStandard>(
      value: selectedStandard,
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
      items: RoleStandard.values.map((standard) {
        return DropdownMenuItem<RoleStandard>(
          value: standard,
          child: Text(
            RoleStandards.getDisplayName(standard),
            style: AppTypography.body.copyWith(color: AppColors.white),
          ),
        );
      }).toList(),
    );
  }
}

/// Read-only display row for a required time field
class _TimeFieldRow extends StatelessWidget {
  final String code;
  final String label;

  const _TimeFieldRow({
    required this.code,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: 18, color: AppColors.denim),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body.copyWith(color: AppColors.white),
            ),
          ),
          Text(
            code,
            style: AppTypography.caption.copyWith(color: AppColors.whiteDarker),
          ),
        ],
      ),
    );
  }
}

/// Dropdown for role selection
class _RoleDropdown extends StatelessWidget {
  final List<({String code, String label})> roles;
  final String selectedRole;
  final ValueChanged<String> onChanged;

  const _RoleDropdown({
    required this.roles,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure selected role exists in the list
    final effectiveRole = roles.any((r) => r.code == selectedRole)
        ? selectedRole
        : roles.first.code;

    return DropdownButtonFormField<String>(
      value: effectiveRole,
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
            '${role.label} (${role.code})',
            style: AppTypography.body.copyWith(color: AppColors.white),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}

/// Row for a custom time field with edit/delete actions
class _CustomFieldRow extends StatelessWidget {
  final String name;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomFieldRow({
    required this.name,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.label_outline, size: 18, color: AppColors.whiteDarker),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: AppTypography.body.copyWith(color: AppColors.white),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.whiteDarker),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Edit',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 18, color: AppColors.errorRed),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}
