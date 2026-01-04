import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hyperlog/models/logbook_entry_short.dart';
import 'package:hyperlog/screens/add_flight_screen.dart';
import 'package:hyperlog/screens/flight_detail_screen.dart';
import 'package:hyperlog/services/api_exception.dart';
import 'package:hyperlog/services/flight_service.dart';
import 'package:hyperlog/session_state.dart';
import 'package:hyperlog/theme/app_colors.dart';
import 'package:hyperlog/theme/app_typography.dart';
import 'package:hyperlog/widgets/glass_card.dart';
import 'package:hyperlog/widgets/flight_entry_card.dart';
import 'package:hyperlog/widgets/app_button.dart';

class LogbookScreen extends StatefulWidget {
  const LogbookScreen({super.key});

  @override
  State<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'This Month', 'This Year'];

  // API integration
  final FlightService _flightService = FlightService();
  List<LogbookEntryShort> _logbookEntries = [];
  bool _isLoading = true;
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
        _errorMessage = 'No pilot profile found. Please complete registration.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final flights = await _flightService.getFlightsForPilot(license);
      if (mounted) {
        setState(() {
          _logbookEntries = flights;
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

  // Calculate stats from loaded entries
  int get totalFlights => _logbookEntries.length;

  String get totalHours {
    int totalMinutes = 0;
    for (var entry in _logbookEntries) {
      if (entry.blockTime != null) {
        final parts = entry.blockTime!.split(':');
        if (parts.length == 2) {
          totalMinutes += int.parse(parts[0]) * 60 + int.parse(parts[1]);
        }
      }
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }

  // Filter entries based on selection and sort by date descending
  List<LogbookEntryShort> get _filteredEntries {
    final now = DateTime.now();
    List<LogbookEntryShort> filtered;
    switch (_selectedFilter) {
      case 1: // This Month
        filtered = _logbookEntries
            .where((e) => e.date.year == now.year && e.date.month == now.month)
            .toList();
        break;
      case 2: // This Year
        filtered = _logbookEntries.where((e) => e.date.year == now.year).toList();
        break;
      default: // All
        filtered = List.from(_logbookEntries);
    }
    // Sort by date descending (most recent first)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Logbook', style: AppTypography.h2(context)),
                          const SizedBox(height: 4),
                          Text(
                            'Your flight history',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      _AddEntryButton(
                        onPressed: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddFlightScreen(),
                            ),
                          );
                          if (result == true) {
                            _loadFlights();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Stats card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            label: 'TOTAL FLIGHTS',
                            value: _isLoading ? '-' : totalFlights.toString(),
                            icon: Icons.flight_takeoff,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 60,
                          color: AppColors.borderVisible,
                        ),
                        Expanded(
                          child: _StatItem(
                            label: 'TOTAL HOURS',
                            value: _isLoading ? '-:-' : totalHours,
                            icon: Icons.schedule,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Filter tabs
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_filters.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index < _filters.length - 1 ? 12 : 0,
                          ),
                          child: TabButton(
                            label: _filters[index],
                            isActive: _selectedFilter == index,
                            onPressed: () {
                              setState(() {
                                _selectedFilter = index;
                              });
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // Content: loading, error, empty, or list
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                sliver: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return SliverToBoxAdapter(child: _buildLoadingState());
    }

    if (_errorMessage != null) {
      return SliverToBoxAdapter(child: _buildErrorState());
    }

    final entries = _filteredEntries;
    if (entries.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = entries[index];
          return FlightEntryCard(
            departureCode: entry.depIata,
            arrivalCode: entry.desIata,
            blockTime: entry.blockTime ?? '--:--',
            date: entry.date,
            aircraftType: entry.acftType,
            aircraftReg: entry.acftReg,
            trustLevel: entry.trustLevel,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FlightDetailScreen(
                    flightId: entry.id,
                  ),
                ),
              );
              // Refresh list in case flight was amended
              _loadFlights();
            },
          );
        },
        childCount: entries.length,
      ),
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
              'Loading flights...',
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
              'Failed to load flights',
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
              Icons.flight_outlined,
              size: 64,
              color: AppColors.whiteDarker,
            ),
            const SizedBox(height: 16),
            Text(
              'No flights yet',
              style: AppTypography.h4,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button above to add your first flight',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.denimLight),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.label.copyWith(fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.denimLight,
          ),
        ),
      ],
    );
  }
}

class _AddEntryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddEntryButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 22,
      padding: EdgeInsets.zero,
      borderColor: AppColors.denim.withValues(alpha: 0.3),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.add, color: AppColors.denimLight),
        iconSize: 24,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      ),
    );
  }
}
