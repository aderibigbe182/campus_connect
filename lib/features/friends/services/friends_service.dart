import '../../../core/services/api_service.dart';
import '../models/friend_model.dart';
import '../models/friend_request_model.dart';
import '../models/user_search_model.dart';

class FriendsService {
  static final ApiService _api = ApiService();

  static Map<String, dynamic> _data(dynamic response) => response is Map && response['data'] is Map
      ? Map<String, dynamic>.from(response['data'] as Map)
      : Map<String, dynamic>.from(response as Map);

  static List<dynamic> _items(dynamic response, String key) {
    final value = _data(response)[key];
    return value is List ? value : const [];
  }

  static Future<List<UserSearchModel>> searchUsers(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final response = await _api.get('/api/search/users', python: true, query: {'q': q});
    return _items(response, 'users')
        .map((e) => UserSearchModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  static Future<List<FriendModel>> getFriends() async => _items(
        await _api.get('/api/friends', python: true), 'friends')
      .map((e) => FriendModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();

  static Future<FriendRequestModel> sendRequest(int receiverId) async {
    final data = _data(await _api.post('/api/friends/requests', {'receiver_id': receiverId}, python: true));
    return FriendRequestModel.fromJson(Map<String, dynamic>.from(data['request'] as Map));
  }

  static Future<List<FriendRequestModel>> getReceivedRequests() async => _requests('received');
  static Future<List<FriendRequestModel>> getSentRequests() async => _requests('sent');

  static Future<List<FriendRequestModel>> _requests(String direction) async => _items(
        await _api.get('/api/friends/requests', python: true, query: {'direction': direction}), 'requests')
      .map((e) => FriendRequestModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();

  static Future<FriendRequestModel> acceptRequest(int requestId) => _respond(requestId, 'accepted');
  static Future<FriendRequestModel> rejectRequest(int requestId) => _respond(requestId, 'rejected');

  static Future<FriendRequestModel> _respond(int requestId, String action) async {
    final response = await _api.patch('/api/friends/requests/$requestId', null,
        python: true, query: {'action': action});
    final data = _data(response);
    return FriendRequestModel.fromJson(Map<String, dynamic>.from(data['request'] as Map));
  }

  static Future<void> removeFriend(int friendId) async {
    await _api.delete('/api/friends/$friendId', python: true);
  }
}
