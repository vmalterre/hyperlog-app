import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Time picker with glass styling (24-hour format)
class GlassTimePicker extends StatelessWidget {
  final TimeOfDay selectedTime;
  final String label;
  final void Function(TimeOfDay) onTimeSelected;

  const GlassTimePicker({
    super.key,
    required this.selectedTime,
    required this.label,
    required this.onTimeSelected,
  });

  String get _formattedTime {
    final hour = selectedTime.hour.toString().padLeft(2, '0');
    final minute = selectedTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(
            fontSize: 11,
            color: AppColors.whiteDarker,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showTimePicker(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.glass50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: AppColors.whiteDarker,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _formattedTime,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.denim,
              onPrimary: AppColors.white,
              surface: AppColors.nightRiderDark,
              onSurface: AppColors.white,
            ),
            dialogBackgroundColor: AppColors.nightRiderDark,
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.nightRiderDark,
              hourMinuteColor: AppColors.glass50,
              hourMinuteTextColor: AppColors.white,
              dialBackgroundColor: AppColors.glass50,
              dialHandColor: AppColors.denim,
              dialTextColor: AppColors.white,
              entryModeIconColor: AppColors.whiteDarker,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      onTimeSelected(picked);
    }
  }
}
