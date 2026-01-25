import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/import_models.dart';
import '../../../services/import_service.dart';
import '../../../session_state.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/glass_card.dart';
import 'import_report_screen.dart';

/// Screen showing import analysis preview
class ImportPreviewScreen extends StatefulWidget {
  final ImportAnalysis analysis;

  const ImportPreviewScreen({super.key, required this.analysis});

  @override
  State<ImportPreviewScreen> createState() => _ImportPreviewScreenState();
}

class _ImportPreviewScreenState extends State<ImportPreviewScreen> {
  bool _isImporting = false;
  String? _error;
  final _importService = ImportService();

  // Track which new crew members to create
  late Set<String> _selectedNewCrew;

  @override
  void initState() {
    super.initState();
    // Select all new crew members by default
    _selectedNewCrew = Set.from(widget.analysis.newCrewMembers);
  }

  Future<void> _executeImport() async {
    final session = Provider.of<SessionState>(context, listen: false);
    final userId = session.currentPilot?.id;

    if (userId == null) {
      setState(() {
        _error = 'No user logged in';
      });
      return;
    }

    setState(() {
      _isImporting = true;
      _error = null;
    });

    try {
      final report = await _importService.executeImport(
        userId: userId,
        provider: widget.analysis.provider,
        flights: widget.analysis.ready,
        createCrewMembers: _selectedNewCrew.toList(),
      );

      if (mounted) {
        // Replace current screen with report screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ImportReportScreen(report: report),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _importService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysis = widget.analysis;
    final dateFormat = DateFormat('MMM d, y');

    return Scaffold(
      backgroundColor: AppColors.nightRider,
      appBar: AppBar(
        backgroundColor: AppColors.nightRider,
        elevation: 0,
        title: Text('Import Preview', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary card
                  GlassContainer(
                    child: Column(
                      children: [
                        // Ready to import
                        _SummaryRow(
                          icon: Icons.check_circle,
                          iconColor: AppColors.endorsedGreen,
                          label: '${analysis.ready.length} flights ready to import',
                          subtitle: analysis.summary.formattedFlightTime,
                        ),
                        if (analysis.summary.dateFrom != null &&
                            analysis.summary.dateTo != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${dateFormat.format(analysis.summary.dateFrom!)} - ${dateFormat.format(analysis.summary.dateTo!)}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.whiteDarker,
                            ),
                          ),
                        ],
                        if (analysis.needsAttention.isNotEmpty) ...[
                          Divider(height: 24, color: AppColors.glassDark50),
                          _SummaryRow(
                            icon: Icons.warning_amber,
                            iconColor: AppColors.trackedAmber,
                            label: '${analysis.needsAttention.length} flights need attention',
                            onTap: () => _showIssuesDialog(context, analysis.needsAttention),
                          ),
                        ],
                        if (analysis.duplicates.isNotEmpty) ...[
                          Divider(height: 24, color: AppColors.glassDark50),
                          _SummaryRow(
                            icon: Icons.content_copy,
                            iconColor: AppColors.whiteDarker,
                            label: '${analysis.duplicates.length} duplicates will be skipped',
                            onTap: () => _showDuplicatesDialog(context, analysis.duplicates),
                          ),
                        ],
                        if (analysis.parseErrors.isNotEmpty) ...[
                          Divider(height: 24, color: AppColors.glassDark50),
                          _SummaryRow(
                            icon: Icons.error,
                            iconColor: Colors.red,
                            label: '${analysis.parseErrors.length} parse errors',
                            onTap: () => _showErrorsDialog(context, analysis.parseErrors),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // New crew members section
                  if (analysis.newCrewMembers.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text('NEW CREW MEMBERS', style: AppTypography.label),
                    ),
                    GlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'These crew members will be added to your saved pilots.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.whiteDarker,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...analysis.newCrewMembers.map((name) => _CrewCheckbox(
                                name: name,
                                isSelected: _selectedNewCrew.contains(name),
                                onChanged: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedNewCrew.add(name);
                                    } else {
                                      _selectedNewCrew.remove(name);
                                    }
                                  });
                                },
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Flight preview list
                  if (analysis.ready.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text('FLIGHTS TO IMPORT', style: AppTypography.label),
                    ),
                    GlassContainer(
                      padding: const EdgeInsets.all(0),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: analysis.ready.length > 10 ? 10 : analysis.ready.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: AppColors.glassDark50,
                        ),
                        itemBuilder: (context, index) {
                          final flight = analysis.ready[index];
                          return _FlightPreviewTile(flight: flight);
                        },
                      ),
                    ),
                    if (analysis.ready.length > 10) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '+ ${analysis.ready.length - 10} more flights',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.whiteDarker,
                          ),
                        ),
                      ),
                    ],
                  ],

                  // Error display
                  if (_error != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: AppTypography.bodySmall.copyWith(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom action bar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.nightRiderDark,
              border: Border(
                top: BorderSide(color: AppColors.glassDark50),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    label: 'Import ${analysis.ready.length} Flights',
                    icon: Icons.download,
                    fullWidth: true,
                    isLoading: _isImporting,
                    onPressed: analysis.ready.isNotEmpty ? _executeImport : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Flights will be added to your Standard tier logbook.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.whiteDarker,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showIssuesDialog(BuildContext context, List<ImportIssue> issues) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text('Issues', style: AppTypography.h4),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              return ListTile(
                leading: Icon(
                  issue.severity == IssueSeverity.error
                      ? Icons.error
                      : issue.severity == IssueSeverity.warning
                          ? Icons.warning_amber
                          : Icons.info_outline,
                  color: issue.severity == IssueSeverity.error
                      ? Colors.red
                      : issue.severity == IssueSeverity.warning
                          ? AppColors.trackedAmber
                          : AppColors.denim,
                ),
                title: Text(
                  'Row ${issue.rowIndex}',
                  style: AppTypography.body,
                ),
                subtitle: Text(
                  issue.message,
                  style: AppTypography.caption,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDuplicatesDialog(BuildContext context, List<ImportDuplicate> duplicates) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text('Duplicates', style: AppTypography.h4),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: duplicates.length,
            itemBuilder: (context, index) {
              final dup = duplicates[index];
              return ListTile(
                leading: const Icon(
                  Icons.content_copy,
                  color: AppColors.whiteDarker,
                ),
                title: Text(
                  '${dup.flightDate} ${dup.route}',
                  style: AppTypography.body,
                ),
                subtitle: Text(
                  dup.reason,
                  style: AppTypography.caption,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorsDialog(BuildContext context, List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightRiderDark,
        title: Text('Parse Errors', style: AppTypography.h4),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: errors.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.error, color: Colors.red),
                title: Text(
                  errors[index],
                  style: AppTypography.bodySmall,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Summary row widget
class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SummaryRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.body.copyWith(color: AppColors.white),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.whiteDarker,
                  ),
                ),
            ],
          ),
        ),
        if (onTap != null)
          const Icon(Icons.chevron_right, color: AppColors.whiteDarker),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Crew member checkbox
class _CrewCheckbox extends StatelessWidget {
  final String name;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const _CrewCheckbox({
    required this.name,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? AppColors.denim : AppColors.whiteDarker,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: AppTypography.body.copyWith(
                  color: isSelected ? AppColors.white : AppColors.whiteDarker,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Flight preview tile
class _FlightPreviewTile extends StatelessWidget {
  final ImportFlightPreview flight;

  const _FlightPreviewTile({required this.flight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Date
          SizedBox(
            width: 80,
            child: Text(
              flight.flightDate,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.whiteDarker,
              ),
            ),
          ),
          // Route
          Expanded(
            child: Text(
              flight.route,
              style: AppTypography.body.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Aircraft
          SizedBox(
            width: 60,
            child: Text(
              flight.aircraftType,
              style: AppTypography.caption.copyWith(
                color: AppColors.whiteDarker,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Duration
          SizedBox(
            width: 60,
            child: Text(
              flight.formattedFlightTime,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.denim,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
