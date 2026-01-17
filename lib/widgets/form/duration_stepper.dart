import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/logbook_entry.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Duration stepper for time values displayed in HH:MM format
class DurationStepper extends StatelessWidget {
  final String label;
  final int minutes;
  final int maxMinutes;
  final int stepSize;
  final void Function(int) onChanged;

  const DurationStepper({
    super.key,
    required this.label,
    required this.minutes,
    required this.maxMinutes,
    this.stepSize = 5,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrement = minutes > 0;
    final canIncrement = minutes < maxMinutes;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.body.copyWith(color: AppColors.whiteDark),
          ),
        ),
        _DurationStepperButton(
          icon: Icons.remove,
          enabled: canDecrement,
          onPressed: canDecrement
              ? () => onChanged((minutes - stepSize).clamp(0, maxMinutes))
              : null,
        ),
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
        _DurationStepperButton(
          icon: Icons.add,
          enabled: canIncrement,
          onPressed: canIncrement
              ? () => onChanged((minutes + stepSize).clamp(0, maxMinutes))
              : null,
        ),
      ],
    );
  }
}

class _DurationStepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onPressed;

  const _DurationStepperButton({
    required this.icon,
    required this.enabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.denim : AppColors.nightRiderLight,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: enabled ? AppColors.white : AppColors.whiteDarker,
          ),
        ),
      ),
    );
  }
}
