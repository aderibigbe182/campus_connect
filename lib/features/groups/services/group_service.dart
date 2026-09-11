import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/services/storage_service.dart';
import '../models/group_member_model.dart';
import '../models/group_model.dart';

class GroupService {
  GroupService._();

  static final GroupService instance =
      GroupService._();

  Future<Map<String, String>> _headers() async {
    final token =
        await StorageService.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  Future<List<GroupModel>> getGroups() async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.pythonApi}/conversations/',
      ),
      headers: await _headers(),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Failed to load groups: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      return [];
    }

    return decoded
        .map(
          (item) => GroupModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where(
          (group) => group.id != 0,
        )
        .toList();
  }

  Future<GroupModel> createGroup({
    required String name,
    String? description,
    required List<int> memberIds,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConstants.pythonApi}/conversations/group',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        if (description != null &&
            description.trim().isNotEmpty)
          'description':
              description.trim(),
        'member_ids': memberIds,
      }),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Failed to create group: ${response.body}',
      );
    }

    return GroupModel.fromJson(
      Map<String, dynamic>.from(
        jsonDecode(response.body),
      ),
    );
  }

  Future<List<GroupMemberModel>>
      getGroupMembers(
    int conversationId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.pythonApi}/conversations/$conversationId',
      ),
      headers: await _headers(),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Failed to load group: ${response.body}',
      );
    }

    final decoded =
        Map<String, dynamic>.from(
      jsonDecode(response.body),
    );

    final members =
        decoded['members'];

    if (members is! List) {
      return [];
    }

    return members
        .map(
          (item) => GroupMemberModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<void> addMembers({
    required int conversationId,
    required List<int> userIds,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConstants.pythonApi}/conversations/$conversationId/members',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'user_ids': userIds,
      }),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Failed to add members: ${response.body}',
      );
    }
  }
}