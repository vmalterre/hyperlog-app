import 'package:flutter/material.dart';
import '../models/screen_config.dart';
import '../services/screen_config_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Bottom sheet for switching between screen configurations in the log flight screen
class ScreenSwitcherSheet extends StatefulWidget {
  final String? selectedScreenId;
  final ValueChanged<String?> onScreenSelected;

  const ScreenSwitcherSheet({
    super.key,
    required this.selectedScreenId,
    required this.onScreenSelected,
  });

  @override
  State<ScreenSwitcherSheet> createState() => _ScreenSwitcherSheetState();
}

class _ScreenSwitcherSheetState extends State<ScreenSwitcherSheet> {
  final ScreenConfigService _screenService = ScreenConfigService.instance;
  List<ScreenConfig> _screens = [];
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedScreenId;
    _loadScreens();
  }

  void _loadScreens() {
    setState(() {
      _screens = _screenService.getAll();
    });
  }

  void _selectScreen(String? id) {
    setState(() {
      _selectedId = id;
    });
    widget.onScreenSelected(id);
    Navigator.pop(context);
  }

  void _navigateToManageScreens() {
    // Pop with result indicating "manage screens" was requested
    // The parent will handle navigation and re-opening the sheet
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.nightRiderDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.whiteDarker,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Select Screen',
                    style: AppTypography.h4,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: AppColors.whiteDarker),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Screen list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Full Form option
                  _ScreenOption(
                    title: 'Full Form',
                    subtitle: 'All fields visible',
                    icon: Icons.dashboard,
                    isSelected: _selectedId == null,
                    onTap: () => _selectScreen(null),
                  ),

                  // Custom screens
                  ..._screens.map((config) => _ScreenOption(
                        title: config.name,
                        subtitle: _screenService.getConfigSummary(config),
                        icon: Icons.dashboard_customize,
                        isSelected: _selectedId == config.id,
                        onTap: () => _selectScreen(config.id),
                      )),
                ],
              ),
            ),

            // Manage screens link
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _navigateToManageScreens,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      color: AppColors.denim,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Manage Screens',
                      style: AppTypography.body.copyWith(
                        color: AppColors.denim,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ScreenOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScreenOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.denim.withValues(alpha: 0.15)
              : AppColors.glass50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.denim : AppColors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.denim.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.denim : AppColors.whiteDark,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      color: isSelected ? AppColors.denim : AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.whiteDarker,
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.denim,
                size: 24,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: AppColors.whiteDarker,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
