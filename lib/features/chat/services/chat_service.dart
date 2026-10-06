import '../../../core/services/api_service.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();
  final ApiService _api = ApiService();

  Map<String, dynamic> _data(dynamic response) {
    if (response is Map && response['data'] is Map) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }
    if (response is Map) return Map<String, dynamic>.from(response);
    throw const FormatException('Unexpected API response.');
  }

  List<dynamic> _list(dynamic response, String key) {
    final value = _data(response)[key];
    return value is List ? value : const [];
  }

  Future<List<ChatModel>> getChats() async {
    final rows = _list(
      await _api.get('/api/chats', python: true),
      'chats',
    ).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    for (final direction in ['received', 'sent']) {
      final requests = _list(
        await _api.get(
          '/api/chats/requests',
          python: true,
          query: {'direction': direction},
        ),
        'requests',
      );
      for (final item in requests) {
        final request = Map<String, dynamic>.from(item as Map);
        if (request['status'] != 'pending') continue;
        rows.add({
          'conversation_id': request['chat_id'],
          'conversation_type': 'private',
          'user_id': request['other_user_id'],
          'username': request['username'],
          'full_name': request['full_name'],
          'profile_picture': request['profile_picture'],
          'last_message': request['first_message'],
          'last_message_at':
              request['first_message_at'] ?? request['created_at'],
          'access_state': direction == 'sent' ? 'accepted' : 'pending',
          'request_sender_id': request['sender_id'],
        });
      }
    }
    final chats = rows.map(ChatModel.fromJson).toList();
    chats.sort(
      (a, b) => (b.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(
            a.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0),
          ),
    );
    return chats;
  }

  Future<ChatStatus> getChatStatus(int userId) async {
    final data = _data(
      await _api.get('/api/chats/status/$userId', python: true),
    );
    return ChatStatus.fromJson(data);
  }

  Future<ChatStatus> startConversation({required int userId}) async {
    final data = _data(
      await _api.post('/api/chats/direct', {'user_id': userId}, python: true),
    );
    return ChatStatus.fromJson(data);
  }

  Future<List<MessageModel>> getMessages({
    required int conversationId,
    int limit = 50,
    int offset = 0,
  }) async {
    // The API uses an exclusive message id cursor. Offset is retained for old callers.
    final data = _data(
      await _api.get(
        '/api/chats/$conversationId/messages',
        python: true,
        query: {'limit': '$limit'},
      ),
    );
    return (data['messages'] is List ? data['messages'] as List : const [])
        .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<MessageModel> sendMessage({
    required int conversationId,
    required int receiverId,
    required String content,
    int? replyToMessageId,
  }) async {
    final data = _data(
      await _api.post('/api/chats/$conversationId/messages', {
        'content': content,
        'type': 'text',
        'reply_to_message_id': ?replyToMessageId,
      }, python: true),
    );
    return MessageModel.fromJson(
      Map<String, dynamic>.from(data['message'] as Map),
    );
  }

  Future<void> resolveMessageRequest({
    required int conversationId,
    required bool accept,
  }) async {
    final action = accept ? 'accepted' : 'declined';
    for (final direction in ['received', 'sent']) {
      final data = _data(
        await _api.get(
          '/api/chats/requests',
          python: true,
          query: {'direction': direction},
        ),
      );
      final requests = data['requests'];
      if (requests is! List) continue;
      for (final item in requests) {
        final request = Map<String, dynamic>.from(item as Map);
        if ((request['chat_id'] as num?)?.toInt() == conversationId &&
            request['status'] == 'pending') {
          await _api.patch(
            '/api/chat-requests/${request['id']}',
            null,
            python: true,
            query: {'action': action},
          );
          return;
        }
      }
    }
    throw Exception('Pending chat request not found.');
  }

  Future<MessageModel> editMessage({
    required int messageId,
    required String content,
  }) async {
    final data = _data(
      await _api.patch('/api/chats/messages/$messageId', {
        'content': content,
      }, python: true),
    );
    return MessageModel.fromJson(
      Map<String, dynamic>.from(data['message'] as Map),
    );
  }

  Future<void> deleteForMe({required int messageId}) async {
    await _api.delete(
      '/api/chats/messages/$messageId',
      python: true,
      query: const {'for_everyone': 'false'},
    );
  }

  Future<void> deleteForEveryone({required int messageId}) async {
    await _api.delete(
      '/api/chats/messages/$messageId',
      python: true,
      query: const {'for_everyone': 'true'},
    );
  }

  Future<void> markRead({required int conversationId}) async {
    await _api.post('/api/chats/$conversationId/read', null, python: true);
  }

  Future<void> markDelivered({required int messageId}) async {
    throw UnsupportedError(
      'The Python backend does not expose a per-message delivered route.',
    );
  }
}

class ChatStatus {
  const ChatStatus({
    required this.status,
    required this.conversationId,
    this.requestId,
    this.requestSenderId,
    this.recipientId,
  });
  final String status;
  final int conversationId;
  final int? requestId;
  final int? requestSenderId;
  final int? recipientId;

  factory ChatStatus.fromJson(Map<String, dynamic> json) => ChatStatus(
    status:
        json['request_state']?.toString() ??
        json['status']?.toString() ??
        'none',
    conversationId:
        (json['conversation_id'] as num?)?.toInt() ??
        (json['chat_id'] as num?)?.toInt() ??
        0,
    requestId: (json['request_id'] as num?)?.toInt(),
    requestSenderId: (json['request_sender_id'] as num?)?.toInt(),
    recipientId: (json['recipient_id'] as num?)?.toInt(),
  );
}
