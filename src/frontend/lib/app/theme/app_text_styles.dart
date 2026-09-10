import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized Material 3 Type Scale for MediKiosk.
/// Calibrated for high readability on kiosk screens (10-12" distance) and phones.
class AppTextStyles {
  AppTextStyles._();
  static final TextStyle displayLarge = GoogleFonts.alegreya(
    fontSize: 36.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static final TextStyle displayMedium = GoogleFonts.alegreya(
    fontSize: 500,
    fontWeight: FontWeight.w900,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static final TextStyle displaySmall = GoogleFonts.alegreya(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    height: 1.28,
    color: AppColors.textPrimary,
  );

  // ==========================================
  // HEADINGS (Screen titles & Section headers)
  // ==========================================
  static final TextStyle headlineLarge = GoogleFonts.alegreya(
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static final TextStyle headlineMedium = GoogleFonts.alegreya(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  static final TextStyle headlineSmall = GoogleFonts.alegreya(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ==========================================
  // TITLES (Card headers, list item titles)
  // ==========================================
  static final TextStyle titleLarge = GoogleFonts.poppins(
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static final TextStyle titleMedium = GoogleFonts.poppins(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static final TextStyle titleSmall = GoogleFonts.poppins(
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ==========================================
  // BODY (High Density Clean Data Layouts)
  // ==========================================
  static final TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static final TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static final TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.4,
    color: AppColors.textMuted,
  );

  // ==========================================
  // LABELS & BADGES (High Density Compact Badges)
  // ==========================================
  static final TextStyle labelLarge = GoogleFonts.poppins(
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static final TextStyle labelMedium = GoogleFonts.poppins(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.2,
    color: AppColors.textSecondary,
  );

  static final TextStyle labelSmall = GoogleFonts.poppins(
    fontSize: 10.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    height: 1.2,
    color: AppColors.textMuted,
  );

  // Button specific text
  static final TextStyle button = GoogleFonts.poppins(
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.onPrimary,
  );

  // ==========================================
  // TEXT THEME EXPORT
  // ==========================================
  /// Plug this into your ThemeData like so:
  /// ThemeData(textTheme: AppTextStyles.textTheme)
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}

class Textbasepo extends StatelessWidget {
  final String text;
  final FontWeight? fontWeight;
  final double? fontSize;
  final double? height;
  final double? letterSpacing; // Mapped from your 'spacing' parameter
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? max;

  const Textbasepo(
      this.text, {
        super.key,
        this.fontWeight,
        this.textAlign,
        this.fontSize,
        this.height,
        this.letterSpacing,
        this.color,
        this.overflow,
        this.max
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: max,
      style: GoogleFonts.poppins(
        fontWeight: fontWeight,
        fontSize: fontSize,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      ),
    );
  }
}