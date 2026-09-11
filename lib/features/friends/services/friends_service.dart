import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/services/storage_service.dart';
import '../models/friend_model.dart';
import '../models/friend_request_model.dart';
import '../models/user_search_model.dart';

class FriendsService {
  FriendsService._();

  static Future<String> _getToken() async {
    final token = await StorageService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication required.');
    }

    return token;
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();

    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> _jsonHeaders() async {
    final token = await _getToken();

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<UserSearchModel>> searchUsers(
    String query,
  ) async {
    final q = query.trim();

    if (q.isEmpty) {
      return [];
    }

    final response = await http.get(
      Uri.parse(
        '${ApiConstants.pythonApi}/users/search'
        '?q=${Uri.encodeQueryComponent(q)}',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_error(response));
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      return [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(UserSearchModel.fromJson)
        .toList();
  }

  static Future<List<FriendModel>> getFriends() async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.pythonApi}/friends',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_error(response));
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      return [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(FriendModel.fromJson)
        .toList();
  }

  static Future<FriendRequestModel> sendRequest(
    int receiverId,
  ) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConstants.pythonApi}/friend-requests/send',
      ),
      headers: await _jsonHeaders(),
      body: jsonEncode({
        'receiver_id': receiverId,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(_error(response));
    }

    return FriendRequestModel.fromJson(
      jsonDecode(response.body),
    );
  }

  static Future<List<FriendRequestModel>>
      getReceivedRequests() async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.pythonApi}/friend-requests/received',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_error(response));
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      return [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(FriendRequestModel.fromJson)
        .toList();
  }

  static Future<List<FriendRequestModel>>
      getSentRequests() async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.pythonApi}/friend-requests/sent',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_error(response));
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      return [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(FriendRequestModel.fromJson)
        .toList();
  }

  static Future<FriendRequestModel> acceptRequest(
    int requestId,
  ) async {
    final response = await http.put(
      Uri.parse(
        '${ApiConstants.pythonApi}/friend-requests/'
        '$requestId/accept',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_error(response));
    }

    return FriendRequestModel.fromJson(
      jsonDecode(response.body),
    );
  }

  static Future<FriendRequestModel> rejectRequest(
    int requestId,
  ) async {
    final response = await http.put(
      Uri.parse(
        '${ApiConstants.pythonApi}/friend-requests/'
        '$requestId/reject',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_error(response));
    }

    return FriendRequestModel.fromJson(
      jsonDecode(response.body),
    );
  }

  static Future<void> removeFriend(
    int friendId,
  ) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiConstants.pythonApi}/friends/$friendId',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(_error(response));
    }
  }

  static String _error(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded['detail']?.toString() ??
            decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            'Request failed.';
      }
    } catch (_) {}

    return response.body.isEmpty
        ? 'Request failed (${response.statusCode}).'
        : response.body;
  }
}