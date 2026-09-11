class ApiConstants {
  ApiConstants._();

  static const String nodeBaseUrl =
      'https://campus-connect-backend-6pwg.onrender.com';

  static const String pythonBaseUrl =
      String.fromEnvironment(
    'https://campus-connect-api-meri.onrender.com',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static String get nodeApi => '$nodeBaseUrl/api';

  static String get pythonApi => '$pythonBaseUrl/api/v1';
}