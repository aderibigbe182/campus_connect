import 'package:socket_io_client/socket_io_client.dart' as io;

import 'socket_service.dart';

class SocketListenerService {
  SocketListenerService._();

  static final SocketListenerService instance =
      SocketListenerService._();

  io.Socket? get _socket =>
      SocketService.instance.socket;

  // ===========================================================
  // GENERIC LISTENER MANAGEMENT
  // ===========================================================

  void removeListener(String event) {
    _socket?.off(event);
  }

  void removeAllListeners() {
    _socket?.clearListeners();
  }

  // ===========================================================
  // NEW MESSAGE
  // ===========================================================

  void listenNewMessage(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "new_message",
      callback,
    );
  }

  void removeNewMessageListener() {
    _socket?.off("new_message");
  }

  // ===========================================================
  // MESSAGE SEEN
  // ===========================================================

  void listenMessageSeen(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "message_seen",
      callback,
    );
  }

  void removeMessageSeenListener() {
    _socket?.off("message_seen");
  }

  // ===========================================================
  // MESSAGE DELIVERED
  // ===========================================================

  void listenMessageDelivered(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "message_delivered",
      callback,
    );
  }

  void removeMessageDeliveredListener() {
    _socket?.off("message_delivered");
  }

  // ===========================================================
  // TYPING
  // ===========================================================

  void listenTyping(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "user_typing",
      callback,
    );
  }

  void listenStopTyping(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "user_stopped_typing",
      callback,
    );
  }

  void removeTypingListener() {
    _socket?.off("user_typing");
  }

  void removeStopTypingListener() {
    _socket?.off("user_stopped_typing");
  }

  // ===========================================================
  // PRESENCE
  // ===========================================================

  void listenPresence(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "userOnline",
      callback,
    );
  }

  void removePresenceListener() {
    _socket?.off("userOnline");
  }

  // ===========================================================
  // FRIEND REQUEST
  // ===========================================================

  void listenFriendRequestSent(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "friend_request_sent",
      callback,
    );
  }

  void listenFriendRequestAccepted(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "friend_request_accepted",
      callback,
    );
  }

  void listenFriendRequestDeclined(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "friend_request_declined",
      callback,
    );
  }

  void removeFriendRequestSentListener() {
    _socket?.off("friend_request_sent");
  }

  void removeFriendRequestAcceptedListener() {
    _socket?.off("friend_request_accepted");
  }

  void removeFriendRequestDeclinedListener() {
    _socket?.off("friend_request_declined");
  }

  // ===========================================================
  // RELATIONSHIP
  // ===========================================================

  void listenRelationshipUpdated(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "relationship_updated",
      callback,
    );
  }

  void removeRelationshipUpdatedListener() {
    _socket?.off("relationship_updated");
  }

  // ===========================================================
  // CHAT LIST
  // ===========================================================

  void listenChatListUpdated(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "chat_list_updated",
      callback,
    );
  }

  void removeChatListUpdatedListener() {
    _socket?.off("chat_list_updated");
  }

  // ===========================================================
  // UNREAD COUNT
  // ===========================================================

  void listenUnreadUpdated(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "unreadUpdated",
      callback,
    );
  }

  void removeUnreadUpdatedListener() {
    _socket?.off("unreadUpdated");
  }

  // ===========================================================
  // REACTIONS
  // ===========================================================

  void listenMessageReaction(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "messageReaction",
      callback,
    );
  }

  void listenMessageUnreaction(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "removeReaction",
      callback,
    );
  }

  void removeMessageReactionListener() {
    _socket?.off("messageReaction");
  }

  void removeMessageUnreactionListener() {
    _socket?.off("removeReaction");
  }

  // ===========================================================
  // MEDIA
  // ===========================================================

  void listenNewMediaMessage(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "newMediaMessage",
      callback,
    );
  }

  void listenMediaUploaded(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "mediaUploaded",
      callback,
    );
  }

  // ===========================================================
  // STARRED MESSAGE
  // ===========================================================

  void listenMessageStarred(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "messageStarred",
      callback,
    );
  }

  void listenMessageUnstarred(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "messageUnstarred",
      callback,
    );
  }

  // ===========================================================
  // CALLS
  // ===========================================================

  void listenIncomingCall(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "incomingCall",
      callback,
    );
  }

  void listenCallAccepted(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "callAccepted",
      callback,
    );
  }

  void listenCallRejected(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "callRejected",
      callback,
    );
  }

  void listenCallEnded(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "callEnded",
      callback,
    );
  }

  void listenCallBusy(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "callBusy",
      callback,
    );
  }

  void listenMissedCall(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "missedCall",
      callback,
    );
  }

  // ===========================================================
  // WEBRTC
  // ===========================================================

  void listenWebRTCOffer(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "webrtcOffer",
      callback,
    );
  }

  void listenWebRTCAnswer(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "webrtcAnswer",
      callback,
    );
  }

  void listenIceCandidate(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "iceCandidate",
      callback,
    );
  }

  // ===========================================================
  // VIDEO CALL
  // ===========================================================

  void listenVideoEnabled(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "videoEnabled",
      callback,
    );
  }

  void listenVideoDisabled(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "videoDisabled",
      callback,
    );
  }

  void listenUpgradeToVideoCall(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "upgradeToVideoCall",
      callback,
    );
  }

  void listenCameraStateChanged(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "cameraStateChanged",
      callback,
    );
  }

  void listenToggleCamera(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "toggleCamera",
      callback,
    );
  }

  // ===========================================================
  // SCREEN SHARING
  // ===========================================================

  void listenScreenShareStarted(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "screenShareStarted",
      callback,
    );
  }

  void listenScreenShareStopped(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "screenShareStopped",
      callback,
    );
  }

  // ===========================================================
  // RECORDING
  // ===========================================================

  void listenRecordingStarted(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "recordingStarted",
      callback,
    );
  }

  void listenRecordingStopped(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "recordingStopped",
      callback,
    );
  }

  // ===========================================================
  // VIDEO PERMISSIONS
  // ===========================================================

  void listenVideoPermissionRequest(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "requestVideoPermission",
      callback,
    );
  }

  void listenVideoPermissionResponse(
    Function(dynamic) callback,
  ) {
    _socket?.on(
      "respondVideoPermission",
      callback,
    );
  }
}