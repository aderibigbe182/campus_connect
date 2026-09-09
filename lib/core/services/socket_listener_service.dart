import 'package:socket_io_client/socket_io_client.dart' as io;

import 'socket_service.dart';

class SocketListenerService {
  SocketListenerService._();

  static final SocketListenerService instance =
      SocketListenerService._();

  // ============================================================
  // SOCKET
  // ============================================================

  io.Socket? get _socket => SocketService.instance.socket;

  // ============================================================
  // GENERIC
  // ============================================================

  void listen(
    String event,
    void Function(dynamic) callback,
  ) {
    final socket = _socket;

    if (socket == null) {
      return;
    }

    socket.on(
      event,
      callback,
    );
  }

  void remove(
    String event,
    void Function(dynamic) callback,
  ) {
    final socket = _socket;

    if (socket == null) {
      return;
    }

    socket.off(
      event,
      callback,
    );
  }

  // ============================================================
  // NEW MESSAGE
  // ============================================================

  void listenNewMessage(
    void Function(dynamic) callback,
  ) {
    listen('new_message', callback);
  }

  void removeNewMessageListener(
    void Function(dynamic) callback,
  ) {
    remove('new_message', callback);
  }

  // ============================================================
  // MESSAGE SEEN
  // ============================================================

  void listenMessageSeen(
    void Function(dynamic) callback,
  ) {
    listen('message_seen', callback);
  }

  void removeMessageSeenListener(
    void Function(dynamic) callback,
  ) {
    remove('message_seen', callback);
  }

  // ============================================================
  // MESSAGE DELIVERED
  // ============================================================

  void listenMessageDelivered(
    void Function(dynamic) callback,
  ) {
    listen('message_delivered', callback);
  }

  void removeMessageDeliveredListener(
    void Function(dynamic) callback,
  ) {
    remove('message_delivered', callback);
  }

  // ============================================================
  // TYPING
  // ============================================================

  void listenTyping(
    void Function(dynamic) callback,
  ) {
    listen('user_typing', callback);
  }

  void removeTypingListener(
    void Function(dynamic) callback,
  ) {
    remove('user_typing', callback);
  }

  // ============================================================
  // STOP TYPING
  // ============================================================

  void listenStopTyping(
    void Function(dynamic) callback,
  ) {
    listen('user_stopped_typing', callback);
  }

  void removeStopTypingListener(
    void Function(dynamic) callback,
  ) {
    remove('user_stopped_typing', callback);
  }

  // ============================================================
  // PRESENCE
  // ============================================================

  void listenPresence(
    void Function(dynamic) callback,
  ) {
    listen('userOnline', callback);
  }

  void removePresenceListener(
    void Function(dynamic) callback,
  ) {
    remove('userOnline', callback);
  }

  // ============================================================
  // FRIEND REQUEST SENT
  // ============================================================

  void listenFriendRequestSent(
    void Function(dynamic) callback,
  ) {
    listen('friend_request_sent', callback);
  }

  void removeFriendRequestSentListener(
    void Function(dynamic) callback,
  ) {
    remove('friend_request_sent', callback);
  }

  // ============================================================
  // FRIEND REQUEST ACCEPTED
  // ============================================================

  void listenFriendRequestAccepted(
    void Function(dynamic) callback,
  ) {
    listen('friend_request_accepted', callback);
  }

  void removeFriendRequestAcceptedListener(
    void Function(dynamic) callback,
  ) {
    remove('friend_request_accepted', callback);
  }

  // ============================================================
  // FRIEND REQUEST DECLINED
  // ============================================================

  void listenFriendRequestDeclined(
    void Function(dynamic) callback,
  ) {
    listen('friend_request_declined', callback);
  }

  void removeFriendRequestDeclinedListener(
    void Function(dynamic) callback,
  ) {
    remove('friend_request_declined', callback);
  }

  // ============================================================
  // RELATIONSHIP UPDATED
  // ============================================================

  void listenRelationshipUpdated(
    void Function(dynamic) callback,
  ) {
    listen('relationship_updated', callback);
  }

  void removeRelationshipUpdatedListener(
    void Function(dynamic) callback,
  ) {
    remove('relationship_updated', callback);
  }

  // ============================================================
  // CHAT LIST UPDATED
  // ============================================================

  void listenChatListUpdated(
    void Function(dynamic) callback,
  ) {
    listen('chat_list_updated', callback);
  }

  void removeChatListUpdatedListener(
    void Function(dynamic) callback,
  ) {
    remove('chat_list_updated', callback);
  }

  // ============================================================
  // ROOM JOINED
  // ============================================================

  void listenRoomJoined(
    void Function(dynamic) callback,
  ) {
    listen('roomJoined', callback);
  }

  void removeRoomJoinedListener(
    void Function(dynamic) callback,
  ) {
    remove('roomJoined', callback);
  }

  // ============================================================
  // REMOVE ALL LISTENERS
  // ============================================================

  void removeAllListeners() {
    final socket = _socket;

    if (socket == null) {
      return;
    }

    socket.clearListeners();
  }
}