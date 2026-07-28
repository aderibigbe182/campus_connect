import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  SocketService._();

  static final SocketService instance = SocketService._();

  IO.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String userId) {
    if (_socket != null) return;

    _socket = IO.io(
      'https://campus-connect-backend-6pwg.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery({'userId': userId})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Socket connected');
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // ===== Conversations =====

  void joinConversation(String conversationId) {
    _socket?.emit('joinConversation', {'conversationId': conversationId});
  }

  void leaveConversation(String conversationId) {
    _socket?.emit('leaveConversation', {'conversationId': conversationId});
  }

  // ===== Messages =====

  void sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String text,
    String messageType = 'text',
  }) {
    _socket?.emit('sendMessage', {
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'messageType': messageType,
    });
  }

  void listenMessage(void Function(dynamic data) callback) {
    _socket?.on('newMessage', callback);
  }

  // ===== Delivered =====

  void sendDelivered(String messageId) {
    _socket?.emit('messageDelivered', {'messageId': messageId});
  }

  void listenDelivered(void Function(dynamic data) callback) {
    _socket?.on('messageDelivered', callback);
  }

  // ===== Seen =====

  void sendSeen(String messageId) {
    _socket?.emit('messageSeen', {'messageId': messageId});
  }

  void listenSeen(void Function(dynamic data) callback) {
    _socket?.on('messageSeen', callback);
  }

  // ===== Typing =====

  void sendTyping(String conversationId, String userId) {
    _socket?.emit('typing', {
      'conversationId': conversationId,
      'userId': userId,
    });
  }

  void sendStopTyping(String conversationId, String userId) {
    _socket?.emit('stopTyping', {
      'conversationId': conversationId,
      'userId': userId,
    });
  }

  void listenTyping(void Function(dynamic data) callback) {
    _socket?.on('typing', callback);
  }

  void listenStopTyping(void Function(dynamic data) callback) {
    _socket?.on('stopTyping', callback);
  }

  // ===== Presence =====

  void updatePresence(bool online) {
    _socket?.emit('presenceUpdate', {'online': online});
  }

  void listenPresence(void Function(dynamic data) callback) {
    _socket?.on('presenceUpdate', callback);
  }

  // ===== Reactions =====

  void sendReaction({
    required String messageId,
    required String userId,
    required String emoji,
  }) {
    _socket?.emit('messageReaction', {
      'messageId': messageId,
      'userId': userId,
      'emoji': emoji,
    });
  }

  void listenReaction(void Function(dynamic data) callback) {
    _socket?.on('messageReaction', callback);
  }

  // ===== Room joined =====

  void listenRoomJoined(void Function(dynamic data) callback) {
    _socket?.on('roomJoined', callback);
  }
}