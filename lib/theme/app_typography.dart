import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// HyperLog typography system using Outfit (primary) and JetBrains Mono (data)
class AppTypography {
  // Headings
  static TextStyle h1(BuildContext context) => GoogleFonts.outfit(
        fontSize: _clamp(context, 48, 80, 0.06),
        fontWeight: FontWeight.w800,
        height: 1.05,
        letterSpacing: -0.48,
        color: AppColors.white,
      );

  static TextStyle h2(BuildContext context) => GoogleFonts.outfit(
        fontSize: _clamp(context, 32, 48, 0.04),
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.32,
        color: AppColors.white,
      );

  static TextStyle get h3 => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.16,
        color: AppColors.white,
      );

  static TextStyle get h4 => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.white,
      );

  // Body text
  static TextStyle get bodyLarge => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        height: 1.7,
        color: AppColors.whiteDark,
      );

  static TextStyle get body => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: AppColors.whiteDark,
      );

  static TextStyle get bodySmall => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: AppColors.whiteDark,
      );

  static TextStyle get caption => GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.whiteDarker,
      );

  // UI Elements
  static TextStyle get button => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  static TextStyle get buttonSmall => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  static TextStyle get navItem => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.32,
        color: AppColors.whiteDark,
      );

  static TextStyle get label => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.6,
        color: AppColors.denimLight,
      );

  static TextStyle get badge => GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      );

  // Monospace (Data Display) - JetBrains Mono
  static TextStyle get statValue => GoogleFonts.jetBrainsMono(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.denimLight,
      );

  static TextStyle get statValueSmall => GoogleFonts.jetBrainsMono(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.denimLight,
      );

  static TextStyle get airportCode => GoogleFonts.jetBrainsMono(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  static TextStyle get airportCodeSmall => GoogleFonts.jetBrainsMono(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  static TextStyle get flightDetail => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.whiteDark,
      );

  static TextStyle get timestamp => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.whiteDarker,
      );

  static TextStyle get dataSmall => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.whiteDark,
      );

  // Helper for fluid typography (similar to CSS clamp)
  static double _clamp(
      BuildContext context, double min, double max, double vwFactor) {
    final width = MediaQuery.of(context).size.width;
    final preferred = width * vwFactor;
    return preferred.clamp(min, max);
  }
}
