import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/logbook_entry.dart';
import '../models/flight_history.dart';
import '../services/flight_service.dart';
import '../services/pilot_service.dart';
import '../session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/trust_badge.dart';
import '../widgets/flight_history_timeline.dart';
import 'add_flight_screen.dart';

class FlightDetailScreen extends StatefulWidget {
  final String flightId;
  final LogbookEntry? initialEntry;

  const FlightDetailScreen({
    super.key,
    required this.flightId,
    this.initialEntry,
  });

  @override
  State<FlightDetailScreen> createState() => _FlightDetailScreenState();
}

class _FlightDetailScreenState extends State<FlightDetailScreen> {
  final FlightService _flightService = FlightService();
  final PilotService _pilotService = PilotService();

  LogbookEntry? _entry;
  List<VersionDiff>? _diffs;
  bool _isLoading = true;
  String? _error;
  int _selectedTabIndex = 0; // 0 = Details, 1 = History

  bool get _isOfficialTier {
    return Provider.of<SessionState>(context, listen: false).currentPilot?.isOfficialTier ?? false;
  }

  bool _hasLoadedData = false;

  @override
  void initState() {
    super.initState();
    _entry = widget.initialEntry;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load data after dependencies are available (for Provider access)
    if (!_hasLoadedData) {
      _hasLoadedData = true;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get pilot license for tier routing
      final pilotLicense = Provider.of<SessionState>(context, listen: false).pilotLicense;

      // Always fetch flight details
      final entry = await _flightService.getFlight(widget.flightId, pilotLicense: pilotLicense);

      // Only fetch history for official tier (standard tier doesn't have access)
      FlightHistory? history;
      if (_isOfficialTier) {
        try {
          history = await _flightService.getFlightHistory(widget.flightId);
        } catch (_) {
          // History fetch failed, continue without it
        }
      }

      // Fetch pilot name for history display (official tier only)
      String? pilotName;
      if (history != null && entry.creatorLicense != null) {
        try {
          final pilot = await _pilotService.getPilot(entry.creatorLicense!);
          pilotName = pilot.name;
        } catch (_) {
          // Pilot lookup failed, will use fallback in timeline
        }
      }

      setState(() {
        _entry = entry;
        _diffs = history != null
            ? _flightService.computeHistoryDiffs(history, pilotName: pilotName)
            : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load flight details';
        _isLoading = false;
      });
    }
  }

  void _navigateToEdit() async {
    if (_entry == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddFlightScreen(entry: _entry!),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightRiderDark,
      appBar: AppBar(
        title: Text(
          _entry?.flightNumber ?? 'Flight Details',
          style: AppTypography.h4,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _entry == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.denim),
      );
    }

    if (_error != null && _entry == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: AppTypography.body.copyWith(color: AppColors.whiteDarker)),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Retry',
              onPressed: _loadData,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildTabToggle(),
        Expanded(
          // Standard tier only sees details (no history tab)
          child: (_selectedTabIndex == 0 || !_isOfficialTier)
              ? _buildDetailsTab()
              : _buildHistoryTab(),
        ),
      ],
    );
  }

  Widget _buildTabToggle() {
    // Standard tier doesn't have access to history
    if (!_isOfficialTier) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TabButton(
              label: 'Details',
              isActive: _selectedTabIndex == 0,
              onPressed: () => setState(() => _selectedTabIndex = 0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TabButton(
              label: 'History',
              isActive: _selectedTabIndex == 1,
              onPressed: () => setState(() => _selectedTabIndex = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    if (_entry == null) return const SizedBox.shrink();

    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Route header
          GlassContainer(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _entry!.dep,
                      style: AppTypography.airportCode.copyWith(fontSize: 32),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.arrow_forward, color: AppColors.denim, size: 32),
                    ),
                    Text(
                      _entry!.dest,
                      style: AppTypography.airportCode.copyWith(fontSize: 32),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  dateFormat.format(_entry!.flightDate),
                  style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Flight details card
          GlassContainer(
            child: Column(
              children: [
                _buildDetailRow('Flight Number', _entry!.flightNumber ?? '-'),
                _buildDivider(),
                _buildDetailRow('Block Off', timeFormat.format(_entry!.blockOff)),
                _buildDetailRow('Block On', timeFormat.format(_entry!.blockOn)),
                _buildDetailRow('Flight Time', _entry!.flightTime.formatted),
                _buildDivider(),
                _buildDetailRow('Aircraft', '${_entry!.aircraftType} (${_entry!.aircraftReg})'),
                _buildDetailRow('Role', _entry!.creatorCrew?.primaryRole ?? '-'),
                _buildDetailRow('Landings', _entry!.totalLandings.total.toString()),
                if (_entry!.creatorCrew != null && _entry!.creatorCrew!.remarks.isNotEmpty) ...[
                  _buildDivider(),
                  _buildDetailRow('Remarks', _entry!.creatorCrew!.remarks),
                ],
              ],
            ),
          ),

          // Crew section - show other crew members (not the creator)
          if (_entry!.crew.where((c) => c.pilotUUID != _entry!.creatorUUID).isNotEmpty) ...[
            const SizedBox(height: 16),
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people_outline, color: AppColors.denim, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Crew',
                        style: AppTypography.label.copyWith(color: AppColors.denim),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._entry!.crew
                      .where((c) => c.pilotUUID != _entry!.creatorUUID)
                      .map((member) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.denim.withValues(alpha: 0.2),
                                  radius: 16,
                                  child: Text(
                                    (member.pilotName ?? '?')[0].toUpperCase(),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.denim,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.pilotName ?? 'Unknown',
                                        style: AppTypography.body.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        member.primaryRole,
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.whiteDarker,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                ],
              ),
            ),
          ],

          // Trust level (official tier only)
          if (_isOfficialTier) ...[
            const SizedBox(height: 16),
            GlassContainer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Verification Level',
                    style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
                  ),
                  TrustBadge(level: _entry!.trustLevel),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Amend button
          PrimaryButton(
            label: 'Amend Flight',
            onPressed: _navigateToEdit,
            icon: Icons.edit,
            fullWidth: true,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: AppTypography.body.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: AppColors.borderVisible, height: 1),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.denim),
      );
    }

    if (_diffs == null || _diffs!.isEmpty) {
      return Center(
        child: Text(
          'No history available',
          style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
        ),
      );
    }

    return FlightHistoryTimeline(diffs: _diffs!);
  }
}
