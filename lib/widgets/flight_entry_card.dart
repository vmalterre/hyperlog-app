import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'trust_badge.dart';
import 'route_line.dart';

/// A card displaying a flight entry with route, timing, and trust level
class FlightEntryCard extends StatefulWidget {
  final String departureCode;
  final String arrivalCode;
  final String blockTime;
  final DateTime date;
  final String aircraftType;
  final String aircraftReg;
  final TrustLevel trustLevel;
  final bool showTrustBadge;
  final bool isSimSession;
  final VoidCallback? onTap;

  const FlightEntryCard({
    super.key,
    required this.departureCode,
    required this.arrivalCode,
    required this.blockTime,
    required this.date,
    required this.aircraftType,
    required this.aircraftReg,
    this.trustLevel = TrustLevel.logged,
    this.showTrustBadge = true,
    this.isSimSession = false,
    this.onTap,
  });

  @override
  State<FlightEntryCard> createState() => _FlightEntryCardState();
}

class _FlightEntryCardState extends State<FlightEntryCard> {
  bool _isPressed = false;

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(_isPressed ? 4 : 0, 0, 0),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isPressed
                ? (widget.isSimSession ? AppColors.simulatorBorder : AppColors.denimBorder)
                : AppColors.borderSubtle,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with date and trust badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(widget.date),
                  style: AppTypography.timestamp,
                ),
                if (widget.showTrustBadge) TrustBadge(level: widget.trustLevel),
              ],
            ),
            const SizedBox(height: 16),

            // Route display
            if (widget.isSimSession)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.simulatorBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'SIM',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.simulatorPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            widget.blockTime,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.whiteDarker,
                            ),
                          ),
                        ),
                        RouteLine(isSimSession: true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.simulatorBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'SIM',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.simulatorPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              )
            else
              RouteDisplay(
                departure: widget.departureCode,
                arrival: widget.arrivalCode,
                duration: widget.blockTime,
                isSimSession: widget.isSimSession,
                codeStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
                durationStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.whiteDarker,
                ),
              ),
            const SizedBox(height: 16),

            // Aircraft/Simulator info row
            Row(
              children: [
                Icon(
                  widget.isSimSession ? Icons.desktop_mac : Icons.airplanemode_active,
                  size: 14,
                  color: AppColors.whiteDarker,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.aircraftType,
                  style: AppTypography.caption,
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.whiteDarker,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.aircraftReg,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.whiteDarker,
                  ),
                ),
                const Spacer(),
                if (widget.onTap != null)
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.whiteDarker,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact version of the flight entry for lists
class FlightEntryCompact extends StatelessWidget {
  final String departureCode;
  final String arrivalCode;
  final String blockTime;
  final TrustLevel trustLevel;
  final bool showTrustBadge;
  final VoidCallback? onTap;

  const FlightEntryCompact({
    super.key,
    required this.departureCode,
    required this.arrivalCode,
    required this.blockTime,
    this.trustLevel = TrustLevel.logged,
    this.showTrustBadge = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Text(
              departureCode,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward,
              size: 12,
              color: AppColors.denimLight,
            ),
            const SizedBox(width: 8),
            Text(
              arrivalCode,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            const Spacer(),
            Text(
              blockTime,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.whiteDarker,
              ),
            ),
            if (showTrustBadge) ...[
              const SizedBox(width: 12),
              TrustBadge(level: trustLevel, compact: true, showIcon: false),
            ],
          ],
        ),
      ),
    );
  }
}
