import 'package:flutter/material.dart';

/// The app's colours, taken from the website's design tokens rather than
/// invented here.
///
/// The site's rule is one accent and one neutral: brand gold (the logo's own
/// #facc15) against zinc, with midnight reserved for large dark surfaces. Gold
/// on white fails contrast for text, so it is used as a surface with dark text
/// on it — never as a text colour on a light ground.
class AppTheme {
  const AppTheme._();

  static const brand = Color(0xFFFACC15);
  static const brandDark = Color(0xFFCA8A04);
  static const midnight = Color(0xFF020617);
  static const ink = Color(0xFF18181B);
  static const inkMuted = Color(0xFF71717A);
  static const inkFaint = Color(0xFFE4E4E7);
  static const surface = Color(0xFFFAFAFA);
  static const danger = Color(0xFFDC2626);
  static const success = Color(0xFF15803D);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: midnight,
        onPrimary: Colors.white,
        secondary: brand,
        onSecondary: midnight,
        surface: Colors.white,
        onSurface: ink,
        error: danger,
      ),
      scaffoldBackgroundColor: surface,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: midnight,
          foregroundColor: Colors.white,
          disabledBackgroundColor: inkFaint,
          disabledForegroundColor: inkMuted,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: inkFaint),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: _inputBorder(inkFaint),
        enabledBorder: _inputBorder(inkFaint),
        focusedBorder: _inputBorder(midnight, width: 1.6),
        errorBorder: _inputBorder(danger),
        focusedErrorBorder: _inputBorder(danger, width: 1.6),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: inkFaint),
        ),
      ),
      dividerTheme: const DividerThemeData(color: inkFaint, space: 1, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: midnight,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  /// The colour a booking status should read as.
  ///
  /// Red is reserved for things that are wrong, per the site's token rules, so
  /// only a cancellation gets it — an unpaid booking is merely pending.
  static Color statusColor(String status) => switch (status) {
        'confirmed' || 'completed' => success,
        'cancelled' || 'refunded' => danger,
        _ => brandDark,
      };
}
