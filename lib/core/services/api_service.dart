import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'storage_service.dart';

/// Shared authenticated JSON transport. Endpoint paths are relative to the
/// selected service origin; Python paths already include their /api prefix.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<dynamic> get(
    String endpoint, {
    bool python = false,
    Map<String, String>? query,
  }) => _request('GET', endpoint, python: python, query: query);

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic>? data, {
    bool python = false,
  }) => _request('POST', endpoint, python: python, body: data);

  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic>? data, {
    bool python = false,
  }) => _request('PUT', endpoint, python: python, body: data);

  Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic>? data, {
    bool python = false,
    Map<String, String>? query,
  }) => _request('PATCH', endpoint, python: python, body: data, query: query);

  Future<dynamic> delete(
    String endpoint, {
    bool python = false,
    Map<String, String>? query,
  }) => _request('DELETE', endpoint, python: python, query: query);

  Future<dynamic> _request(
    String method,
    String endpoint, {
    bool python = false,
    Map<String, dynamic>? body,
    Map<String, String>? query,
    bool authenticated = true,
  }) async {
    final origin = python ? ApiConstants.pythonBaseUrl : ApiConstants.nodeBaseUrl;
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final uri = Uri.parse('$origin$path').replace(queryParameters: query);
    final token = authenticated ? await StorageService.getToken() : null;
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    late http.Response response;
    switch (method) {
      case 'GET':
        response = await _client.get(uri, headers: headers);
        break;
      case 'POST':
        response = await _client.post(uri, headers: headers, body: body == null ? null : jsonEncode(body));
        break;
      case 'PUT':
        response = await _client.put(uri, headers: headers, body: body == null ? null : jsonEncode(body));
        break;
      case 'PATCH':
        response = await _client.patch(uri, headers: headers, body: body == null ? null : jsonEncode(body));
        break;
      case 'DELETE':
        response = await _client.delete(uri, headers: headers);
        break;
      default:
        throw ArgumentError.value(method, 'method', 'Unsupported HTTP method');
    }
    final decoded = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, _message(decoded, response));
    }
    return decoded;
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } on FormatException {
      return response.body;
    }
  }

  String _message(dynamic value, http.Response response) {
    if (value is Map) {
      return (value['message'] ?? value['detail'] ?? value['error'] ?? 'Request failed').toString();
    }
    return value is String && value.isNotEmpty ? value : 'Request failed (${response.statusCode})';
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;
  @override
  String toString() => message;
}
