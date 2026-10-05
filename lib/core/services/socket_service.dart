import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  SocketService._();

  static final SocketService instance = SocketService._();

  // ============================================================
  // CONFIG
  // ============================================================

  static const String _baseUrl =
      'https://campus-connect-backend-6pwg.onrender.com';

  // ============================================================
  // SOCKET
  // ============================================================

  io.Socket? _socket;

  String? _token;

  Future<bool>? _connectionFuture;

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  // ============================================================
  // PUBLIC GETTERS
  // ============================================================

  io.Socket? get socket => _socket;

  bool get isConnected => _socket?.connected ?? false;

  Stream<bool> get connectionStream => _connectionController.stream;

  // ============================================================
  // CONNECT
  // ============================================================

  Future<bool> connect(String token) async {
    final cleanToken = token.trim();

    if (cleanToken.isEmpty) {
      print('[SocketService] Cannot connect: token is empty.');
      return false;
    }

    _token = cleanToken;

    // Already connected.
    if (_socket != null && _socket!.connected) {
      return true;
    }

    // Another connection attempt is already running.
    final existingConnection = _connectionFuture;

    if (existingConnection != null) {
      return existingConnection;
    }

    final connection = _connectInternal();

    _connectionFuture = connection;

    try {
      return await connection;
    } finally {
      if (identical(_connectionFuture, connection)) {
        _connectionFuture = null;
      }
    }
  }

  // ============================================================
  // INTERNAL CONNECT
  // ============================================================

  Future<bool> _connectInternal() async {
    final token = _token;

    if (token == null || token.trim().isEmpty) {
      print('[SocketService] Cannot connect: token is missing.');
      return false;
    }

    // Remove old socket before creating a new one.
    _disposeSocket();

    final completer = Completer<bool>();

    final socket = io.io(
      _baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({
            'token': token,
          })
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .build(),
    );

    _socket = socket;

    // ==========================================================
    // CONNECTED
    // ==========================================================

    socket.onConnect((_) {
      print('[SocketService] Connected.');

      if (!_connectionController.isClosed) {
        _connectionController.add(true);
      }

      if (!completer.isCompleted) {
        completer.complete(true);
      }
    });

    // ==========================================================
    // DISCONNECTED
    // ==========================================================

    socket.onDisconnect((reason) {
      print('[SocketService] Disconnected: $reason');

      if (!_connectionController.isClosed) {
        _connectionController.add(false);
      }
    });

    // ==========================================================
    // CONNECT ERROR
    // ==========================================================

    socket.onConnectError((error) {
      print('[SocketService] Connection error: $error');

      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    // ==========================================================
    // GENERAL SOCKET ERROR
    // ==========================================================

    socket.onError((error) {
      print('[SocketService] Socket error: $error');
    });

    // ==========================================================
    // RECONNECT ATTEMPT
    // ==========================================================

    socket.io.on(
      'reconnect_attempt',
      (_) {
        print('[SocketService] Reconnection attempt...');
      },
    );

    // ==========================================================
    // RECONNECTED
    // ==========================================================

    socket.io.on(
      'reconnect',
      (_) {
        print('[SocketService] Reconnected.');

        if (!_connectionController.isClosed) {
          _connectionController.add(true);
        }
      },
    );

    // ==========================================================
    // RECONNECT ERROR
    // ==========================================================

    socket.io.on(
      'reconnect_error',
      (error) {
        print('[SocketService] Reconnect error: $error');
      },
    );

    // ==========================================================
    // START CONNECTION
    // ==========================================================

    print('[SocketService] Connecting...');

    socket.connect();

    // ==========================================================
    // WAIT FOR INITIAL CONNECTION
    // ==========================================================

    try {
      return await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('[SocketService] Connection timeout.');

          return false;
        },
      );
    } catch (e) {
      print('[SocketService] Connection failed: $e');

      return false;
    }
  }

  // ============================================================
  // ENSURE CONNECTED
  // ============================================================

  Future<bool> ensureConnected() async {
    if (isConnected) {
      return true;
    }

    final token = _token;

    if (token == null || token.trim().isEmpty) {
      print('[SocketService] ensureConnected failed: token missing.');

      return false;
    }

    return connect(token);
  }

  // ============================================================
  // UPDATE TOKEN
  // ============================================================

  Future<bool> updateToken(String token) async {
    final cleanToken = token.trim();

    if (cleanToken.isEmpty) {
      return false;
    }

    _token = cleanToken;

    if (isConnected) {
      return true;
    }

    return connect(cleanToken);
  }

  // ============================================================
  // DISCONNECT
  // ============================================================

  void disconnect() {
    _token = null;
    _connectionFuture = null;

    _disposeSocket();

    if (!_connectionController.isClosed) {
      _connectionController.add(false);
    }
  }

  // ============================================================
  // INTERNAL SOCKET DISPOSAL
  // ============================================================

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
  }

  // ============================================================
  // CONVERSATION ROOM
  // ============================================================

  void joinConversation(int conversationId) {
    final socket = _socket;

    if (socket == null || !socket.connected) {
      print(
        '[SocketService] Cannot join conversation '
        '$conversationId. Socket is not connected.',
      );

      return;
    }

    socket.emit(
      'joinConversation',
      conversationId,
    );

    print(
      '[SocketService] Joined conversation request: '
      '$conversationId',
    );
  }

  // ============================================================
  // LEAVE CONVERSATION ROOM
  // ============================================================

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
      '[SocketService] Left conversation request: '
      '$conversationId',
    );
  }

  // ============================================================
  // TYPING
  // ============================================================

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

  // ============================================================
  // STOP TYPING
  // ============================================================

  void sendStopTyping(
    int conversationId, {
    int? senderId,
  }) {
    final socket = _socket;

    if (socket == null || !socket.connected) {
      return;
    }

    socket.emit(
      'stopTyping',
      {
        'conversationId': conversationId,
        'senderId': ?senderId,
      },
    );
  }

  // ============================================================
  // MESSAGE DELIVERED
  // ============================================================

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

  // ============================================================
  // MESSAGE SEEN
  // ============================================================

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

  // ============================================================
  // ROOM JOINED LISTENER
  // ============================================================

  void listenRoomJoined(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      'roomJoined',
      callback,
    );
  }

  // ============================================================
  // REMOVE ROOM JOINED LISTENER
  // ============================================================

  void removeRoomJoinedListener() {
    _socket?.off('roomJoined');
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    if (!_connectionController.isClosed) {
      _connectionController.close();
    }

    _token = null;
    _connectionFuture = null;

    _disposeSocket();
  }
}