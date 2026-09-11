import 'package:flutter/material.dart';

/// The app's colours, taken from the website's design tokens rather than
/// invented here.
///
/// The site's rule is one accent and one neutral: brand gold (the logo's own
/// #facc15) against zinc, with midnight reserved for large dark surfaces. Gold
/// on white fails contrast for text, so it is used as a surface with dark text
/// on it — never as a text colour on a light ground.
///
/// Colours that mean the same thing on either ground live here as constants.
/// Colours that depend on the ground — text, borders, cards — live in
/// [AppColors] and are read through `context.colors`.
class AppTheme {
  const AppTheme._();

  static const brand = Color(0xFFFACC15);
  static const brandDark = Color(0xFFCA8A04);
  static const midnight = Color(0xFF020617);
  static const danger = Color(0xFFDC2626);
  static const success = Color(0xFF15803D);

  static ThemeData light() => _build(AppColors.light, Brightness.light);

  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    /*
     * The primary button is midnight on the light ground and gold on the dark
     * one: midnight on midnight would vanish, and gold with dark text is the
     * site's own dark-mode treatment of its call to action.
     */
    final primaryButton = isDark ? brand : midnight;
    final onPrimaryButton = isDark ? midnight : Colors.white;
    const buttonText = TextStyle(fontFamily: 'Figtree', fontSize: 16, fontWeight: FontWeight.w600);

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      // The website's typeface, bundled so the app and the site read as one.
      fontFamily: 'Figtree',
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryButton,
        onPrimary: onPrimaryButton,
        secondary: brand,
        onSecondary: midnight,
        surface: colors.card,
        onSurface: colors.ink,
        error: danger,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: colors.surface,
      extensions: [colors],
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme.apply(bodyColor: colors.ink, displayColor: colors.ink), colors),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.card,
        foregroundColor: colors.ink,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge!.copyWith(fontSize: 18, fontWeight: FontWeight.w700, color: colors.ink),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryButton,
          foregroundColor: onPrimaryButton,
          disabledBackgroundColor: colors.inkFaint,
          disabledForegroundColor: colors.inkMuted,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.ink,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: colors.inkFaint),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: _inputBorder(colors.inkFaint),
        enabledBorder: _inputBorder(colors.inkFaint),
        focusedBorder: _inputBorder(isDark ? brand : midnight, width: 1.6),
        errorBorder: _inputBorder(danger),
        focusedErrorBorder: _inputBorder(danger, width: 1.6),
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.inkFaint),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.ink, textStyle: buttonText.copyWith(fontSize: 14)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: brand,
        foregroundColor: midnight,
        elevation: 3,
        focusElevation: 3,
        hoverElevation: 3,
        highlightElevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        extendedTextStyle: buttonText.copyWith(fontSize: 15),
      ),
      dividerTheme: DividerThemeData(color: colors.inkFaint, space: 1, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? colors.inkFaint : midnight,
        contentTextStyle: TextStyle(color: isDark ? colors.ink : Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Derived with copyWith so every style keeps the family and falls back the
  /// same way; a bare TextStyle here would silently drop back to Roboto.
  static TextTheme _textTheme(TextTheme t, AppColors colors) => t.copyWith(
        headlineMedium: t.headlineMedium!.copyWith(fontSize: 28, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.5),
        titleLarge: t.titleLarge!.copyWith(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.2),
        titleMedium: t.titleMedium!.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
        bodyMedium: t.bodyMedium!.copyWith(fontSize: 15, height: 1.4),
        bodySmall: t.bodySmall!.copyWith(fontSize: 13, height: 1.4, color: colors.inkMuted),
      );

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

/// The ground-dependent palette: zinc on white by day, the inverse by night.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.surface,
    required this.card,
    required this.errorSurface,
    required this.errorBorder,
    required this.errorText,
  });

  static const light = AppColors(
    ink: Color(0xFF18181B),
    inkMuted: Color(0xFF71717A),
    inkFaint: Color(0xFFE4E4E7),
    surface: Color(0xFFFAFAFA),
    card: Colors.white,
    errorSurface: Color(0xFFFEF2F2),
    errorBorder: Color(0xFFFECACA),
    errorText: Color(0xFF991B1B),
  );

  static const dark = AppColors(
    ink: Color(0xFFF4F4F5),
    inkMuted: Color(0xFFA1A1AA),
    inkFaint: Color(0xFF3F3F46),
    surface: Color(0xFF09090B),
    card: Color(0xFF18181B),
    errorSurface: Color(0xFF2A1215),
    errorBorder: Color(0xFF7F1D1D),
    errorText: Color(0xFFFCA5A5),
  );

  /// Body text.
  final Color ink;

  /// Secondary text: helper lines, captions, labels.
  final Color inkMuted;

  /// Borders and dividers.
  final Color inkFaint;

  /// The scaffold ground.
  final Color surface;

  /// Cards, inputs, app bar, bottom action bar.
  final Color card;

  final Color errorSurface;
  final Color errorBorder;
  final Color errorText;

  /// The one shadow the app uses, on cards that float over the hero or the
  /// ground. Softer and larger than Material's default elevation.
  List<BoxShadow> get floatingShadow => [
        BoxShadow(color: Colors.black.withValues(alpha: surface.computeLuminance() > 0.5 ? 0.10 : 0.5), blurRadius: 28, offset: const Offset(0, 12)),
      ];

  @override
  AppColors copyWith({
    Color? ink,
    Color? inkMuted,
    Color? inkFaint,
    Color? surface,
    Color? card,
    Color? errorSurface,
    Color? errorBorder,
    Color? errorText,
  }) {
    return AppColors(
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkFaint: inkFaint ?? this.inkFaint,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      errorSurface: errorSurface ?? this.errorSurface,
      errorBorder: errorBorder ?? this.errorBorder,
      errorText: errorText ?? this.errorText,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;

    return AppColors(
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      inkFaint: Color.lerp(inkFaint, other.inkFaint, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      errorSurface: Color.lerp(errorSurface, other.errorSurface, t)!,
      errorBorder: Color.lerp(errorBorder, other.errorBorder, t)!,
      errorText: Color.lerp(errorText, other.errorText, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
