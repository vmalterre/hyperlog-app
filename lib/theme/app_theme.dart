import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// HyperLog dark theme configuration
class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.nightRider,
        colorScheme: ColorScheme.dark(
          primary: AppColors.denim,
          primaryContainer: AppColors.denimDark,
          secondary: AppColors.denimLight,
          secondaryContainer: AppColors.denimDark,
          surface: AppColors.nightRiderDark,
          error: const Color(0xFFEF4444),
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          onSurface: AppColors.whiteDark,
          onError: AppColors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          centerTitle: true,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
          iconTheme: const IconThemeData(color: AppColors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.denim,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            elevation: 0,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return AppColors.denimDark;
              }
              return null;
            }),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: const BorderSide(color: AppColors.nightRiderLight, width: 2),
            textStyle: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.denimLight,
            textStyle: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.nightRiderDark.withOpacity(0.5),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderSubtle),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.denim, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
          labelStyle: GoogleFonts.outfit(color: AppColors.whiteDarker),
          hintStyle: GoogleFonts.outfit(color: AppColors.whiteDarker),
          errorStyle: GoogleFonts.outfit(
            color: const Color(0xFFEF4444),
            fontSize: 12,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.denim,
          foregroundColor: AppColors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.borderVisible,
          thickness: 1,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.glassDark85,
          selectedItemColor: AppColors.denim,
          unselectedItemColor: AppColors.whiteDarker,
          selectedLabelStyle: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.whiteDark,
          size: 24,
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.outfit(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
          ),
          displayMedium: GoogleFonts.outfit(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
          displaySmall: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
          headlineLarge: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
          headlineMedium: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
          headlineSmall: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
          titleLarge: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
          titleMedium: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          ),
          titleSmall: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          ),
          bodyLarge: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.whiteDark,
          ),
          bodyMedium: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.whiteDark,
          ),
          bodySmall: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.whiteDarker,
          ),
          labelLarge: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
          labelMedium: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.whiteDark,
          ),
          labelSmall: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.whiteDarker,
          ),
        ),
      );
}
