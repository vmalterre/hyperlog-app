import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../database/database_provider.dart';
import '../../../models/import_models.dart';
import '../../../session_state.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/glass_card.dart';

/// Screen showing import completion report
class ImportReportScreen extends StatefulWidget {
  final ImportReport report;

  const ImportReportScreen({super.key, required this.report});

  @override
  State<ImportReportScreen> createState() => _ImportReportScreenState();
}

class _ImportReportScreenState extends State<ImportReportScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger a sync after the frame to ensure context is valid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncFlights();
    });
  }

  Future<void> _syncFlights() async {
    if (!mounted) return;
    final userId = Provider.of<SessionState>(context, listen: false).userId;
    if (userId != null && userId.isNotEmpty) {
      await syncService.syncFlights(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
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
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

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
                            // Flights section
                            _StatRow(
                              icon: Icons.flight,
                              label: 'Flights Imported',
                              value: '${report.flightsCount}',
                              valueColor: AppColors.endorsedGreen,
                            ),
                            Divider(height: 24, color: AppColors.glassDark50),
                            _StatRow(
                              icon: Icons.timer,
                              label: 'Total Flight Time',
                              value: report.formattedFlightTime,
                              valueColor: AppColors.denim,
                            ),
                            // Simulator section
                            if (report.simulatorSessionsCount > 0) ...[
                              Divider(height: 24, color: AppColors.glassDark50),
                              _StatRow(
                                icon: Icons.computer,
                                label: 'Simulator Sessions',
                                value: '${report.simulatorSessionsCount}',
                                valueColor: AppColors.endorsedGreen,
                              ),
                              Divider(height: 24, color: AppColors.glassDark50),
                              _StatRow(
                                icon: Icons.timer_outlined,
                                label: 'Simulator Time',
                                value: report.formattedSimulatorTime,
                                valueColor: AppColors.denim,
                              ),
                            ],
                            // Simulator types and registrations
                            if (report.simulatorTypesCount > 0) ...[
                              Divider(height: 24, color: AppColors.glassDark50),
                              _StatRow(
                                icon: Icons.computer,
                                label: 'Simulator Types',
                                value: '${report.simulatorTypesCount}',
                                valueColor: AppColors.white,
                              ),
                            ],
                            if (report.simulatorRegistrationsCount > 0) ...[
                              Divider(height: 24, color: AppColors.glassDark50),
                              _StatRow(
                                icon: Icons.devices,
                                label: 'Simulator Registrations',
                                value: '${report.simulatorRegistrationsCount}',
                                valueColor: AppColors.white,
                              ),
                            ],
                            // Aircraft section
                            if (report.aircraftTypesCount > 0) ...[
                              Divider(height: 24, color: AppColors.glassDark50),
                              _StatRow(
                                icon: Icons.airplanemode_active,
                                label: 'Aircraft Types',
                                value: '${report.aircraftTypesCount}',
                                valueColor: AppColors.white,
                              ),
                            ],
                            if (report.aircraftRegistrationsCount > 0) ...[
                              Divider(height: 24, color: AppColors.glassDark50),
                              _StatRow(
                                icon: Icons.confirmation_number_outlined,
                                label: 'Aircraft Registrations',
                                value: '${report.aircraftRegistrationsCount}',
                                valueColor: AppColors.white,
                              ),
                            ],
                            // Crew section
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
                                label: 'Entries Skipped',
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
                        GlassContainer(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: report.errors
                                .take(20) // Show max 20 errors to keep it manageable
                                .map((error) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        error,
                                        style: AppTypography.caption.copyWith(
                                          color: Colors.red.shade300,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        if (report.errors.length > 20)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '... and ${report.errors.length - 20} more errors',
                              style: AppTypography.caption.copyWith(
                                color: Colors.red.shade300,
                              ),
                            ),
                          ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Fixed bottom section
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Done',
                icon: Icons.check,
                fullWidth: true,
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/settings');
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Your entries are now in your logbook.',
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
