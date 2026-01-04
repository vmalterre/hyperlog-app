import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'trust_badge.dart';
import 'glass_card.dart';

/// A KPI card displaying a trust level count with glass-morphism styling
class TrustKpiCard extends StatelessWidget {
  final TrustLevel trustLevel;
  final int count;

  const TrustKpiCard({
    super.key,
    required this.trustLevel,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
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
                  color: trustLevel.color,
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
                        color: trustLevel.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: trustLevel.color.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        trustLevel.icon,
                        size: 18,
                        color: trustLevel.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Count value
                    Text(
                      count.toString(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: trustLevel.color,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Label
                    Text(
                      trustLevel.label,
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
      ),
    );
  }
}

/// A row of 3 KPI cards for the statistics screen
class TrustKpiRow extends StatelessWidget {
  final int loggedCount;
  final int trackedCount;
  final int endorsedCount;

  const TrustKpiRow({
    super.key,
    required this.loggedCount,
    required this.trackedCount,
    required this.endorsedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TrustKpiCard(
          trustLevel: TrustLevel.logged,
          count: loggedCount,
        ),
        const SizedBox(width: 12),
        TrustKpiCard(
          trustLevel: TrustLevel.tracked,
          count: trackedCount,
        ),
        const SizedBox(width: 12),
        TrustKpiCard(
          trustLevel: TrustLevel.endorsed,
          count: endorsedCount,
        ),
      ],
    );
  }
}
