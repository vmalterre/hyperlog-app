import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyperlog/models/logbook_entry_short.dart';
import 'package:hyperlog/services/api_exception.dart';
import 'package:hyperlog/services/flight_service.dart';
import 'package:hyperlog/session_state.dart';
import 'package:hyperlog/theme/app_colors.dart';
import 'package:hyperlog/theme/app_typography.dart';
import 'package:hyperlog/widgets/trust_badge.dart';
import 'package:hyperlog/widgets/trust_kpi_card.dart';
import 'package:hyperlog/widgets/trust_evolution_chart.dart';
import 'package:hyperlog/widgets/app_button.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final FlightService _flightService = FlightService();
  List<LogbookEntryShort> _flights = [];
  bool _isLoading = true;
  bool _noPilotProfile = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  String? get _pilotLicense {
    return Provider.of<SessionState>(context, listen: false).pilotLicense;
  }

  Future<void> _loadFlights() async {
    if (!mounted) return;

    final license = _pilotLicense;
    if (license == null) {
      setState(() {
        _noPilotProfile = true;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _noPilotProfile = false;
      _errorMessage = null;
    });

    try {
      final flights = await _flightService.getFlightsForPilot(license);
      if (mounted) {
        setState(() {
          _flights = flights;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    }
  }

  // Count flights by trust level
  int get loggedCount =>
      _flights.where((f) => f.trustLevel == TrustLevel.logged).length;
  int get trackedCount =>
      _flights.where((f) => f.trustLevel == TrustLevel.tracked).length;
  int get endorsedCount =>
      _flights.where((f) => f.trustLevel == TrustLevel.endorsed).length;

  // Compute cumulative chart data by month
  List<TrustChartData> get _chartData {
    if (_flights.isEmpty) return [];

    // Sort flights by date
    final sortedFlights = List<LogbookEntryShort>.from(_flights)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Group by month
    final Map<String, List<LogbookEntryShort>> byMonth = {};
    for (final flight in sortedFlights) {
      final key = '${flight.date.year}-${flight.date.month.toString().padLeft(2, '0')}';
      byMonth.putIfAbsent(key, () => []).add(flight);
    }

    // Generate all months from first to last flight
    final firstDate = sortedFlights.first.date;
    final lastDate = sortedFlights.last.date;
    final months = <DateTime>[];

    var current = DateTime(firstDate.year, firstDate.month);
    final end = DateTime(lastDate.year, lastDate.month);
    while (!current.isAfter(end)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1);
    }

    // Compute cumulative counts
    int cumulativeLogged = 0;
    int cumulativeTracked = 0;
    int cumulativeEndorsed = 0;

    return months.map((month) {
      final key = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      final monthFlights = byMonth[key] ?? [];

      for (final flight in monthFlights) {
        switch (flight.trustLevel) {
          case TrustLevel.logged:
            cumulativeLogged++;
            break;
          case TrustLevel.tracked:
            cumulativeTracked++;
            break;
          case TrustLevel.endorsed:
            cumulativeEndorsed++;
            break;
        }
      }

      return TrustChartData(
        month: month,
        cumulativeLogged: cumulativeLogged,
        cumulativeTracked: cumulativeTracked,
        cumulativeEndorsed: cumulativeEndorsed,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightRider,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadFlights,
          color: AppColors.denim,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Statistics', style: AppTypography.h2(context)),
                      const SizedBox(height: 4),
                      Text(
                        'Track your progress',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                sliver: SliverToBoxAdapter(
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_noPilotProfile) {
      return _buildEmptyState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_flights.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Cards Row
        TrustKpiRow(
          loggedCount: loggedCount,
          trackedCount: trackedCount,
          endorsedCount: endorsedCount,
        ),
        const SizedBox(height: 24),

        // Evolution Chart
        TrustEvolutionChart(data: _chartData),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.denim,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading statistics...',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.whiteDarker,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load statistics',
              style: AppTypography.h4,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SecondaryButton(
              label: 'Try Again',
              icon: Icons.refresh,
              onPressed: _loadFlights,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 64,
              color: AppColors.whiteDarker,
            ),
            const SizedBox(height: 16),
            Text(
              'No statistics yet',
              style: AppTypography.h4,
            ),
            const SizedBox(height: 8),
            Text(
              'Log some flights to see your trust level statistics',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
