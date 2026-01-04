import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/flight_history.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'glass_card.dart';

class FlightHistoryTimeline extends StatelessWidget {
  final List<VersionDiff> diffs;

  const FlightHistoryTimeline({
    super.key,
    required this.diffs,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: diffs.length,
      itemBuilder: (context, index) {
        final diff = diffs[index];
        final isLast = index == diffs.length - 1;

        return _buildTimelineItem(diff, isLast);
      },
    );
  }

  Widget _buildTimelineItem(VersionDiff diff, bool isLast) {
    final dateFormat = DateFormat('MMM d, yyyy HH:mm');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getDotColor(diff),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getDotColor(diff).withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.borderVisible,
                    ),
                  ),
              ],
            ),
          ),

          // Card content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with timestamp
                    Row(
                      children: [
                        Icon(
                          _getEventIcon(diff),
                          size: 16,
                          color: _getDotColor(diff),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getEventTitle(diff),
                            style: AppTypography.body.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateFormat.format(diff.timestamp),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.whiteDarker,
                          ),
                        ),
                      ],
                    ),

                    // Pilot info
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _getPilotInfo(diff),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.whiteDarker,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    // Field changes (skip for verification/endorsement upgrades - that's app-level info)
                    if (diff.changes.isNotEmpty && !diff.isVerificationUpgrade && !diff.isEndorsementUpgrade) ...[
                      const SizedBox(height: 12),
                      ...diff.changes.map((change) => _buildChangeRow(change)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDotColor(VersionDiff diff) {
    if (diff.isCreation) return AppColors.loggedBlue;
    if (diff.isDeletion) return const Color(0xFFEF4444);
    if (diff.isEndorsementUpgrade) return AppColors.endorsedGreen;
    if (diff.isVerificationUpgrade) return AppColors.trackedAmber;
    return const Color(0xFFEF4444); // Amendments in red
  }

  IconData _getEventIcon(VersionDiff diff) {
    if (diff.isCreation) return Icons.add_circle_outline;
    if (diff.isDeletion) return Icons.remove_circle_outline;
    if (diff.isEndorsementUpgrade) return Icons.verified_user;
    if (diff.isVerificationUpgrade) return Icons.satellite_alt;
    return Icons.edit_outlined;
  }

  String _getEventTitle(VersionDiff diff) {
    if (diff.isCreation) return 'Flight Created';
    if (diff.isDeletion) return 'Flight Deleted';
    if (diff.isEndorsementUpgrade) return 'Flight Endorsed';
    if (diff.isVerificationUpgrade) return 'Flight Tracked';
    return 'Flight Amended';
  }

  String _getPilotInfo(VersionDiff diff) {
    if (diff.isEndorsementUpgrade) {
      final endorsement = diff.latestEndorsement;
      if (endorsement != null) {
        return 'by ${endorsement.endorserName} - ${endorsement.endorserLicense}';
      }
    }
    if (diff.isVerificationUpgrade) {
      final verification = diff.latestVerification;
      if (verification != null) {
        return 'On ${verification.source}\nVerified by ${verification.verifiedBy}';
      }
    }
    final name = diff.pilotName ?? 'Pilot';
    final license = diff.pilotLicense ?? 'Unknown';
    return 'by $name - $license';
  }

  Widget _buildChangeRow(FieldChange change) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.nightRiderDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderVisible),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            change.displayName,
            style: AppTypography.caption.copyWith(
              color: AppColors.denim,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // Old value (struck through)
              Expanded(
                child: Text(
                  change.oldValue ?? '(empty)',
                  style: AppTypography.body.copyWith(
                    color: const Color(0xFFEF4444),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: AppColors.whiteDarker,
                ),
              ),
              // New value
              Expanded(
                child: Text(
                  change.newValue ?? '(empty)',
                  style: AppTypography.body.copyWith(
                    color: AppColors.endorsedGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
