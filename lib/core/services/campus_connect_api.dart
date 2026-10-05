import 'api_service.dart';

/// Route facade for endpoints that exist in the supplied Node and Python
/// backends. Python responses use {success, data}; [payload] unwraps that shape.
class CampusConnectApi {
  CampusConnectApi({ApiService? client}) : _client = client ?? ApiService();
  final ApiService _client;

  dynamic payload(dynamic value, [String? key]) {
    if (value is Map && value['data'] is Map) {
      final data = value['data'];
      return key == null ? data : data[key];
    }
    return value;
  }

  // Node / Express authentication, users, account preferences, and support.
  Future<dynamic> currentUser() => _client.get('/api/auth/me');
  Future<dynamic> updateProfile(Map<String, dynamic> body) => _client.put('/api/users/profile', body);
  Future<dynamic> userProfile(int id) => _client.get('/api/users/profile/$id');
  Future<dynamic> searchUsers(String query) => _client.get('/api/users/search', query: {'q': query});
  Future<dynamic> friends() => _client.get('/api/friends', python: true);
  Future<dynamic> friendRequests({String direction = 'received'}) =>
      _client.get('/api/friends/requests', python: true, query: {'direction': direction});
  Future<dynamic> sendFriendRequest(int receiverId) =>
      _client.post('/api/friends/requests', {'receiver_id': receiverId}, python: true);
  Future<dynamic> respondToFriendRequest(int requestId, String action) =>
      _client.patch('/api/friends/requests/$requestId', null, python: true, query: {'action': action});
  Future<dynamic> removeFriend(int friendId) => _client.delete('/api/friends/$friendId', python: true);
  Future<dynamic> privacySettings() => _client.get('/api/users/privacy-settings');
  Future<dynamic> updatePrivacy(Map<String, dynamic> body) => _client.put('/api/users/privacy-settings', body);
  Future<dynamic> storageSettings() => _client.get('/api/users/storage-settings');
  Future<dynamic> updateStorage(Map<String, dynamic> body) => _client.put('/api/users/storage-settings', body);
  Future<dynamic> sendFeedback(Map<String, dynamic> body) => _client.post('/api/users/help-feedback', body);
  Future<dynamic> myFeedback() => _client.get('/api/users/help-feedback');
  Future<dynamic> inviteSettings() => _client.get('/api/users/invite-settings');
  Future<dynamic> updateInviteSettings(Map<String, dynamic> body) =>
      _client.put('/api/users/invite-settings', body);
  Future<dynamic> createInviteLink() =>
      _client.post('/api/users/generate-invite-link', null);
  Future<dynamic> registerInviteSent(Map<String, dynamic> body) =>
      _client.post('/api/users/invite-sent', body);

  // Python / FastAPI communication backend. Paths include /api (no /v1).
  Future<dynamic> chats() async => payload(await _client.get('/api/chats', python: true), 'chats');
  Future<dynamic> chatRequests({String direction = 'received'}) async => payload(
        await _client.get('/api/chats/requests', python: true, query: {'direction': direction}),
        'requests',
      );
  Future<dynamic> messages(int chatId, {int? before, int limit = 50}) async => payload(
        await _client.get('/api/chats/$chatId/messages', python: true, query: {
          if (before != null) 'before': '$before',
          'limit': '$limit',
        }),
        'messages',
      );
  Future<dynamic> sendMessage(int chatId, Map<String, dynamic> body) async => payload(
        await _client.post('/api/chats/$chatId/messages', body, python: true),
        'message',
      );
  Future<dynamic> editMessage(int messageId, String content) async => payload(
        await _client.patch('/api/chats/messages/$messageId', {'content': content}, python: true),
        'message',
      );
  Future<dynamic> deleteMessage(int messageId, {bool forEveryone = false}) => _client.delete(
        '/api/chats/messages/$messageId',
        python: true,
        query: {'for_everyone': '$forEveryone'},
      );
  Future<dynamic> markChatRead(int chatId) => _client.post('/api/chats/$chatId/read', null, python: true);
  Future<dynamic> respondToChatRequest(int requestId, String action) => _client.patch(
        '/api/chat-requests/$requestId',
        null,
        python: true,
        query: {'action': action},
      );
  Future<dynamic> createChatRequest({required int receiverId, required String content}) async => payload(
        await _client.post('/api/chat-requests', {'receiver_id': receiverId, 'content': content}, python: true),
      );

  Future<dynamic> groups() async => payload(await _client.get('/api/groups', python: true), 'groups');
  Future<dynamic> createGroup(Map<String, dynamic> body) async => payload(
        await _client.post('/api/groups', body, python: true),
      );
  Future<dynamic> group(int groupId) async => payload(await _client.get('/api/groups/$groupId', python: true));
  Future<dynamic> addGroupMember(int groupId, int userId) => _client.post(
        '/api/groups/$groupId/members', {'user_id': userId}, python: true,
      );
  Future<dynamic> removeGroupMember(int groupId, int userId) => _client.delete(
        '/api/groups/$groupId/members/$userId', python: true,
      );
  Future<dynamic> leaveGroup(int groupId) => _client.post('/api/groups/$groupId/leave', null, python: true);

  Future<dynamic> stories() async => payload(await _client.get('/api/stories', python: true), 'stories');
  Future<dynamic> storyViewers(int storyId) async => payload(
        await _client.get('/api/stories/$storyId/viewers', python: true),
      );
  Future<dynamic> deleteStory(int storyId) => _client.delete('/api/stories/$storyId', python: true);
  Future<dynamic> callHistory() async => payload(await _client.get('/api/calls', python: true), 'calls');
  Future<dynamic> startCall({required int calleeId, required String type}) =>
      _client.post('/api/calls', {'callee_id': calleeId, 'type': type}, python: true);
  Future<dynamic> signalCall(int callId, Map<String, dynamic> signal) =>
      _client.post('/api/calls/$callId/signal', signal, python: true);
  Future<dynamic> contextualUserSearch(String query) =>
      _client.get('/api/search/users', python: true, query: {'q': query});
  Future<dynamic> messageSearch(int chatId, String query) =>
      _client.get('/api/search/messages/$chatId', python: true, query: {'q': query});
}
