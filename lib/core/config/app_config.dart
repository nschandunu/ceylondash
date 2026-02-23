class AppConfig {
  AppConfig._();

  /// Base URL of the CeylonDash Node.js REST API.
  /// - Android emulator  → http://10.0.2.2:3000
  /// - iOS simulator     → http://127.0.0.1:3000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
  static const Duration requestTimeout = Duration(seconds: 15);
}
