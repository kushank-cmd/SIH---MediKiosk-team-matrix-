import 'package:flutter/material.dart';
class AppColors {
  AppColors._();

  // ===========================================================================
  // 1. PRIMARY & ACTION COLORS
  // ===========================================================================
  /// Primary active action color (#185DF1) - buttons, active tabs, selected states
  static const Color primary = Color(0xFF185DF1);
  static const Color primaryLight = Color(0xFF4F85F6);
  static const Color primaryDark = Color(0xFF03113D);
  static const Color primaryNavy = Color(0xFF03113D);
  static const Color primaryContainer = Color(0xFFDCE8FD);
  static const Color onPrimary = Color(0xFFF3F7FE);
  static const Color onPrimaryContainer = Color(0xFF03113D);

  // ===========================================================================
  // 2. SECONDARY (Deep Ayurvedic Teal: #0C4137)
  // ===========================================================================
  /// Deep Teal for secondary buttons, AYUSH icons, and section headers
  static const Color secondary = Color(0xFF0C4137);
  static const Color secondaryLight = Color(0xFF186859);
  static const Color secondaryContainer = Color(0xFFD8ECE7);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF05221C);

  // ===========================================================================
  // 3. ACCENT & HIGHLIGHT (Mint Green: #33FFB6)
  // ===========================================================================
  /// Vibrant mint-green highlight used strictly for verified badges & success tags
  static const Color highlight = Color(0xFF33FFB6);
  static const Color onHighlight = Color(0xFF03113D);
  static const Color accent = Color(0xFF185DF1);
  static const Color accentLight = Color(0xFF4F85F6);
  static const Color accentContainer = Color(0xFFE6EFFB);
  static const Color onAccent = Color(0xFFFFFFFF);

  // ===========================================================================
  // 4. LIGHT MODE BACKGROUNDS & SURFACES
  // ===========================================================================
  /// Crisp light ice-blue background (#F3F7FE)
  static const Color background = Color(0xFFf5efeb);
  /// Light blue surface container (#E6EFFB)
  static const Color surface = Color(0xFFc8d9e6);
  /// Elevated pure white card surface for high-contrast layering on #F3F7FE
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  /// Soft variant container
  static const Color surfaceVariant = Color(0xFFDCE8FD);
  /// Light borders and dividers
  static const Color border = Color(0xFFD2E1F8);
  static const Color borderFocused = Color(0xFF185DF1);
  static const Color divider = Color(0xFFDDE8F8);

  // ===========================================================================
  // 5. DARK MODE BACKGROUNDS & SURFACES
  // ===========================================================================
  /// Deepest ink/black background layer (#101516)
  static const Color backgroundDark = Color(0xFF101516);
  /// Deep ink layer (#0B0911)
  static const Color ink = Color(0xFF0B0911);
  /// Elevated dark surface container
  static const Color surfaceDark = Color(0xFF181F22);
  static const Color surfaceVariantDark = Color(0xFF202A2E);
  static const Color borderDark = Color(0xFF283439);
  static const Color dividerDark = Color(0xFF222B2F);

  // ===========================================================================
  // 6. TYPOGRAPHY / INK
  // ===========================================================================
  /// Deep navy high-contrast text (#03113D)
  static const Color textPrimary = Color(0xFF03113D);
  static const Color textSecondary = Color(0xFF344668);
  static const Color textMuted = Color(0xFF6B7F9E);
  static const Color textOnPrimary = Color(0xFFF3F7FE);

  /// Dark mode text colors
  static const Color textPrimaryDark = Color(0xFFF3F7FE);
  static const Color textSecondaryDark = Color(0xFFB5C8E8);
  static const Color textMutedDark = Color(0xFF8294B2);

  // ===========================================================================
  // 7. SEMANTIC STATUS SIGNALS
  // ===========================================================================
  /// Success (#33FFB6 / deep clinical green)
  static const Color success = Color(0xFF059669);
  static const Color successHighlight = Color(0xFF33FFB6);
  static const Color successContainer = Color(0xFFD1FCEB);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF064E3B);

  /// Warning / Moderate Dosha
  static const Color warning = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color onWarningContainer = Color(0xFF78350F);

  /// Error / Critical Medical Flags
  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF7F1D1D);

  /// Info / OPD Advisory
  static const Color info = Color(0xFF185DF1);
  static const Color infoContainer = Color(0xFFE6EFFB);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color onInfoContainer = Color(0xFF03113D);

  // ===========================================================================
  // 8. AYUSH DOSHA CONSTITUTION COLORS
  // ===========================================================================
  /// Vata (Air/Ether) - Movement & Cognition
  static const Color doshaVata = Color(0xFF185DF1);
  static const Color doshaVataContainer = Color(0xFFE6EFFB);

  /// Pitta (Fire/Water) - Digestion & Transformation
  static const Color doshaPitta = Color(0xFFEA580C);
  static const Color doshaPittaContainer = Color(0xFFFFEDD5);

  /// Kapha (Earth/Water) - Structure & Immunity
  static const Color doshaKapha = Color(0xFF0C4137);
  static const Color doshaKaphaContainer = Color(0xFFD8ECE7);
}
