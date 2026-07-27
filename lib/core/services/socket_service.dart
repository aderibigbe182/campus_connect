import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static final SocketService instance =
      SocketService._();

  SocketService._();

  io.Socket? socket;

  void connect(String token) {
    socket ??= io.io(
      'https://campus-connect-backend-6pwg.onrender.com',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({
            "token": token,
          })
          .build(),
    );

    socket!.connect();
  }

  void disconnect() {
    socket?.disconnect();
  }

  bool get connected =>
      socket?.connected ?? false;
}
void joinConversation(int conversationId) {
  socket?.emit(
    'join_conversation',
    {
      'conversationId': conversationId,
    },
  );
}

void leaveConversation(int conversationId) {
  socket?.emit(
    'leave_conversation',
    {
      'conversationId': conversationId,
    },
  );
}
void listenRoomJoined() {
  socket?.on(
    'joined_conversation',
    (data) {
      print(
        'Joined room: ${data["conversationId"]}',
      );
    },
  );
}
void sendTyping(
  int conversationId,
) {
  socket?.emit(
    "typing",
    {
      "conversationId": conversationId,
    },
  );
}

void sendStopTyping(
  int conversationId,
) {
  socket?.emit(
    "stop_typing",
    {
      "conversationId": conversationId,
    },
  );
}
void listenTyping(
  void Function(dynamic data) callback,
) {
  socket?.on(
    "typing",
    callback,
  );
}

void listenStopTyping(
  void Function(dynamic data) callback,
) {
  socket?.on(
    "stop_typing",
    callback,
  );
}
void listenMessage(
  void Function(dynamic data) callback,
) {
  socket?.on(
    "new_message",
    callback,
  );
}
void sendMessage({
  required int conversationId,
  required int receiverId,
  required String message,
  dynamic replyTo,
}) {
  socket?.emit(
    "send_message",
    {
      "conversationId": conversationId,
      "receiverId": receiverId,
      "message": message,
      "replyTo": replyTo,
    },
  );
}
socket.listenMessage((data) {

  final incoming =
      MessageModel.fromJson(data);

  final pendingIndex =
      messages.indexWhere(
    (m) =>
        m.sending &&
        m.senderId ==
            incoming.senderId &&
        m.message ==
            incoming.message,
  );

  setState(() {

    if (pendingIndex != -1) {

      messages[pendingIndex] =
          incoming;

    } else {

      messages.insert(
        0,
        incoming,
      );
      _markMessagesSeen();
socket.socket?.emit(
  "message_delivered",
  {
    "messageId": incoming.id,
    "conversationId":
        widget.conversationId,
  },
);
    }

  });

  _scrollToBottom();

});
void listenDelivered(
  void Function(dynamic data) callback,
) {
  socket?.on(
    "message_delivered",
    callback,
  );
}
socket.listenDelivered((data) {

  final id = data["messageId"];

  final index =
      messages.indexWhere(
        (m) => m.id == id,
      );

  if (index == -1) return;

  if (!mounted) return;

  setState(() {

    messages[index] =
        messages[index].copyWith(
      delivered: true,
      sending: false,
    );

  });

});
void listenSeen(
  void Function(dynamic data) callback,
) {
  socket?.on(
    "message_seen",
    callback,
  );
}
void sendSeen({
  required int conversationId,
  required int messageId,
}) {
  socket?.emit(
    "message_seen",
    {
      "conversationId": conversationId,
      "messageId": messageId,
    },
  );
}
socket.listenSeen((data) {

  final id = data["messageId"];

  final index =
      messages.indexWhere(
    (m) => m.id == id,
  );

  if (index == -1) return;

  if (!mounted) return;

  setState(() {

    messages[index] =
        messages[index].copyWith(
      seen: true,
    );

  });

});
void listenPresence(
  void Function(dynamic data) callback,
) {
  socket?.on(
    "presence_changed",
    callback,
  );
}
void updatePresence(bool online) {
  socket?.emit(
    "presence",
    {
      "online": online,
    },
  );
}