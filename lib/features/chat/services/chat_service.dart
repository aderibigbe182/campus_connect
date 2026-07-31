import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../models/chat_request_model.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/storage_service.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/reply_message_model.dart';

class ChatService {
  ChatService._();

  static final ChatService instance = ChatService._();

  String get _baseUrl => ApiConstants.baseUrl;

  Future<Map<String, String>> _headers({
    bool json = true,
  }) async {
    final token = await StorageService.getToken();

    return {
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null)
        'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _replyToJson(
    ReplyMessageModel reply,
  ) {
    return {
      'messageId': reply.messageId,
      'sender': reply.sender,
      'message': reply.message,
    };
  }
  // ==========================================================
  // GET ALL CONVERSATIONS
  // ==========================================================
  // ==========================================================
  // (Conversations methods defined later)
  // ==========================================================
  //============================
// CHAT REQUESTS
//============================

Future<void> sendChatRequest({
  required String receiverId,
}) async {
  final response = await http.post(
    Uri.parse("$_baseUrl/chat/request"),
    headers: await _headers(),
    body: jsonEncode({
      "receiverId": receiverId,
    }),
  );

  if (response.statusCode != 200 &&
      response.statusCode != 201) {
    throw Exception("Failed to send chat request");
  }
}

Future<void> acceptChatRequest({
  required String requestId,
}) async {
  final response = await http.put(
    Uri.parse(
      "$_baseUrl/chat/request/$requestId/accept",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to accept chat request");
  }
}

Future<void> declineChatRequest({
  required String requestId,
}) async {
  final response = await http.put(
    Uri.parse(
      "$_baseUrl/chat/request/$requestId/decline",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to decline chat request");
  }
}

Future<List<ChatRequestModel>> getPendingRequests() async {
  final response = await http.get(
    Uri.parse("$_baseUrl/chat/requests"),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to load requests");
  }

  final json = jsonDecode(response.body);
  final List data = json["requests"] ?? [];

  return data
      .map((e) => ChatRequestModel.fromJson(e))
      .toList();
}
//============================
// CONVERSATIONS
//============================
Future<List<ChatModel>> getChats() async {
  final response = await http.get(
    Uri.parse("$_baseUrl/chat/conversations"),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to load chats");
  }

  final json = jsonDecode(response.body);

  final List data = json["chats"] ?? [];

  return data
      .map((e) => ChatModel.fromJson(e))
      .toList();
}
Future<ChatModel> getChat(
  String conversationId,
) async {
  final response = await http.get(
    Uri.parse(
      "$_baseUrl/chat/$conversationId",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to load chat");
  }

  return ChatModel.fromJson(
    jsonDecode(response.body),
  );
}
Future<List<MessageModel>>
    getConversationMessages(
  String conversationId,
) async {
  final response = await http.get(
    Uri.parse(
      "$_baseUrl/chat/conversation/$conversationId",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to load messages",
    );
  }

  final json = jsonDecode(response.body);

  final List data =
      json["messages"] ?? [];

  return data
      .map(
        (e) =>
            MessageModel.fromJson(e),
      )
      .toList();
}
//============================
// SEND MESSAGES
//============================
Future<MessageModel> sendTextMessage({
  required String conversationId,
  required String message,
  ReplyMessageModel? reply,
}) async {
  final response = await http.post(
    Uri.parse(
      "$_baseUrl/chat/$conversationId/messages/text",
    ),
    headers: await _headers(),
    body: jsonEncode({
      "message": message,
      if (reply != null)
        "reply": _replyToJson(reply),
    }),
  );

  if (response.statusCode != 200 &&
      response.statusCode != 201) {
    throw Exception(
      "Failed to send message",
    );
  }

  return MessageModel.fromJson(
    jsonDecode(response.body),
  );
}
Future<MessageModel> sendImageMessage({
  required String conversationId,
  required File image,
  String? caption,
  ReplyMessageModel? reply,
}) async {
  final request = http.MultipartRequest(
    "POST",
    Uri.parse(
      "$_baseUrl/chat/$conversationId/messages/image",
    ),
  );

  request.headers.addAll(
    await _headers(json: false),
  );

  request.fields["caption"] =
      caption ?? "";

  if (reply != null) {
    request.fields["reply"] = jsonEncode(
      _replyToJson(reply),
    );
  }

  request.files.add(
    await http.MultipartFile.fromPath(
      "image",
      image.path,
    ),
  );

  final streamed = await request.send();

  final response =
      await http.Response.fromStream(
    streamed,
  );

  if (response.statusCode != 200 &&
      response.statusCode != 201) {
    throw Exception(
      "Failed to send image",
    );
  }

  return MessageModel.fromJson(
    jsonDecode(response.body),
  );
}
Future<MessageModel> sendVoiceMessage({
  required String conversationId,
  required File audio,
  ReplyMessageModel? reply,
}) async {
  final request = http.MultipartRequest(
    "POST",
    Uri.parse(
      "$_baseUrl/chat/$conversationId/messages/voice",
    ),
  );

  request.headers.addAll(
    await _headers(json: false),
  );

  if (reply != null) {
    request.fields["reply"] = jsonEncode(
      _replyToJson(reply),
    );
  }

  request.files.add(
    await http.MultipartFile.fromPath(
      "audio",
      audio.path,
    ),
  );

  final streamed = await request.send();

  final response =
      await http.Response.fromStream(
    streamed,
  );

  if (response.statusCode != 200 &&
      response.statusCode != 201) {
    throw Exception(
      "Failed to send voice message",
    );
  }

  return MessageModel.fromJson(
    jsonDecode(response.body),
  );
}
Future<MessageModel> sendFileMessage({
  required String conversationId,
  required File file,
  ReplyMessageModel? reply,
}) async {
  final request = http.MultipartRequest(
    "POST",
    Uri.parse(
      "$_baseUrl/chat/$conversationId/messages/file",
    ),
  );

  request.headers.addAll(
    await _headers(json: false),
  );

  if (reply != null) {
    request.fields["reply"] = jsonEncode(
      _replyToJson(reply),
    );
  }

  request.files.add(
    await http.MultipartFile.fromPath(
      "file",
      file.path,
    ),
  );

  final streamed = await request.send();

  final response =
      await http.Response.fromStream(
    streamed,
  );

  if (response.statusCode != 200 &&
      response.statusCode != 201) {
    throw Exception(
      "Failed to send file",
    );
  }

  return MessageModel.fromJson(
    jsonDecode(response.body),
  );
}
//============================
// SEND GENERIC MEDIA MESSAGE
//============================

Future<MessageModel> sendMediaMessage({
  required String conversationId,
  required String messageType,
  required String fileUrl,
  required String fileName,
  required int fileSize,
  String? caption,
}) async {
  final response = await http.post(
    Uri.parse("$_baseUrl/chat/media"),
    headers: await _headers(),
    body: jsonEncode({
      "conversationId": conversationId,
      "messageType": messageType,
      "fileUrl": fileUrl,
      "fileName": fileName,
      "fileSize": fileSize,
      "caption": caption,
    }),
  );

  if (response.statusCode != 200 &&
      response.statusCode != 201) {
    throw Exception(
      "Failed to send media message",
    );
  }

  return MessageModel.fromJson(
    jsonDecode(response.body),
  );
}
//============================
// MESSAGE ACTIONS
//============================
Future<MessageModel> editMessage({
  required String messageId,
  required String message,
}) async {
  final response = await http.put(
    Uri.parse(
      "$_baseUrl/chat/messages/$messageId",
    ),
    headers: await _headers(),
    body: jsonEncode({
      "message": message,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to edit message",
    );
  }

  return MessageModel.fromJson(
    jsonDecode(response.body),
  );
}
Future<void> deleteMessage({
  required String messageId,
}) async {
  final response = await http.delete(
    Uri.parse(
      "$_baseUrl/chat/messages/$messageId",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to delete message",
    );
  }
}
Future<MessageModel> forwardMessage({
  required String messageId,
  required String conversationId,
}) async {
  final response = await http.post(
    Uri.parse(
      "$_baseUrl/chat/messages/$messageId/forward",
    ),
    headers: await _headers(),
    body: jsonEncode({
      "conversationId": conversationId,
    }),
  );

  if (response.statusCode != 200 &&
      response.statusCode != 201) {
    throw Exception(
      "Failed to forward message",
    );
  }

  return MessageModel.fromJson(
    jsonDecode(response.body),
  );
}
Future<void> starMessage({
  required String messageId,
}) async {
  final response = await http.post(
    Uri.parse(
      "$_baseUrl/chat/messages/$messageId/star",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to star message",
    );
  }
}
Future<void> unstarMessage({
  required String messageId,
}) async {
  final response = await http.delete(
    Uri.parse(
      "$_baseUrl/chat/messages/$messageId/star",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to unstar message",
    );
  }
}
//============================
// REACTIONS
//============================
Future<void> addReaction({
  required String messageId,
  required String reaction,
}) async {
  final response = await http.post(
    Uri.parse(
      "$_baseUrl/chat/messages/$messageId/reaction",
    ),
    headers: await _headers(),
    body: jsonEncode({
      "reaction": reaction,
    }),
  );

  if (response.statusCode != 200 &&
      response.statusCode != 201) {
    throw Exception(
      "Failed to add reaction",
    );
  }
}
Future<void> removeReaction({
  required String messageId,
}) async {
  final response = await http.delete(
    Uri.parse(
      "$_baseUrl/chat/messages/$messageId/reaction",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to remove reaction",
    );
  }
}
Future<List<dynamic>> getMessageReactions({
  required String messageId,
}) async {
  final response = await http.get(
    Uri.parse(
      "$_baseUrl/chat/messages/$messageId/reactions",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to load reactions",
    );
  }

  final data = jsonDecode(response.body);

  if (data is List) {
    return data;
  }

  if (data["reactions"] != null) {
    return List<dynamic>.from(data["reactions"]);
  }

  return [];
}
//============================
// READ STATUS
//============================
Future<void> markMessageDelivered({
  required String messageId,
}) async {
  final response = await http.put(
    Uri.parse(
      "$_baseUrl/chat/messages/$messageId/delivered",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to mark message as delivered",
    );
  }
}
Future<void> markMessageSeen({
  required String messageId,
}) async {
  final response = await http.put(
    Uri.parse(
      "$_baseUrl/chat/messages/$messageId/seen",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to mark message as seen",
    );
  }
}
Future<void> markMessagesAsRead({
  required String conversationId,
}) async {
  final response = await http.put(
    Uri.parse(
      "$_baseUrl/chat/conversations/$conversationId/read",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to mark messages as read",
    );
  }
}
Future<int> getUnreadCount() async {
  final response = await http.get(
    Uri.parse(
      "$_baseUrl/chat/unread-count",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to load unread count",
    );
  }

  final data = jsonDecode(response.body);

  if (data["count"] != null) {
    return data["count"];
  }

  if (data["unreadCount"] != null) {
    return data["unreadCount"];
  }

  return 0;
}
//============================
// TYPING & PRESENCE
//============================
Future<void> sendTypingStatus({
  required String conversationId,
  required bool typing,
}) async {
  final response = await http.post(
    Uri.parse(
      "$_baseUrl/chat/$conversationId/typing",
    ),
    headers: await _headers(),
    body: jsonEncode({
      "typing": typing,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to update typing status",
    );
  }
}
Future<void> setOnline({
  required bool online,
}) async {
  final response = await http.put(
    Uri.parse(
      "$_baseUrl/chat/online",
    ),
    headers: await _headers(),
    body: jsonEncode({
      "online": online,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to update online status",
    );
  }
}
Future<void> updateLastSeen() async {
  final response = await http.put(
    Uri.parse(
      "$_baseUrl/chat/last-seen",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to update last seen",
    );
  }
}
//============================
// CHAT MANAGEMENT
//============================
Future<void> pinChat({
  required String conversationId,
}) async {
  final response = await http.post(
    Uri.parse(
      "$_baseUrl/chat/$conversationId/pin",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to pin chat",
    );
  }
}
Future<void> unpinChat({
  required String conversationId,
}) async {
  final response = await http.delete(
    Uri.parse(
      "$_baseUrl/chat/$conversationId/pin",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to unpin chat",
    );
  }
}
Future<void> archiveChat({
  required String conversationId,
}) async {
  final response = await http.post(
    Uri.parse(
      "$_baseUrl/chat/$conversationId/archive",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to archive chat",
    );
  }
}
Future<void> unarchiveChat({
  required String conversationId,
}) async {
  final response = await http.delete(
    Uri.parse(
      "$_baseUrl/chat/$conversationId/archive",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to unarchive chat",
    );
  }
}
Future<void> muteConversation({
  required String conversationId,
}) async {
  final response = await http.put(
    Uri.parse(
      "$_baseUrl/chat/conversation/$conversationId/mute",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to mute conversation",
    );
  }
}
Future<void> unmuteConversation({
  required String conversationId,
}) async {
  final response = await http.put(
    Uri.parse(
      "$_baseUrl/chat/conversation/$conversationId/unmute",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to unmute conversation",
    );
  }
}
Future<void> clearChat({
  required String conversationId,
}) async {
  final response = await http.put(
    Uri.parse(
      "$_baseUrl/chat/$conversationId/clear",
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to clear chat",
    );
  }
}
//============================
// SEARCH
//============================

Future<List<MessageModel>> searchMessages({
  required String query,
}) async {
  final response = await http.get(
    Uri.parse(
      '$_baseUrl/chat/search?query=${Uri.encodeComponent(query)}',
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to search messages');
  }

  final body = jsonDecode(response.body);

  final List data = body['messages'] ?? body;

  return data
      .map((e) => MessageModel.fromJson(e))
      .toList();
}

Future<List<MessageModel>> searchConversationMessages({
  required String conversationId,
  required String query,
}) async {
  final response = await http.get(
    Uri.parse(
      '$_baseUrl/chat/conversation/$conversationId/search?query=${Uri.encodeComponent(query)}',
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Failed to search conversation messages',
    );
  }

  final body = jsonDecode(response.body);

  final List data = body['messages'] ?? body;

  return data
      .map((e) => MessageModel.fromJson(e))
      .toList();
}
//============================
// SHARED MEDIA
//============================

Future<List<MessageModel>> getSharedMedia({
  required String conversationId,
}) async {
  final response = await http.get(
    Uri.parse(
      '$_baseUrl/chat/$conversationId/media',
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to load shared media');
  }

  final body = jsonDecode(response.body);

  final List data = body['media'] ?? body;

  return data
      .map((e) => MessageModel.fromJson(e))
      .toList();
}

//============================
// SAVE MEDIA TO PHONE
//============================

Future<String> saveMediaToPhone({
  required String messageId,
}) async {
  final response = await http.get(
    Uri.parse(
      '$_baseUrl/chat/media/$messageId/download',
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to get download link');
  }

  final body = jsonDecode(response.body);

  return body['downloadUrl'] ??
      body['url'] ??
      body['fileUrl'];
}

//============================
// MEDIA / LINKS / DOCUMENTS
//============================

Future<List<MessageModel>> getMediaLinksDocuments({
  required String conversationId,
}) async {
  final response = await http.get(
    Uri.parse(
      '$_baseUrl/chat/$conversationId/media-links-documents',
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Failed to load media, links and documents',
    );
  }

  final body = jsonDecode(response.body);

  final List data =
      body['items'] ??
      body['messages'] ??
      body;

  return data
      .map((e) => MessageModel.fromJson(e))
      .toList();
}
//============================
// BLOCK USER
//============================

Future<void> blockUser(String userId) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/chat/block/$userId'),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to block user");
  }
}

//============================
// UNBLOCK USER
//============================

Future<void> unblockUser(String userId) async {
  final response = await http.delete(
    Uri.parse('$_baseUrl/chat/unblock/$userId'),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to unblock user");
  }
}

//============================
// REPORT USER
//============================

Future<void> reportUser({
  required String userId,
  required String reason,
}) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/chat/report/$userId'),
    headers: await _headers(),
    body: jsonEncode({
      "reason": reason,
    }),
  );

  if (response.statusCode != 200 &&
      response.statusCode != 201) {
    throw Exception("Failed to report user");
  }
}

//============================
// GET RECIPIENT PROFILE
//============================

Future<Map<String, dynamic>> getRecipientProfile(
    String userId) async {
  final response = await http.get(
    Uri.parse('$_baseUrl/chat/profile/$userId'),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to load profile");
  }

  return jsonDecode(response.body);
}
//============================
// SETTINGS
//============================

Future<Map<String, dynamic>> getChatNotificationSettings(
  String conversationId,
) async {
  final response = await http.get(
    Uri.parse(
      '$_baseUrl/chat/$conversationId/notifications',
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Failed to load notification settings',
    );
  }

  return jsonDecode(response.body);
}

Future<void> updateChatNotificationSettings({
  required String conversationId,
  required Map<String, dynamic> settings,
}) async {
  final response = await http.put(
    Uri.parse(
      '$_baseUrl/chat/$conversationId/notifications',
    ),
    headers: await _headers(),
    body: jsonEncode(settings),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Failed to update notification settings',
    );
  }
}

Future<Map<String, dynamic>> getChatTheme(
  String conversationId,
) async {
  final response = await http.get(
    Uri.parse(
      '$_baseUrl/chat/$conversationId/theme',
    ),
    headers: await _headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Failed to load chat theme',
    );
  }

  return jsonDecode(response.body);
}

Future<void> updateChatTheme({
  required String conversationId,
  required String theme,
}) async {
  final response = await http.put(
    Uri.parse(
      '$_baseUrl/chat/$conversationId/theme',
    ),
    headers: await _headers(),
    body: jsonEncode({
      'theme': theme,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Failed to update chat theme',
    );
  }
}
}