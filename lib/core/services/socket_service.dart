import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../features/chat/models/reply_message_model.dart';

class SocketService {
  SocketService._();

  static final SocketService instance = SocketService._();

  // ===========================================================
  // CONFIGURATION
  // ===========================================================

  static const String _serverUrl =
      'https://campus-connect-backend-6pwg.onrender.com';

  // ===========================================================
  // SOCKET
  // ===========================================================

  io.Socket? _socket;

  String? _token;

  bool _connecting = false;

  // ===========================================================
  // CONNECTION STATE
  // ===========================================================

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream =>
      _connectionController.stream;

  io.Socket? get socket => _socket;

  bool get isConnected =>
      _socket?.connected ?? false;

  bool get isConnecting =>
      _connecting;

  // ===========================================================
  // CONNECTION
  // ===========================================================

  void connect(String token) {
    // Always remember the newest token.
    _token = token;

    // ---------------------------------------------------------
    // Already connected
    // ---------------------------------------------------------
    if (_socket != null && _socket!.connected) {
      return;
    }

    // ---------------------------------------------------------
    // Connection already being established
    // ---------------------------------------------------------
    if (_connecting) {
      return;
    }

    _connecting = true;

    // ---------------------------------------------------------
    // If an old socket exists but is disconnected, completely
    // remove it before creating the new connection.
    // ---------------------------------------------------------
    if (_socket != null) {
      _disposeSocket();
    }

    // ---------------------------------------------------------
    // Create socket
    // ---------------------------------------------------------

    final socket = io.io(
      _serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({
            'token': token,
          })
          .enableReconnection()
          .setReconnectionAttempts(double.infinity)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setTimeout(10000)
          .build(),
    );

    _socket = socket;

    // ---------------------------------------------------------
    // CONNECT
    // ---------------------------------------------------------

    socket.onConnect((_) {
      _connecting = false;

      _connectionController.add(true);

      print(
        '[SocketService] Connected. Socket ID: ${socket.id}',
      );
    });

    // ---------------------------------------------------------
    // DISCONNECT
    // ---------------------------------------------------------

    socket.onDisconnect((reason) {
      _connecting = false;

      _connectionController.add(false);

      print(
        '[SocketService] Disconnected: $reason',
      );
    });

    // ---------------------------------------------------------
    // CONNECT ERROR
    // ---------------------------------------------------------

    socket.onConnectError((error) {
      _connecting = false;

      _connectionController.add(false);

      print(
        '[SocketService] Connection error: $error',
      );
    });

    // ---------------------------------------------------------
    // GENERAL SOCKET ERROR
    // ---------------------------------------------------------

    socket.onError((error) {
      print(
        '[SocketService] Socket error: $error',
      );
    });

    // ---------------------------------------------------------
    // RECONNECTING
    // ---------------------------------------------------------

    socket.on('reconnect_attempt', (attempt) {
      print(
        '[SocketService] Reconnect attempt: $attempt',
      );
    });

    // ---------------------------------------------------------
    // RECONNECTED
    // ---------------------------------------------------------

    socket.on('reconnect', (attempt) {
      _connecting = false;

      _connectionController.add(true);

      print(
        '[SocketService] Reconnected after attempt: $attempt',
      );
    });

    // ---------------------------------------------------------
    // RECONNECT ERROR
    // ---------------------------------------------------------

    socket.on('reconnect_error', (error) {
      print(
        '[SocketService] Reconnect error: $error',
      );
    });

    // ---------------------------------------------------------
    // RECONNECT FAILED
    // ---------------------------------------------------------

    socket.on('reconnect_failed', (_) {
      _connecting = false;

      _connectionController.add(false);

      print(
        '[SocketService] Reconnection failed.',
      );
    });

    // ---------------------------------------------------------
    // START CONNECTION
    // ---------------------------------------------------------

    socket.connect();
  }

  // ===========================================================
  // ENSURE CONNECTION
  // ===========================================================

  Future<bool> ensureConnected({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (isConnected) {
      return true;
    }

    final token = _token;

    if (token == null || token.isEmpty) {
      return false;
    }

    connect(token);

    if (isConnected) {
      return true;
    }

    try {
      await connectionStream
          .firstWhere((connected) => connected)
          .timeout(timeout);

      return isConnected;
    } on TimeoutException {
      return false;
    }
  }

  // ===========================================================
  // UPDATE TOKEN
  // ===========================================================

  void updateToken(String token) {
    _token = token;

    if (_socket == null) {
      return;
    }

    if (_socket!.connected) {
      return;
    }

    connect(token);
  }

  // ===========================================================
  // DISCONNECT
  // ===========================================================

  void disconnect() {
    print('[SocketService] Manual disconnect.');

    _token = null;

    _disposeSocket();

    _connectionController.add(false);
  }

  // ===========================================================
  // INTERNAL SOCKET DISPOSAL
  // ===========================================================

  void _disposeSocket() {
    final socket = _socket;

    if (socket == null) {
      return;
    }

    try {
      socket.clearListeners();
      socket.disconnect();
      socket.dispose();
    } catch (e) {
      print(
        '[SocketService] Error disposing socket: $e',
      );
    }

    _socket = null;

    _connecting = false;
  }

  // ===========================================================
  // CONVERSATIONS
  // ===========================================================

  void joinConversation(int conversationId) {
    final socket = _socket;

    if (socket == null || !socket.connected) {
      print(
        '[SocketService] Cannot join conversation $conversationId. '
        'Socket is not connected.',
      );
      return;
    }

    socket.emit(
      'joinConversation',
      conversationId,
    );

    print(
      '[SocketService] Joining conversation: $conversationId',
    );
  }

  void leaveConversation(int conversationId) {
    final socket = _socket;

    if (socket == null || !socket.connected) {
      return;
    }

    socket.emit(
      'leaveConversation',
      conversationId,
    );

    print(
      '[SocketService] Leaving conversation: $conversationId',
    );
  }

  // ===========================================================
  // ROOM JOINED
  // ===========================================================

  void listenRoomJoined(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      'roomJoined',
      callback,
    );
  }

  void removeRoomJoinedListener() {
    _socket?.off('roomJoined');
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
    final socket = _socket;

    if (socket == null || !socket.connected) {
      print(
        '[SocketService] Cannot send message. '
        'Socket is not connected.',
      );
      return;
    }

    final Map<String, dynamic> payload = {
      'conversation_id': conversationId,
      'receiverId': receiverId,
      'message': message,
      'replyTo': replyTo == null
          ? null
          : {
              'messageId': replyTo.messageId,
              'sender': replyTo.sender,
              'message': replyTo.message,
            },
    };

    socket.emit(
      'sendMessage',
      payload,
    );

    print(
      '[SocketService] Message emitted '
      '(conversation: $conversationId)',
    );
  }

  // ===========================================================
  // MESSAGE DELIVERED
  // ===========================================================

  void sendDelivered({
    required int conversationId,
    required int messageId,
  }) {
    final socket = _socket;

    if (socket == null || !socket.connected) {
      return;
    }

    socket.emit(
      'messageDelivered',
      {
        'conversationId': conversationId,
        'messageId': messageId,
      },
    );
  }

  // ===========================================================
  // MESSAGE SEEN
  // ===========================================================

  void sendSeen({
    required int conversationId,
    required int messageId,
  }) {
    final socket = _socket;

    if (socket == null || !socket.connected) {
      return;
    }

    socket.emit(
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
    final socket = _socket;

    if (socket == null || !socket.connected) {
      return;
    }

    socket.emit(
      'typing',
      {
        'conversationId': conversationId,
        'senderId': senderId,
      },
    );
  }

  // ===========================================================
  // STOP TYPING
  // ===========================================================

  void sendStopTyping(
    int conversationId,
  ) {
    final socket = _socket;

    if (socket == null || !socket.connected) {
      return;
    }

    socket.emit(
      'stopTyping',
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
    final socket = _socket;

    if (socket == null || !socket.connected) {
      return;
    }

    socket.emit(
      'messageReaction',
      {
        'conversationId': conversationId,
        'messageId': messageId,
        'emoji': emoji,
      },
    );
  }

  // ===========================================================
  // GENERIC EMIT
  // ===========================================================
  //
  // This is intentionally generic so future socket events can
  // be added without bypassing the central SocketService.
  //
  // IMPORTANT:
  // Only use event names that actually exist on the backend.
  // ===========================================================

  void emit(
    String event,
    dynamic data,
  ) {
    final socket = _socket;

    if (socket == null || !socket.connected) {
      print(
        '[SocketService] Cannot emit "$event". '
        'Socket is not connected.',
      );
      return;
    }

    socket.emit(
      event,
      data,
    );
  }

  // ===========================================================
  // LISTENER HELPERS
  // ===========================================================

  void on(
    String event,
    Function(dynamic) callback,
  ) {
    _socket?.on(
      event,
      callback,
    );
  }

  void off(
    String event,
  ) {
    _socket?.off(event);
  }

  void offCallback(
    String event,
    Function(dynamic) callback,
  ) {
    _socket?.off(
      event,
      callback,
    );
  }

  // ===========================================================
  // DISPOSE
  // ===========================================================

  void dispose() {
    _disposeSocket();

    if (!_connectionController.isClosed) {
      _connectionController.close();
    }
  }
}