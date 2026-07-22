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