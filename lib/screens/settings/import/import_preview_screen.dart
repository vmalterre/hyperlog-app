import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // Expandable section states
  bool _flightsExpanded = false;
  bool _aircraftExpanded = false;
  bool _simulatorsExpanded = false;
  bool _crewExpanded = false;
  bool _showAllFlights = false;

  // Expansion state for nested types within Aircraft/Simulators sections
  final Set<String> _expandedAircraftTypes = {};
  final Set<String> _expandedSimTypes = {};

  // Computed values
  late ImportTotals _totals;
  // Map of aircraft type → list of registrations for that type
  late Map<String, List<String>> _aircraftByType;
  // Map of sim type → list of registrations for that type
  late Map<String, List<String>> _simsByType;
  late int _flightCount;
  late int _flightTimeMinutes;
  late int _simCount;
  late int _simTimeMinutes;

  @override
  void initState() {
    super.initState();
    // Select all new crew members by default
    _selectedNewCrew = Set.from(widget.analysis.newCrewMembers);

    // Compute totals from ready flights
    _totals = ImportTotals.fromFlights(widget.analysis.ready);

    // Build grouped data structures and count flights vs sims
    final aircraftByType = <String, Set<String>>{};
    final simsByType = <String, Set<String>>{};
    int flightCount = 0;
    int flightTime = 0;
    int simCount = 0;
    int simTime = 0;

    for (final flight in widget.analysis.ready) {
      if (flight.isSimulator) {
        simCount++;
        simTime += flight.timeTotal;
        // Group by aircraftType (the sim type, e.g., "A320 FFS")
        if (flight.aircraftType.isNotEmpty) {
          simsByType.putIfAbsent(flight.aircraftType, () => {});
          if (flight.simReg != null && flight.simReg!.isNotEmpty) {
            simsByType[flight.aircraftType]!.add(flight.simReg!);
          }
        }
      } else {
        flightCount++;
        flightTime += flight.timeTotal;
        // Group by aircraft type
        if (flight.aircraftType.isNotEmpty) {
          aircraftByType.putIfAbsent(flight.aircraftType, () => {});
          if (flight.aircraftReg != null && flight.aircraftReg!.isNotEmpty) {
            aircraftByType[flight.aircraftType]!.add(flight.aircraftReg!);
          }
        }
      }
    }

    _flightCount = flightCount;
    _flightTimeMinutes = flightTime;
    _simCount = simCount;
    _simTimeMinutes = simTime;

    // Convert to sorted lists, adding "Unknown reg" for empty sets
    _aircraftByType = Map.fromEntries(
      aircraftByType.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    ).map((k, v) => MapEntry(k, v.isEmpty ? ['Unknown reg'] : (v.toList()..sort())));

    _simsByType = Map.fromEntries(
      simsByType.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    ).map((k, v) => MapEntry(k, v.isEmpty ? ['Unknown reg'] : (v.toList()..sort())));
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

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins.toString().padLeft(2, '0')}m';
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
                  // 1. Summary Card (at the very top)
                  GlassContainer(
                    child: Column(
                      children: [
                        // Flights ready to import
                        if (_flightCount > 0)
                          _SummaryRow(
                            icon: Icons.flight,
                            iconColor: AppColors.endorsedGreen,
                            label: '$_flightCount flights ready to import',
                            subtitle: _formatMinutes(_flightTimeMinutes),
                          ),
                        // Simulators ready to import
                        if (_simCount > 0) ...[
                          if (_flightCount > 0) const SizedBox(height: 12),
                          _SummaryRow(
                            icon: Icons.desktop_windows,
                            iconColor: const Color(0xFF8B5CF6),
                            label: '$_simCount simulator sessions ready to import',
                            subtitle: _formatMinutes(_simTimeMinutes),
                          ),
                        ],
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

                  // 2. Totals Verification Section
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text('VERIFY YOUR TOTALS', style: AppTypography.label),
                  ),
                  _TotalsVerificationSection(totals: _totals),
                  const SizedBox(height: 24),

                  // 3. Expandable Sections
                  // Flights Section
                  if (analysis.ready.isNotEmpty) ...[
                    _ExpandableSection(
                      icon: Icons.flight,
                      title: 'Flights',
                      count: analysis.ready.length,
                      isExpanded: _flightsExpanded,
                      onToggle: () => setState(() => _flightsExpanded = !_flightsExpanded),
                      child: _buildFlightsList(analysis.ready),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Aircraft Section (nested: types → registrations)
                  if (_aircraftByType.isNotEmpty) ...[
                    _ExpandableSection(
                      icon: Icons.airplanemode_active,
                      title: 'Aircraft',
                      count: _aircraftByType.length,
                      isExpanded: _aircraftExpanded,
                      onToggle: () => setState(() => _aircraftExpanded = !_aircraftExpanded),
                      child: Column(
                        children: _aircraftByType.entries.map((entry) {
                          final type = entry.key;
                          final regs = entry.value;
                          final isTypeExpanded = _expandedAircraftTypes.contains(type);
                          return _TypeRow(
                            icon: Icons.airplanemode_active,
                            typeName: type,
                            registrations: regs,
                            isExpanded: isTypeExpanded,
                            onToggle: () => setState(() {
                              if (isTypeExpanded) {
                                _expandedAircraftTypes.remove(type);
                              } else {
                                _expandedAircraftTypes.add(type);
                              }
                            }),
                            chipType: _ChipType.aircraftReg,
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Simulators Section (nested: sim types → registrations)
                  if (_simsByType.isNotEmpty) ...[
                    _ExpandableSection(
                      icon: Icons.desktop_windows,
                      title: 'Simulators',
                      count: _simsByType.length,
                      isExpanded: _simulatorsExpanded,
                      onToggle: () => setState(() => _simulatorsExpanded = !_simulatorsExpanded),
                      child: Column(
                        children: _simsByType.entries.map((entry) {
                          final simType = entry.key;
                          final regs = entry.value;
                          final isTypeExpanded = _expandedSimTypes.contains(simType);
                          return _TypeRow(
                            icon: Icons.desktop_windows,
                            typeName: simType,
                            registrations: regs,
                            isExpanded: isTypeExpanded,
                            onToggle: () => setState(() {
                              if (isTypeExpanded) {
                                _expandedSimTypes.remove(simType);
                              } else {
                                _expandedSimTypes.add(simType);
                              }
                            }),
                            chipType: _ChipType.simReg,
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Crew Members Section (only if new crew detected)
                  if (analysis.newCrewMembers.isNotEmpty) ...[
                    _ExpandableSection(
                      icon: Icons.people,
                      title: 'Crew Members',
                      count: analysis.newCrewMembers.length,
                      isExpanded: _crewExpanded,
                      onToggle: () => setState(() => _crewExpanded = !_crewExpanded),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select crew members to add to your saved pilots.',
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
                    label: 'Import ${analysis.ready.length} ${analysis.ready.length == 1 ? 'Entry' : 'Entries'}',
                    icon: Icons.download,
                    fullWidth: true,
                    isLoading: _isImporting,
                    onPressed: analysis.ready.isNotEmpty ? _executeImport : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Entries will be added to your Standard tier logbook.',
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

  Widget _buildFlightsList(List<ImportFlightPreview> flights) {
    const int initialLimit = 100;
    final bool hasMore = flights.length > initialLimit;
    final displayedFlights = _showAllFlights ? flights : flights.take(initialLimit).toList();

    return Column(
      children: [
        ...displayedFlights.map((flight) => _FlightPreviewTile(flight: flight)),
        if (hasMore && !_showAllFlights) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _showAllFlights = true),
              icon: const Icon(Icons.expand_more, size: 18),
              label: Text(
                'Show all ${flights.length} flights',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.denim,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.denim,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Totals verification section with KPI grid
class _TotalsVerificationSection extends StatelessWidget {
  final ImportTotals totals;

  const _TotalsVerificationSection({required this.totals});

  @override
  Widget build(BuildContext context) {
    // KPI data matching the plan layout
    final kpis = [
      _KpiData(Icons.schedule, totals.totalFormatted, 'TOTAL', AppColors.denim),
      _KpiData(Icons.airline_seat_recline_extra, totals.picFormatted, 'PIC', AppColors.endorsedGreen),
      _KpiData(Icons.supervisor_account, totals.picusFormatted, 'PICUS', const Color(0xFF8B5CF6)),
      _KpiData(Icons.airline_seat_recline_normal, totals.sicFormatted, 'SIC', AppColors.trackedAmber),
      _KpiData(Icons.groups, totals.multiPilotFormatted, 'MULTI-PILOT', const Color(0xFF0EA5E9)),
      _KpiData(Icons.nightlight_round, totals.nightFormatted, 'NIGHT', const Color(0xFF6366F1)),
      _KpiData(Icons.cloud, totals.ifrFormatted, 'IFR TOTAL', const Color(0xFF8B5CF6)),
      _KpiData(Icons.school, totals.dualFormatted, 'DUAL', const Color(0xFF10B981)),
      _KpiData(Icons.record_voice_over, totals.instructorFormatted, 'INSTRUCTOR', const Color(0xFFF59E0B)),
      _KpiData(Icons.flight_land, totals.landingsFormatted, 'LANDINGS', AppColors.denim),
    ];

    return Column(
      children: [
        for (int i = 0; i < kpis.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i < kpis.length - 2 ? 12 : 0),
            child: Row(
              children: [
                Expanded(
                  child: _ImportKpiCard(
                    icon: kpis[i].icon,
                    value: kpis[i].value,
                    label: kpis[i].label,
                    accentColor: kpis[i].color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ImportKpiCard(
                    icon: kpis[i + 1].icon,
                    value: kpis[i + 1].value,
                    label: kpis[i + 1].label,
                    accentColor: kpis[i + 1].color,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _KpiData {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  _KpiData(this.icon, this.value, this.label, this.color);
}

/// KPI card for import totals (similar to ExperienceKpiCard)
class _ImportKpiCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;

  const _ImportKpiCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.glass50,
            AppColors.glassDark50,
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Accent bar at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                color: accentColor,
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Value
                  Text(
                    value,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Label
                  Text(
                    label,
                    style: AppTypography.label.copyWith(
                      color: AppColors.whiteDarker,
                      fontSize: 9,
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

/// Expandable section with icon, title, count badge, and chevron
class _ExpandableSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  const _ExpandableSection({
    required this.icon,
    required this.title,
    required this.count,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.denim, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.body.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _CountBadge(count: count),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.chevron_right,
                      color: AppColors.whiteDarker,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(height: 1, color: AppColors.glassDark50),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: child,
                ),
              ],
            ),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

/// Small count badge pill
class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.denim.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.denim.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        count.toString(),
        style: AppTypography.caption.copyWith(
          color: AppColors.denim,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum _ChipType {
  aircraftType,
  aircraftReg,
  simReg,
}

/// Chip for aircraft type, registration, or simulator registration
class _TypeChip extends StatelessWidget {
  final String label;
  final _ChipType chipType;

  const _TypeChip({
    required this.label,
    this.chipType = _ChipType.aircraftType,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;

    switch (chipType) {
      case _ChipType.aircraftType:
        color = AppColors.denim;
        icon = Icons.airplanemode_active;
        break;
      case _ChipType.aircraftReg:
        color = AppColors.endorsedGreen;
        icon = Icons.confirmation_number;
        break;
      case _ChipType.simReg:
        color = const Color(0xFF8B5CF6);
        icon = Icons.desktop_windows;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// A row showing a type name with count, expandable to reveal registrations
class _TypeRow extends StatelessWidget {
  final IconData icon;
  final String typeName;
  final List<String> registrations;
  final bool isExpanded;
  final VoidCallback onToggle;
  final _ChipType chipType;

  const _TypeRow({
    required this.icon,
    required this.typeName,
    required this.registrations,
    required this.isExpanded,
    required this.onToggle,
    required this.chipType,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = chipType == _ChipType.simReg
        ? const Color(0xFF8B5CF6)
        : AppColors.denim;

    return Column(
      children: [
        // Type header row
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    typeName,
                    style: AppTypography.body.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${registrations.length} ${registrations.length == 1 ? "reg" : "regs"}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.whiteDarker,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.chevron_right,
                    color: AppColors.whiteDarker,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Expanded registrations
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(left: 28, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: registrations
                    .map((reg) => _TypeChip(label: reg, chipType: chipType))
                    .toList(),
              ),
            ),
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        // Divider between types
        Divider(height: 1, color: AppColors.glassDark50),
      ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.glassDark50, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Date
          SizedBox(
            width: 85,
            child: Text(
              flight.flightDate,
              style: AppTypography.caption.copyWith(
                color: AppColors.whiteDarker,
              ),
            ),
          ),
          // Route
          Expanded(
            child: Text(
              flight.route,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Aircraft
          SizedBox(
            width: 50,
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
            width: 55,
            child: Text(
              flight.formattedFlightTime,
              style: AppTypography.caption.copyWith(
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
