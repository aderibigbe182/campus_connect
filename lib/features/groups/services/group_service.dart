import '../../../core/services/api_service.dart';
import '../models/group_member_model.dart';
import '../models/group_model.dart';

class GroupService {
  GroupService._();
  static final GroupService instance = GroupService._();
  final ApiService _api = ApiService();

  Map<String, dynamic> _data(dynamic response) => response is Map && response['data'] is Map
      ? Map<String, dynamic>.from(response['data'] as Map)
      : Map<String, dynamic>.from(response as Map);

  Future<List<GroupModel>> getGroups() async {
    final groups = _data(await _api.get('/api/groups', python: true))['groups'];
    if (groups is! List) return [];
    return groups.map((e) => GroupModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<GroupModel> createGroup({required String name, String? description, required List<int> memberIds}) async {
    final data = _data(await _api.post('/api/groups', {
      'name': name.trim(),
      if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
      'member_ids': memberIds,
    }, python: true));
    // Current API returns the generated id only; refresh supplies the full record.
    return GroupModel(id: (data['group_id'] as num?)?.toInt() ?? 0, name: name.trim(), description: description);
  }

  Future<List<GroupMemberModel>> getGroupMembers(int conversationId) async {
    final data = _data(await _api.get('/api/groups/$conversationId', python: true));
    final members = data['members'];
    if (members is! List) return [];
    return members.map((e) => GroupMemberModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> addMembers({required int conversationId, required List<int> userIds}) async {
    for (final userId in userIds) {
      await _api.post('/api/groups/$conversationId/members', {'user_id': userId}, python: true);
    }
  }
}
