class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.45.100:8000',
  );

  static const int dogId = int.fromEnvironment('DOG_ID', defaultValue: 1);

  static const Duration requestTimeout = Duration(seconds: 5);
  static const Duration dashboardRefreshInterval = Duration(seconds: 5);
}
