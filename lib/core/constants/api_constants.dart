class ApiConstants {
  ApiConstants._();

  static const String pythonBaseUrl =
      String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static String get pythonApi => '$pythonBaseUrl/api/v1';
}
