/// Build-time configuration via `--dart-define`, e.g. `API_BASE_URL=http://10.0.2.2:8000/api/v1`.
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

  /// The brand's Facebook page, linked from the account screen.
  static const String facebookUrl = String.fromEnvironment(
    'FACEBOOK_URL',
    defaultValue: 'https://facebook.com/saintslinkuk',
  );

  /// Shown on sign-in so a tester knows which backend they are on.
  static bool get isDevelopmentBackend =>
      !apiBaseUrl.startsWith('https://saintslink.co.uk');
}
