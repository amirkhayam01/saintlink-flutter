/// Build-time configuration.
///
/// Supplied with `--dart-define` rather than read from a bundled file, so a
/// debug build cannot accidentally ship pointing at production, and so the
/// same source tree builds both without a checked-in secret:
///
/// ```
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
/// ```
///
/// 10.0.2.2 is how the Android emulator reaches the host machine's localhost.
class Env {
  const Env._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://saintslink.co.uk/api/v1',
  );

  /// Where the customer is sent to read the terms they accept at checkout.
  static const String termsUrl = String.fromEnvironment(
    'TERMS_URL',
    defaultValue: 'https://saintslink.co.uk/terms-and-conditions',
  );

  static const String privacyUrl = String.fromEnvironment(
    'PRIVACY_URL',
    defaultValue: 'https://saintslink.co.uk/privacy-policy',
  );

  static const String supportPhone = String.fromEnvironment(
    'SUPPORT_PHONE',
    defaultValue: '+44 7721 300053',
  );

  static const String supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'info@saintslink.co.uk',
  );

  static const String websiteUrl = String.fromEnvironment(
    'WEBSITE_URL',
    defaultValue: 'https://saintslink.co.uk',
  );

  /// True when the app is pointed at something other than the live site, which
  /// the sign-in screen surfaces so a tester never wonders which backend a
  /// booking landed in.
  static bool get isDevelopmentBackend => !apiBaseUrl.startsWith('https://saintslink.co.uk');
}
