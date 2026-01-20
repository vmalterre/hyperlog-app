import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/logbook_entry.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'time_range_picker_modal.dart';

/// Quick-set widget for duration time fields with toggle and edit buttons
///
/// Features:
/// - Toggle button: cycles between all time (maxMinutes), none (0), shows partial state
/// - Edit button: opens TimeRangePickerModal for visual time range selection
class DurationQuickSet extends StatelessWidget {
  final String label;
  final int minutes;
  final int maxMinutes;
  final TimeOfDay? blockOff;
  final TimeOfDay? blockOn;
  final void Function(int) onChanged;

  const DurationQuickSet({
    super.key,
    required this.label,
    required this.minutes,
    required this.maxMinutes,
    this.blockOff,
    this.blockOn,
    required this.onChanged,
  });

  bool get _isAll => minutes == maxMinutes && maxMinutes > 0;
  bool get _isNone => minutes == 0;
  bool get _isPartial => !_isAll && !_isNone;

  void _handleToggle() {
    HapticFeedback.lightImpact();
    if (_isAll) {
      // All -> None
      onChanged(0);
    } else {
      // None or Partial -> All
      onChanged(maxMinutes);
    }
  }

  Future<void> _handleEdit(BuildContext context) async {
    if (maxMinutes <= 0) return;

    final result = await TimeRangePickerModal.show(
      context,
      title: label,
      totalMinutes: maxMinutes,
      initialDuration: minutes,
      blockOff: blockOff,
      blockOn: blockOn,
    );

    if (result != null) {
      onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Label
        Expanded(
          child: Text(
            label,
            style: AppTypography.body.copyWith(color: AppColors.whiteDark),
          ),
        ),

        // Time display
        Container(
          width: 64,
          alignment: Alignment.center,
          child: Text(
            FlightTime.formatMinutes(minutes),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: minutes > 0 ? AppColors.white : AppColors.whiteDarker,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Toggle button - pill style matching HyperLog tab buttons
        _ToggleButton(
          isAll: _isAll,
          isPartial: _isPartial,
          enabled: maxMinutes > 0,
          onPressed: maxMinutes > 0 ? _handleToggle : null,
        ),

        const SizedBox(width: 8),

        // Edit button - outline style
        _EditButton(
          enabled: maxMinutes > 0,
          onPressed: maxMinutes > 0 ? () => _handleEdit(context) : null,
        ),
      ],
    );
  }
}

/// Toggle button with three visual states matching HyperLog tab/pill button style
class _ToggleButton extends StatelessWidget {
  final bool isAll;
  final bool isPartial;
  final bool enabled;
  final VoidCallback? onPressed;

  const _ToggleButton({
    required this.isAll,
    required this.isPartial,
    required this.enabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on state
    final Color backgroundColor;
    final Color borderColor;
    final Color iconColor;
    final IconData icon;

    if (!enabled) {
      backgroundColor = Colors.transparent;
      borderColor = AppColors.borderSubtle;
      iconColor = AppColors.whiteDarker.withValues(alpha: 0.5);
      icon = Icons.radio_button_unchecked;
    } else if (isAll) {
      // Active/All state - solid denim
      backgroundColor = AppColors.denim;
      borderColor = AppColors.denim;
      iconColor = AppColors.white;
      icon = Icons.check_circle;
    } else if (isPartial) {
      // Partial state - denim accent
      backgroundColor = AppColors.denimBg;
      borderColor = AppColors.denimBorder;
      iconColor = AppColors.denimLight;
      icon = Icons.timelapse;
    } else {
      // None/Inactive state - transparent with border
      backgroundColor = Colors.transparent;
      borderColor = AppColors.borderVisible;
      iconColor = AppColors.whiteDarker;
      icon = Icons.radio_button_unchecked;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Edit button with outline style matching HyperLog secondary buttons
class _EditButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;

  const _EditButton({
    required this.enabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: enabled ? AppColors.borderVisible : AppColors.borderSubtle,
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.edit_outlined,
              size: 16,
              color: enabled ? AppColors.whiteDarker : AppColors.whiteDarker.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
