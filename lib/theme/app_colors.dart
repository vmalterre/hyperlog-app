import 'package:flutter/material.dart';

/// HyperLog brand color palette
class AppColors {
  // Primary - Denim Blue Scale
  static const Color denim = Color(0xFF025EB5);
  static const Color denimLight = Color(0xFF328DD8);
  static const Color denimLighter = Color(0xFF7DBEF4);
  static const Color denimDark = Color(0xFF00213D);

  // Neutrals - Night Rider Scale
  static const Color nightRider = Color(0xFF333333);
  static const Color nightRiderDark = Color(0xFF242526);
  static const Color nightRiderLight = Color(0xFF5D6266);

  // Whites
  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteDark = Color(0xFFD1D2D2);
  static const Color whiteDarker = Color(0xFFB1B3B4);
  static const Color aliceBlue = Color(0xFFDCEFFF);

  // Trust Level Colors
  static const Color loggedBlue = Color(0xFF3B82F6);
  static const Color trackedAmber = Color(0xFFF59E0B);
  static const Color endorsedGreen = Color(0xFF10B981);

  // Common opacity variants for glass-morphism
  static Color glass50 = nightRider.withValues(alpha: 0.5);
  static Color glassDark50 = nightRiderDark.withValues(alpha: 0.5);
  static Color glassDark85 = nightRiderDark.withValues(alpha: 0.85);
  static Color glassDark90 = nightRiderDark.withValues(alpha: 0.9);

  // Border colors
  static Color borderSubtle = white.withValues(alpha: 0.05);
  static Color borderVisible = white.withValues(alpha: 0.1);
  static Color borderStrong = white.withValues(alpha: 0.3);

  // Trust level backgrounds (15% opacity)
  static Color loggedBg = loggedBlue.withValues(alpha: 0.15);
  static Color trackedBg = trackedAmber.withValues(alpha: 0.15);
  static Color endorsedBg = endorsedGreen.withValues(alpha: 0.15);

  // Trust level borders (30% opacity)
  static Color loggedBorder = loggedBlue.withValues(alpha: 0.3);
  static Color trackedBorder = trackedAmber.withValues(alpha: 0.3);
  static Color endorsedBorder = endorsedGreen.withValues(alpha: 0.3);

  // Denim accents
  static Color denimBg = denim.withValues(alpha: 0.15);
  static Color denimBorder = denim.withValues(alpha: 0.3);
}
