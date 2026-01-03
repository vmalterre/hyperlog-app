import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Numeric stepper for values like landings count
class NumberStepper extends StatelessWidget {
  final String label;
  final int value;
  final int minValue;
  final int maxValue;
  final void Function(int) onChanged;

  const NumberStepper({
    super.key,
    required this.label,
    required this.value,
    this.minValue = 0,
    this.maxValue = 99,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrement = value > minValue;
    final canIncrement = value < maxValue;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.body.copyWith(color: AppColors.whiteDark),
          ),
        ),
        _StepperButton(
          icon: Icons.remove,
          enabled: canDecrement,
          onPressed: canDecrement ? () => onChanged(value - 1) : null,
        ),
        Container(
          width: 48,
          alignment: Alignment.center,
          child: Text(
            value.toString(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
        _StepperButton(
          icon: Icons.add,
          enabled: canIncrement,
          onPressed: canIncrement ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onPressed;

  const _StepperButton({
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
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: enabled ? AppColors.white : AppColors.whiteDarker,
          ),
        ),
      ),
    );
  }
}
