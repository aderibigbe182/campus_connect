import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import 'storage_service.dart';
import '../constants/api_constants.dart';
class ChatService {
  ChatService._();

  static final ChatService instance = ChatService._();

  Future<Map<String, String>> _headers() async {
    final token = await StorageService.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }
  // ==========================================
  // GET CHAT LIST
  // ==========================================
  Future<List<ChatModel>> getChats() async {
    final response = await http.get(
      Uri.parse(
        "${ApiConstants.baseUrl}/api/chat/conversations",
      ),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map(
            (e) => ChatModel.fromJson(e),
          )  
          .toList();
    }
    throw Exception("Failed to load chats");
  }
  // ==========================================
  // GET CONVERSATION
  // ==========================================
  Future<List<MessageModel>> getMessages(
    int conversationId,
  ) async {
    final response = await http.get(
      Uri.parse(
        "${ApiConstants.baseUrl}/api/chat/conversation/$conversationId",
      ),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map(
            (e) => MessageModel.fromJson(e),
          )
          .toList();
    }
    throw Exception("Failed to load messages");
  }
  // ==========================================
  // SEND MESSAGE
  // ==========================================
  Future<MessageModel> sendMessage({
    required int conversationId,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse(
        "${ApiConstants.baseUrl}/api/chat/message",
      ),
      headers: await _headers(),
      body: jsonEncode({
        "conversationId": conversationId,
        "message": message,
      }),
    );
    if (response.statusCode == 201) {
      return MessageModel.fromJson(
        jsonDecode(response.body),
      );
    }
    throw Exception("Failed to send message");
  }
  // ==========================================
  // MARK MESSAGE SEEN
  // ==========================================
  Future<void> markSeen(
    int messageId,
  ) async {
    await http.put(
      Uri.parse(
        "${ApiConstants.baseUrl}/api/message/$messageId/seen",
      ),
      headers: await _headers(),
    );
  }
  // ==========================================
  // GET CHAT REQUESTS
  // ==========================================
  Future<List<dynamic>> getRequests() async {
    final response = await http.get(
      Uri.parse(
        "${ApiConstants.baseUrl}/api/chat/requests",
      ),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Failed to load requests");
  }
  // ==========================================
  // ACCEPT REQUEST
  // ==========================================
  Future<void> acceptRequest(
    int requestId,
  ) async {
    await http.put(
      Uri.parse(
        "${ApiConstants.baseUrl}/api/chat/request/$requestId/accept",
      ),
      headers: await _headers(),
    );
  }
  // ==========================================
  // DECLINE REQUEST
  // ==========================================
  Future<void> declineRequest(
    int requestId,
  ) async {
    await http.put(
      Uri.parse(
        "${ApiConstants.baseUrl}/api/chat/request/$requestId/decline",
      ),
      headers: await _headers(),
    );
  }
}
