class ApiConstants {
  ApiConstants._();

  static const String nodeBaseUrl = String.fromEnvironment(
    'https://campus-connect-backend-6pwg.onrender.com',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const String pythonBaseUrl = String.fromEnvironment(
    'https://campus-connect-backend-ep6d.onrender.com',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static String get nodeApi => '$nodeBaseUrl/api';
  static String get pythonApi => pythonBaseUrl;
  // Kept for existing app code that previously used this property.
  static String get baseUrl => nodeBaseUrl;
}
