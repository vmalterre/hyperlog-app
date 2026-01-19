import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A gradient line with an airplane icon in the center
class RouteLine extends StatelessWidget {
  final double height;
  final bool showPlane;
  final double planeSize;

  const RouteLine({
    super.key,
    this.height = 2,
    this.showPlane = true,
    this.planeSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (!showPlane) {
      // Simple continuous line when no plane
      return Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.denim,
              AppColors.denimLight,
              AppColors.denim,
            ],
          ),
          borderRadius: BorderRadius.circular(height / 2),
        ),
      );
    }

    // Line with gap for airplane icon
    return Row(
      children: [
        // Left line segment
        Expanded(
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.denim,
                  AppColors.denimLight,
                ],
              ),
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
        // Gap + airplane icon + gap
        const SizedBox(width: 6),
        Icon(
          Icons.flight,
          size: planeSize,
          color: AppColors.denimLight,
        ),
        const SizedBox(width: 6),
        // Right line segment
        Expanded(
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.denimLight,
                  AppColors.denim,
                ],
              ),
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Route display with departure, line, and arrival
class RouteDisplay extends StatelessWidget {
  final String departure;
  final String arrival;
  final String? duration;
  final TextStyle? codeStyle;
  final TextStyle? durationStyle;

  const RouteDisplay({
    super.key,
    required this.departure,
    required this.arrival,
    this.duration,
    this.codeStyle,
    this.durationStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          departure,
          style: codeStyle ??
              const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              if (duration != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    duration!,
                    style: durationStyle ??
                        const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.whiteDarker,
                        ),
                  ),
                ),
              const RouteLine(),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          arrival,
          style: codeStyle ??
              const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
        ),
      ],
    );
  }
}
