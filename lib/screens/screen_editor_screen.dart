import 'package:flutter/material.dart';
import '../constants/flight_fields.dart';
import '../models/screen_config.dart';
import '../services/screen_config_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';

class ScreenEditorScreen extends StatefulWidget {
  final ScreenConfig config;

  const ScreenEditorScreen({super.key, required this.config});

  @override
  State<ScreenEditorScreen> createState() => _ScreenEditorScreenState();
}

class _ScreenEditorScreenState extends State<ScreenEditorScreen> {
  final ScreenConfigService _screenService = ScreenConfigService.instance;
  late TextEditingController _nameController;
  late Set<FlightField> _hiddenFields;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.config.name);
    _hiddenFields = Set.from(widget.config.hiddenFields);
    _nameController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  void _toggleField(FlightField field) {
    setState(() {
      if (_hiddenFields.contains(field)) {
        _hiddenFields.remove(field);
      } else {
        _hiddenFields.add(field);
      }
      _hasChanges = true;
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a screen name'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final updatedConfig = widget.config.copyWith(
      name: name,
      hiddenFields: _hiddenFields,
    );

    await _screenService.update(updatedConfig);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text(
          'Discard changes?',
          style: AppTypography.h4.copyWith(color: AppColors.white),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to discard them?',
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
              'Discard',
              style: AppTypography.button.copyWith(color: AppColors.denim),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final bySection = FlightFieldsMeta.bySection;
    final sectionOrder = FlightFieldsMeta.sectionOrder;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.nightRider,
        appBar: AppBar(
          backgroundColor: AppColors.nightRider,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.whiteDark),
            onPressed: () async {
              final navigator = Navigator.of(context);
              if (_hasChanges) {
                final shouldPop = await _onWillPop();
                if (shouldPop && mounted) {
                  navigator.pop();
                }
              } else {
                navigator.pop();
              }
            },
          ),
          title: Text('Edit Screen', style: AppTypography.h3),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _save,
              child: Text(
                'Save',
                style: AppTypography.button.copyWith(color: AppColors.denim),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Name
              _buildSectionHeader('SCREEN NAME'),
              const SizedBox(height: 12),
              GlassContainer(
                child: TextField(
                  controller: _nameController,
                  style: AppTypography.body.copyWith(color: AppColors.white),
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'e.g. GA Simple, Airline, Instruction',
                    hintStyle: AppTypography.body.copyWith(color: AppColors.whiteDarker),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Info text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.denim.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.denim.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.denim,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Unchecked fields will be hidden. Hidden fields are still calculated and saved with your flight.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.whiteDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Field sections
              ...sectionOrder.map((section) {
                final fields = bySection[section];
                if (fields == null || fields.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(section.toUpperCase()),
                    const SizedBox(height: 12),
                    GlassContainer(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: fields.asMap().entries.map((entry) {
                          final index = entry.key;
                          final meta = entry.value;
                          final isHidden = _hiddenFields.contains(meta.field);

                          return Column(
                            children: [
                              _FieldToggleRow(
                                meta: meta,
                                isVisible: !isHidden,
                                onToggle: () => _toggleField(meta.field),
                              ),
                              if (index < fields.length - 1)
                                Divider(
                                  height: 1,
                                  color: AppColors.borderSubtle,
                                  indent: 56,
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }),

              // Required fields notice
              _buildSectionHeader('REQUIRED FIELDS'),
              const SizedBox(height: 12),
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The following fields cannot be hidden:',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.whiteDarker,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _RequiredFieldRow(icon: Icons.calendar_today, label: 'Date'),
                    _RequiredFieldRow(icon: Icons.flight_takeoff, label: 'From (departure)'),
                    _RequiredFieldRow(icon: Icons.flight_land, label: 'To (destination)'),
                    _RequiredFieldRow(icon: Icons.flight, label: 'Aircraft'),
                    _RequiredFieldRow(icon: Icons.timer, label: 'Block Off / Block On'),
                    _RequiredFieldRow(icon: Icons.person, label: 'Your role'),
                    _RequiredFieldRow(icon: Icons.schedule, label: 'Primary role time'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
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

/// A toggleable row for a flight field
class _FieldToggleRow extends StatelessWidget {
  final FlightFieldMeta meta;
  final bool isVisible;
  final VoidCallback onToggle;

  const _FieldToggleRow({
    required this.meta,
    required this.isVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isVisible
                    ? AppColors.denim
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isVisible
                      ? AppColors.denim
                      : AppColors.whiteDarker.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isVisible
                  ? const Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Label and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        meta.label,
                        style: AppTypography.body.copyWith(
                          color: isVisible ? AppColors.white : AppColors.whiteDarker,
                        ),
                      ),
                      if (meta.isCalculated) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.denim.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'AUTO',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.denim,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta.description,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.whiteDarker,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A row showing a required field that cannot be hidden
class _RequiredFieldRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RequiredFieldRow({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: AppColors.whiteDarker,
            size: 16,
          ),
          const SizedBox(width: 12),
          Icon(
            icon,
            color: AppColors.whiteDark,
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTypography.body.copyWith(
              color: AppColors.whiteDark,
            ),
          ),
        ],
      ),
    );
  }
}
