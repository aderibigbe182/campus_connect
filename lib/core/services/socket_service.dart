import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../features/chat/models/reply_message_model.dart';

class SocketService {
  SocketService._();

  static final SocketService instance = SocketService._();

  io.Socket? _socket;

  io.Socket? get socket => _socket;

  bool get isConnected => _socket?.connected ?? false;

  // ===========================================================
  // CONNECTION
  // ===========================================================

  void connect(String token) {
    if (_socket != null) return;

    _socket = io.io(
      'https://campus-connect-backend-6pwg.onrender.com',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({
            'Authorization': 'Bearer $token',
          })
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Socket connected');
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
    });

    _socket!.onConnectError((e) {
      print('Socket connect error: $e');
    });

    _socket!.onError((e) {
      print('Socket error: $e');
    });
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  // ===========================================================
  // CONVERSATIONS
  // ===========================================================

  void joinConversation(int conversationId) {
    _socket?.emit('joinConversation', {
      'conversationId': conversationId,
    });
  }

  void leaveConversation(int conversationId) {
    _socket?.emit('leaveConversation', {
      'conversationId': conversationId,
    });
  }

  void listenRoomJoined([Function(dynamic)? callback]) {
    _socket?.on(
      'roomJoined',
      callback ??
          (data) {
            print('Joined room: $data');
          },
    );
  }

  // ===========================================================
  // SEND MESSAGE
  // ===========================================================

  void sendMessage({
    required int conversationId,
    required int receiverId,
    required String message,
    ReplyMessageModel? replyTo,
  }) {
    _socket?.emit(
      'sendMessage',
      {
        'conversationId': conversationId,
        'receiverId': receiverId,
        'message': message,
        'replyTo': replyTo == null
            ? null
            : {
                'messageId': replyTo.messageId,
                'sender': replyTo.sender,
                'message': replyTo.message,
              },
      },
    );
  }

  void listenMessage(Function(dynamic) callback) {
    _socket?.on('newMessage', callback);
  }

  // ===========================================================
  // DELIVERED
  // ===========================================================

  void sendDelivered({
    required int conversationId,
    required int messageId,
  }) {
    _socket?.emit(
      'message_delivered',
      {
        'conversationId': conversationId,
        'messageId': messageId,
      },
    );
  }

  void listenDelivered(Function(dynamic) callback) {
    _socket?.on('message_delivered', callback);
  }

  // ===========================================================
  // SEEN
  // ===========================================================

  void sendSeen({
    required int conversationId,
    required int messageId,
  }) {
    _socket?.emit(
      'message_seen',
      {
        'conversationId': conversationId,
        'messageId': messageId,
      },
    );
  }

  void listenSeen(Function(dynamic) callback) {
    _socket?.on('message_seen', callback);
  }

  // ===========================================================
  // TYPING
  // ===========================================================

  void sendTyping(int conversationId) {
    _socket?.emit(
      'typing',
      {
        'conversationId': conversationId,
      },
    );
  }

  void sendStopTyping(int conversationId) {
    _socket?.emit(
      'stop_typing',
      {
        'conversationId': conversationId,
      },
    );
  }

  void listenTyping(Function(dynamic) callback) {
    _socket?.on('typing', callback);
  }

  void listenStopTyping(Function(dynamic) callback) {
    _socket?.on('stop_typing', callback);
  }

  // ===========================================================
  // PRESENCE
  // ===========================================================

  void updatePresence(bool online) {
    _socket?.emit(
      'presence_update',
      {
        'online': online,
      },
    );
  }

  void listenPresence(Function(dynamic) callback) {
    _socket?.on('presence_update', callback);
  }

  // ===========================================================
  // REACTIONS
  // ===========================================================

  void sendReaction({
    required int conversationId,
    required int messageId,
    required String emoji,
  }) {
    _socket?.emit(
      'message_reaction',
      {
        'conversationId': conversationId,
        'messageId': messageId,
        'emoji': emoji,
      },
    );
  }

  void listenReaction(Function(dynamic) callback) {
    _socket?.on('message_reaction', callback);
  }
}