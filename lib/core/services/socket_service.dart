import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'storage_service.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart' as api;

class SocketService {

  SocketService._();

  static final SocketService instance = SocketService._();

  IO.Socket? _socket;

  IO.Socket? get socket => _socket!;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {

    if (_socket != null && _socket!.connected) {

      return;

    }

    final token = await StorageService.getToken();

    _socket = IO.io(

      api.ApiConstants.baseUrl,

      IO.OptionBuilder()

          .setTransports(

            ['websocket'],

          )

          .disableAutoConnect()

          .setAuth(

            {

              "token": token,

            },

          )

          .enableReconnection()

          .setReconnectionAttempts(

            10,

          )

          .setReconnectionDelay(

            1000,

          )

          .build(),

    );

    _socket!.connect();

    _socket!.onConnect((_) {

      debugPrint("Socket Connected");

    });

    _socket!.onDisconnect((_) {

      debugPrint("Socket Disconnected");

    });

    _socket!.onConnectError((error) {

      debugPrint("Socket Error: $error");

    });

  }

  // ==========================================
  // JOIN CONVERSATION
  // ==========================================

  void joinConversation(

    int conversationId,

  ) {

    if (_socket == null) return;

    _socket!.emit(

      "joinConversation",

      conversationId,

    );

  }

  // ==========================================
  // LEAVE CONVERSATION
  // ==========================================

  void leaveConversation(

    int conversationId,

  ) {

    if (_socket == null) return;

    _socket!.emit(

      "leaveConversation",

      conversationId,

    );

  }
// ==========================================
// SEND MESSAGE
// ==========================================

void sendMessage(

  Map<String, dynamic> message,

) {

  _socket?.emit(

    "sendMessage",

    message,

  );

}

// ==========================================
// LISTEN FOR NEW MESSAGE
// ==========================================

void onNewMessage(

  Function(dynamic data) callback,

) {

  _socket?.on(

    "newMessage",

    callback,

  );

}

// ==========================================
// STOP LISTENING
// ==========================================

void removeNewMessageListener() {

  _socket?.off(

    "newMessage",

  );

}
// ==========================================
// MESSAGE DELIVERED
// ==========================================

void messageDelivered({

  required int conversationId,

  required int messageId,

}) {

  _socket?.emit(

    "messageDelivered",

    {

      "conversationId": conversationId,

      "messageId": messageId,

    },

  );

}

void onMessageDelivered(

  Function(dynamic data) callback,

) {

  _socket?.on(

    "messageDelivered",

    callback,

  );

}

void removeDeliveredListener() {

  _socket?.off(

    "messageDelivered",

  );

}
// ==========================================
// MESSAGE SEEN
// ==========================================

void messageSeen({

  required int conversationId,

  required int messageId,

}) {

  _socket?.emit(

    "messageSeen",

    {

      "conversationId": conversationId,

      "messageId": messageId,

    },

  );

}

void onMessageSeen(

  Function(dynamic data) callback,

) {

  _socket?.on(

    "messageSeen",

    callback,

  );

}

void removeSeenListener() {

  _socket?.off(

    "messageSeen",

  );

}
// ==========================================
//  // DISCONNECT
// ==========================================

  void disconnect() {

    _socket?.disconnect();

    _socket?.dispose();

    _socket = null;

  }

}
void dispose() {
  SocketService.instance.disconnect();
}