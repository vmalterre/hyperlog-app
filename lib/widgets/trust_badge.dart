import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Trust level enum for flight entries
enum TrustLevel {
  logged,   // Pilot-signed (Blue)
  tracked,  // ADS-B corroborated (Amber)
  endorsed  // Authority verified (Green)
}

/// Extension for trust level properties
extension TrustLevelExtension on TrustLevel {
  Color get color => switch (this) {
        TrustLevel.logged => AppColors.loggedBlue,
        TrustLevel.tracked => AppColors.trackedAmber,
        TrustLevel.endorsed => AppColors.endorsedGreen,
      };

  Color get backgroundColor => switch (this) {
        TrustLevel.logged => AppColors.loggedBg,
        TrustLevel.tracked => AppColors.trackedBg,
        TrustLevel.endorsed => AppColors.endorsedBg,
      };

  Color get borderColor => switch (this) {
        TrustLevel.logged => AppColors.loggedBorder,
        TrustLevel.tracked => AppColors.trackedBorder,
        TrustLevel.endorsed => AppColors.endorsedBorder,
      };

  String get label => switch (this) {
        TrustLevel.logged => 'LOGGED',
        TrustLevel.tracked => 'TRACKED',
        TrustLevel.endorsed => 'ENDORSED',
      };

  String get shortLabel => switch (this) {
        TrustLevel.logged => 'LOG',
        TrustLevel.tracked => 'TRK',
        TrustLevel.endorsed => 'END',
      };

  String get description => switch (this) {
        TrustLevel.logged => 'Pilot Signed',
        TrustLevel.tracked => 'Data Corroborated',
        TrustLevel.endorsed => 'Authority Verified',
      };

  IconData get icon => switch (this) {
        TrustLevel.logged => Icons.flight,
        TrustLevel.tracked => Icons.satellite_alt,
        TrustLevel.endorsed => Icons.verified,
      };
}

/// A pill-shaped badge showing the trust level of a flight entry
class TrustBadge extends StatelessWidget {
  final TrustLevel level;
  final bool showIcon;
  final bool compact;

  const TrustBadge({
    super.key,
    required this.level,
    this.showIcon = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: level.backgroundColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: level.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              level.icon,
              size: compact ? 10 : 12,
              color: level.color,
            ),
            SizedBox(width: compact ? 4 : 6),
          ],
          Text(
            compact ? level.shortLabel : level.label,
            style: AppTypography.badge.copyWith(color: level.color),
          ),
        ],
      ),
    );
  }
}

/// A larger trust icon for cards and detail views
class TrustIcon extends StatelessWidget {
  final TrustLevel level;
  final double size;

  const TrustIcon({
    super.key,
    required this.level,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: level.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size * 0.25),
        border: Border.all(
          color: level.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Icon(
        level.icon,
        size: size * 0.45,
        color: level.color,
      ),
    );
  }
}
