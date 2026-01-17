import 'package:flutter/material.dart';
import '../constants/airport_format.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';

class DisplayOptionsScreen extends StatefulWidget {
  const DisplayOptionsScreen({super.key});

  @override
  State<DisplayOptionsScreen> createState() => _DisplayOptionsScreenState();
}

class _DisplayOptionsScreenState extends State<DisplayOptionsScreen> {
  final PreferencesService _prefs = PreferencesService.instance;

  late AirportCodeFormat _selectedFormat;

  @override
  void initState() {
    super.initState();
    _selectedFormat = _prefs.getAirportCodeFormat();
  }

  Future<void> _onFormatChanged(AirportCodeFormat format) async {
    await _prefs.setAirportCodeFormat(format);
    setState(() {
      _selectedFormat = format;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightRider,
      appBar: AppBar(
        backgroundColor: AppColors.nightRider,
        elevation: 0,
        title: Text('Display Options', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'AIRPORT CODE FORMAT',
                style: AppTypography.label,
              ),
            ),
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose how airport codes are displayed throughout the app.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.whiteDarker,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...AirportCodeFormat.values.map((format) => _FormatOption(
                        format: format,
                        isSelected: _selectedFormat == format,
                        onTap: () => _onFormatChanged(format),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatOption extends StatelessWidget {
  final AirportCodeFormat format;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatOption({
    required this.format,
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
          padding: const EdgeInsets.symmetric(vertical: 12),
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
              // Format name and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AirportFormats.getDisplayName(format),
                      style: AppTypography.body.copyWith(
                        color: AppColors.white,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AirportFormats.getDescription(format),
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
