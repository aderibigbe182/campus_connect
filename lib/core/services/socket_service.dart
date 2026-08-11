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

  void listenMessage(Function(dynamic) callback) {
    _socket?.on('new_message', callback);
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

  void listenDelivered(Function(dynamic) callback) {
    _socket?.on('messageDelivered', callback);
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

  void listenSeen(Function(dynamic) callback) {
    _socket?.on('messageSeen', callback);
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

  void listenTyping(Function(dynamic) callback) {
    _socket?.on(
    "userTyping",
    callback,
);
  }

  void listenStopTyping(Function(dynamic) callback) {
    _socket?.on(
    "userStoppedTyping",
    callback,
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

  void listenReaction(Function(dynamic) callback) {
    _socket?.on('messageReaction', callback);
  }
//================================
//FRIEND REQUESTS
//================================
void listenFriendRequestSent(
  Function(dynamic) callback,
) {
  _socket?.on(
    "friend_request_sent",
    callback,
  );
}
//================================
//FRIEND REQUEST ACCEPTED 
//================================
void listenFriendRequestAccepted(
  Function(dynamic) callback,
) {
  _socket?.on(
    "friend_request_accepted",
    callback,
  );
}
//===============================
//FRIEND REQUEST DECLINED
//===============================
void listenFriendRequestDeclined(
  Function(dynamic) callback,
) {
  _socket?.on(
    "friend_request_declined",
    callback,
  );
}
//==============================
//RELATIONSHIP UPDATED
//==============================
void listenRelationshipUpdated(
  Function(dynamic) callback,
) {
  _socket?.on(
    "relationship_updated",
    callback,
  );
}
//================================
//MESSAGE SEEN
//===================================
void listenMessageSeen(
  Function(Map<String, dynamic>) callback,
) {
  socket?.on(
    "message_seen",
    (data) => callback(
      Map<String, dynamic>.from(data),
    ),
  );
}
//================================
// CHAT LIST UPDATED
//================================

void listenChatListUpdated(
  Function(dynamic) callback,
) {
  _socket?.on(
    "chat_list_updated",
    callback,
  );
}
}