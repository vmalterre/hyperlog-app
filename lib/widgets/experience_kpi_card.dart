import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/experience_totals.dart';

/// A KPI card for experience metrics with glass-morphism styling
class ExperienceKpiCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;

  const ExperienceKpiCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.accentColor = const Color(0xFF025EB5), // AppColors.denim
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
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Value
                  Text(
                    value,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Label
                  Text(
                    label,
                    style: AppTypography.label.copyWith(
                      color: AppColors.whiteDarker,
                      fontSize: 10,
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

/// Grid of experience KPI cards (2 columns)
class ExperienceKpiGrid extends StatelessWidget {
  final ExperienceTotals totals;

  const ExperienceKpiGrid({
    super.key,
    required this.totals,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _CardData(Icons.schedule, totals.totalFormatted, 'TOTAL TIME', AppColors.denim),
      _CardData(Icons.airline_seat_recline_extra, totals.picFormatted, 'PIC', AppColors.endorsedGreen),
      _CardData(Icons.airline_seat_recline_normal, totals.sicFormatted, 'SIC', AppColors.trackedAmber),
      _CardData(Icons.school, totals.dualFormatted, 'DUAL', const Color(0xFF8B5CF6)),
      _CardData(Icons.nightlight_round, totals.nightFormatted, 'NIGHT', const Color(0xFF6366F1)),
      _CardData(Icons.cloud, totals.ifrFormatted, 'IFR', const Color(0xFF8B5CF6)),
      _CardData(Icons.wb_sunny, totals.dayLandings.toString(), 'DAY LANDINGS', AppColors.trackedAmber),
      _CardData(Icons.nightlight, totals.nightLandings.toString(), 'NIGHT LANDINGS', const Color(0xFF6366F1)),
      _CardData(Icons.flight, totals.jetFormatted, 'JET', const Color(0xFF0EA5E9)),
      _CardData(Icons.flight_takeoff, totals.gaPistonFormatted, 'GA / PISTON', AppColors.endorsedGreen),
    ];

    return Column(
      children: [
        for (int i = 0; i < cards.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i < cards.length - 2 ? 12 : 0),
            child: Row(
              children: [
                Expanded(
                  child: ExperienceKpiCard(
                    icon: cards[i].icon,
                    value: cards[i].value,
                    label: cards[i].label,
                    accentColor: cards[i].color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ExperienceKpiCard(
                    icon: cards[i + 1].icon,
                    value: cards[i + 1].value,
                    label: cards[i + 1].label,
                    accentColor: cards[i + 1].color,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CardData {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  _CardData(this.icon, this.value, this.label, this.color);
}
