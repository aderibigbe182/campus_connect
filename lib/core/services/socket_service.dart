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
          .setAuth({
            'token': token
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
    _socket?.emit(
  "joinConversation",
  conversationId,
);
  }

  void leaveConversation(int conversationId) {
   _socket?.emit(
  "leaveConversation",
  conversationId,
);
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
  "sendMessage",
  {
    "conversation_id": conversationId,
    "receiverId": receiverId,
    "message": message,
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

  // ===========================================================
  // DELIVERED
  // ===========================================================

  void sendDelivered({
    required int conversationId,
    required int messageId,
  }) {
    _socket?.emit("messageDelivered",
      {
        'conversationId': conversationId,
        'messageId': messageId,
      },
    );
  }

  // ===========================================================
  // SEEN
  // ===========================================================

  void sendSeen({
    required int conversationId,
    required int messageId,
  }) {
    _socket?.emit(
      'messageSeen',
      {
        'conversationId': conversationId,
        'messageId': messageId,
      },
    );
  }


  // ===========================================================
  // TYPING
  // ===========================================================

  void sendTyping({
required int conversationId,
required int senderId,
}) {
  _socket?.emit(
    "typing",
    {
      "conversationId": conversationId,
      "senderId": senderId,
    },
  );
}

  void sendStopTyping(int conversationId) {
    _socket?.emit("stopTyping",
      {
        'conversationId': conversationId,
      },
    );
  }

  // ===========================================================
  // REACTIONS
  // ===========================================================

  void sendReaction({
    required int conversationId,
    required int messageId,
    required String emoji,
  }) {
    _socket?.emit("messageReaction",
      {
        'conversationId': conversationId,
        'messageId': messageId,
        'emoji': emoji,
      },
    );
  }
}