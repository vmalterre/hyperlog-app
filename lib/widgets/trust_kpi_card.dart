import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'trust_badge.dart';

/// A KPI card displaying a trust level percentage with glass-morphism styling
class TrustKpiCard extends StatelessWidget {
  final TrustLevel trustLevel;
  final double percentage;
  final double labelScale;

  const TrustKpiCard({
    super.key,
    required this.trustLevel,
    required this.percentage,
    this.labelScale = 1.0,
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
                    // Percentage value
                    Text(
                      '${percentage.round()}%',
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
                        fontSize: 10 * labelScale,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      softWrap: false,
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

  int get _totalCount => loggedCount + trackedCount + endorsedCount;

  double _percentage(int count) {
    if (_totalCount == 0) return 0;
    return (count / _totalCount) * 100;
  }

  // Calculate label scale based on available card width
  double _calculateLabelScale(double rowWidth) {
    // Card width = (rowWidth - 2 gaps of 12px) / 3 cards
    final cardWidth = (rowWidth - 24) / 3;
    // Available text width = card width - horizontal padding (32px)
    final availableWidth = cardWidth - 32;

    // Measure actual width of "ENDORSED" (longest label) at base font size
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'ENDORSED',
        style: AppTypography.label.copyWith(fontSize: 10),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final neededWidth = textPainter.width;
    if (availableWidth >= neededWidth) return 1.0;
    return (availableWidth / neededWidth).clamp(0.6, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final labelScale = _calculateLabelScale(constraints.maxWidth);

        return Row(
          children: [
            TrustKpiCard(
              trustLevel: TrustLevel.logged,
              percentage: _percentage(loggedCount),
              labelScale: labelScale,
            ),
            const SizedBox(width: 12),
            TrustKpiCard(
              trustLevel: TrustLevel.tracked,
              percentage: _percentage(trackedCount),
              labelScale: labelScale,
            ),
            const SizedBox(width: 12),
            TrustKpiCard(
              trustLevel: TrustLevel.endorsed,
              percentage: _percentage(endorsedCount),
              labelScale: labelScale,
            ),
          ],
        );
      },
    );
  }
}
