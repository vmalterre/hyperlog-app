import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/logbook_entry.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Read-only duration display for automatic time fields
///
/// Shows a label and the time in HH:MM format without any edit controls.
/// Used for fields that are auto-calculated (Night, Multi-Engine, Multi-Pilot).
class DurationDisplay extends StatelessWidget {
  final String label;
  final int minutes;

  const DurationDisplay({
    super.key,
    required this.label,
    required this.minutes,
  });

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
        Text(
          FlightTime.formatMinutes(minutes),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: minutes > 0 ? AppColors.white : AppColors.whiteDarker,
          ),
        ),
      ],
    );
  }
}
