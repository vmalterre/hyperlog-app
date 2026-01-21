import 'package:flutter/material.dart';
import '../models/screen_config.dart';
import '../services/screen_config_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';
import 'screen_editor_screen.dart';

class MyScreensScreen extends StatefulWidget {
  const MyScreensScreen({super.key});

  @override
  State<MyScreensScreen> createState() => _MyScreensScreenState();
}

class _MyScreensScreenState extends State<MyScreensScreen> {
  final ScreenConfigService _screenService = ScreenConfigService.instance;
  List<ScreenConfig> _screens = [];

  @override
  void initState() {
    super.initState();
    _loadScreens();
    _screenService.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _screenService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    _loadScreens();
  }

  void _loadScreens() {
    setState(() {
      _screens = _screenService.getAll();
    });
  }

  Future<void> _createScreen() async {
    final name = await _showNameDialog(title: 'New Screen');
    if (name == null || name.trim().isEmpty) return;

    final config = await _screenService.create(name.trim());

    if (mounted) {
      // Navigate to editor to configure the new screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScreenEditorScreen(config: config),
        ),
      );
    }
  }

  Future<void> _editScreen(ScreenConfig config) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScreenEditorScreen(config: config),
      ),
    );
  }

  Future<void> _deleteScreen(ScreenConfig config) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text(
          'Delete Screen?',
          style: AppTypography.h4.copyWith(color: AppColors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${config.name}"? This cannot be undone.',
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
      await _screenService.delete(config.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${config.name}"'),
            backgroundColor: AppColors.nightRiderLight,
          ),
        );
      }
    }
  }

  Future<void> _setAsDefault(ScreenConfig config) async {
    await _screenService.setDefault(config.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${config.name}" is now your default screen'),
          backgroundColor: AppColors.endorsedGreen,
        ),
      );
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
            hintText: 'e.g. GA Simple, Airline, Instruction',
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
              'Create',
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
        title: Text('My Screens', style: AppTypography.h3),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GlassContainer(
              borderRadius: 22,
              padding: EdgeInsets.zero,
              borderColor: AppColors.denim.withValues(alpha: 0.3),
              child: IconButton(
                onPressed: _createScreen,
                icon: const Icon(Icons.add, color: AppColors.denimLight),
                iconSize: 24,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Explanation
          Text(
            'Create custom screens to show only the fields you need when logging flights. '
            'Hidden fields are still calculated and saved.',
            style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
          ),
          const SizedBox(height: 24),

          if (_screens.isEmpty)
            _buildEmptyState()
          else
            ..._screens.map((config) => SizedBox(
                  width: double.infinity,
                  child: _ScreenCard(
                    config: config,
                    isDefault: config.id == _screenService.defaultScreenId,
                    summary: _screenService.getConfigSummary(config),
                    onEdit: () => _editScreen(config),
                    onDelete: () => _deleteScreen(config),
                    onSetDefault: () => _setAsDefault(config),
                  ),
                )),
        ],
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.dashboard_customize_outlined,
              color: AppColors.whiteDarker,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'No custom screens yet',
              style: AppTypography.h4.copyWith(color: AppColors.whiteDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to create a screen with only\nthe fields you need',
              style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Card for a custom screen configuration
class _ScreenCard extends StatelessWidget {
  final ScreenConfig config;
  final bool isDefault;
  final String summary;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _ScreenCard({
    required this.config,
    required this.isDefault,
    required this.summary,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      borderColor: isDefault ? AppColors.denim.withValues(alpha: 0.5) : null,
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.denim.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.dashboard_customize,
              color: AppColors.denim,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Name and summary
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        config.name,
                        style: AppTypography.body.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.denim.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DEFAULT',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.denim,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  summary,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.whiteDarker,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.denim, size: 20),
            onPressed: onEdit,
            tooltip: 'Edit',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.errorRed, size: 20),
            onPressed: onDelete,
            tooltip: 'Delete',
          ),
          if (!isDefault)
            IconButton(
              icon: Icon(
                Icons.radio_button_unchecked,
                color: AppColors.whiteDarker,
                size: 24,
              ),
              onPressed: onSetDefault,
              tooltip: 'Set as default',
            )
          else
            Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.check_circle,
                color: AppColors.denim,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }
}
