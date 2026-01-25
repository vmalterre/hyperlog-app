import 'package:flutter/material.dart';
import '../../../models/import_models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/glass_card.dart';

/// Screen showing import completion report
class ImportReportScreen extends StatelessWidget {
  final ImportReport report;

  const ImportReportScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final success = report.success && report.errors.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.nightRider,
      appBar: AppBar(
        backgroundColor: AppColors.nightRider,
        elevation: 0,
        title: Text('Import Complete', style: AppTypography.h3),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Success/Error icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: success
                      ? AppColors.endorsedGreen.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
                ),
                child: Icon(
                  success ? Icons.check_circle : Icons.error,
                  size: 48,
                  color: success ? AppColors.endorsedGreen : Colors.red,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                success ? 'Import Successful!' : 'Import Completed with Errors',
                style: AppTypography.h3.copyWith(
                  color: success ? AppColors.endorsedGreen : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Stats card
              GlassContainer(
                child: Column(
                  children: [
                    _StatRow(
                      icon: Icons.flight,
                      label: 'Flights Imported',
                      value: '${report.imported}',
                      valueColor: AppColors.endorsedGreen,
                    ),
                    Divider(height: 24, color: AppColors.glassDark50),
                    _StatRow(
                      icon: Icons.timer,
                      label: 'Total Flight Time',
                      value: report.formattedFlightTime,
                      valueColor: AppColors.denim,
                    ),
                    if (report.crewCreated > 0) ...[
                      Divider(height: 24, color: AppColors.glassDark50),
                      _StatRow(
                        icon: Icons.person_add,
                        label: 'Crew Members Added',
                        value: '${report.crewCreated}',
                        valueColor: AppColors.white,
                      ),
                    ],
                    if (report.skipped > 0) ...[
                      Divider(height: 24, color: AppColors.glassDark50),
                      _StatRow(
                        icon: Icons.skip_next,
                        label: 'Flights Skipped',
                        value: '${report.skipped}',
                        valueColor: AppColors.whiteDarker,
                      ),
                    ],
                  ],
                ),
              ),

              // Errors section
              if (report.errors.isNotEmpty) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${report.errors.length} Errors',
                        style: AppTypography.label.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GlassContainer(
                    padding: EdgeInsets.zero,
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(12),
                      itemCount: report.errors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return Text(
                          report.errors[index],
                          style: AppTypography.caption.copyWith(
                            color: Colors.red.shade300,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ] else ...[
                const Spacer(),
              ],

              const SizedBox(height: 32),

              // Done button
              PrimaryButton(
                label: 'Done',
                icon: Icons.check,
                fullWidth: true,
                onPressed: () {
                  // Pop back to settings (two screens: provider -> preview -> report)
                  Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/settings');
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Your flights are now in your logbook.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.whiteDarker,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stat row widget
class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.whiteDarker, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
          ),
        ),
        Text(
          value,
          style: AppTypography.h4.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
