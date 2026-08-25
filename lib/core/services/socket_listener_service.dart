import 'package:socket_io_client/socket_io_client.dart' as io;

import 'socket_service.dart';

class SocketListenerService {
  SocketListenerService._();

  static final SocketListenerService instance =
      SocketListenerService._();

  io.Socket? get _socket => SocketService.instance.socket;

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
    _socket?.off('new_message');
    _socket?.on('new_message', callback);
  }

  void removeNewMessageListener() {
    _socket?.off('new_message');
  }

  // ===========================================================
  // MESSAGE SEEN
  // ===========================================================

  void listenMessageSeen(
    Function(dynamic) callback,
  ) {
    _socket?.off('message_seen');
    _socket?.on('message_seen', callback);
  }

  void removeMessageSeenListener() {
    _socket?.off('message_seen');
  }

  // ===========================================================
  // MESSAGE DELIVERED
  // ===========================================================

  void listenMessageDelivered(
    Function(dynamic) callback,
  ) {
    _socket?.off('message_delivered');
    _socket?.on('message_delivered', callback);
  }

  void removeMessageDeliveredListener() {
    _socket?.off('message_delivered');
  }

  // ===========================================================
  // TYPING
  // ===========================================================

  void listenTyping(
    Function(dynamic) callback,
  ) {
    _socket?.off('user_typing');
    _socket?.on('user_typing', callback);
  }

  void listenStopTyping(
    Function(dynamic) callback,
  ) {
    _socket?.off('user_stopped_typing');
    _socket?.on('user_stopped_typing', callback);
  }

  void removeTypingListener() {
    _socket?.off('user_typing');
  }

  void removeStopTypingListener() {
    _socket?.off('user_stopped_typing');
  }

  void removeTypingListeners() {
    _socket?.off('user_typing');
    _socket?.off('user_stopped_typing');
  }

  // ===========================================================
  // PRESENCE
  // ===========================================================

  void listenPresence(
    Function(dynamic) callback,
  ) {
    _socket?.off('userOnline');
    _socket?.on('userOnline', callback);
  }

  void removePresenceListener() {
    _socket?.off('userOnline');
  }

  // ===========================================================
  // FRIEND REQUEST
  // ===========================================================

  void listenFriendRequestSent(
    Function(dynamic) callback,
  ) {
    _socket?.off('friend_request_sent');
    _socket?.on('friend_request_sent', callback);
  }

  void listenFriendRequestAccepted(
    Function(dynamic) callback,
  ) {
    _socket?.off('friend_request_accepted');
    _socket?.on('friend_request_accepted', callback);
  }

  void listenFriendRequestDeclined(
    Function(dynamic) callback,
  ) {
    _socket?.off('friend_request_declined');
    _socket?.on('friend_request_declined', callback);
  }

  void removeFriendRequestSentListener() {
    _socket?.off('friend_request_sent');
  }

  void removeFriendRequestAcceptedListener() {
    _socket?.off('friend_request_accepted');
  }

  void removeFriendRequestDeclinedListener() {
    _socket?.off('friend_request_declined');
  }

  void removeFriendRequestListeners() {
    _socket?.off('friend_request_sent');
    _socket?.off('friend_request_accepted');
    _socket?.off('friend_request_declined');
  }

  // ===========================================================
  // RELATIONSHIP
  // ===========================================================

  void listenRelationshipUpdated(
    Function(dynamic) callback,
  ) {
    _socket?.off('relationship_updated');
    _socket?.on('relationship_updated', callback);
  }

  void removeRelationshipUpdatedListener() {
    _socket?.off('relationship_updated');
  }

  // ===========================================================
  // CHAT LIST
  // ===========================================================

  void listenChatListUpdated(
    Function(dynamic) callback,
  ) {
    _socket?.off('chat_list_updated');
    _socket?.on('chat_list_updated', callback);
  }

  void removeChatListUpdatedListener() {
    _socket?.off('chat_list_updated');
  }

  // ===========================================================
  // UNREAD COUNT
  // ===========================================================

  void listenUnreadUpdated(
    Function(dynamic) callback,
  ) {
    _socket?.off('unreadUpdated');
    _socket?.on('unreadUpdated', callback);
  }

  void removeUnreadUpdatedListener() {
    _socket?.off('unreadUpdated');
  }

  // ===========================================================
  // REACTIONS
  // ===========================================================

  void listenMessageReaction(
    Function(dynamic) callback,
  ) {
    _socket?.off('messageReaction');
    _socket?.on('messageReaction', callback);
  }

  void listenMessageUnreaction(
    Function(dynamic) callback,
  ) {
    _socket?.off('removeReaction');
    _socket?.on('removeReaction', callback);
  }

  void removeMessageReactionListener() {
    _socket?.off('messageReaction');
  }

  void removeMessageUnreactionListener() {
    _socket?.off('removeReaction');
  }

  void removeReactionListeners() {
    _socket?.off('messageReaction');
    _socket?.off('removeReaction');
  }

  // ===========================================================
  // MEDIA
  // ===========================================================

  void listenNewMediaMessage(
    Function(dynamic) callback,
  ) {
    _socket?.off('newMediaMessage');
    _socket?.on('newMediaMessage', callback);
  }

  void listenMediaUploaded(
    Function(dynamic) callback,
  ) {
    _socket?.off('mediaUploaded');
    _socket?.on('mediaUploaded', callback);
  }

  void removeNewMediaMessageListener() {
    _socket?.off('newMediaMessage');
  }

  void removeMediaUploadedListener() {
    _socket?.off('mediaUploaded');
  }

  // ===========================================================
  // STARRED MESSAGE
  // ===========================================================

  void listenMessageStarred(
    Function(dynamic) callback,
  ) {
    _socket?.off('messageStarred');
    _socket?.on('messageStarred', callback);
  }

  void listenMessageUnstarred(
    Function(dynamic) callback,
  ) {
    _socket?.off('messageUnstarred');
    _socket?.on('messageUnstarred', callback);
  }

  void removeMessageStarredListener() {
    _socket?.off('messageStarred');
  }

  void removeMessageUnstarredListener() {
    _socket?.off('messageUnstarred');
  }

  // ===========================================================
  // CALLS
  // ===========================================================

  void listenIncomingCall(
    Function(dynamic) callback,
  ) {
    _socket?.off('incomingCall');
    _socket?.on('incomingCall', callback);
  }

  void listenCallAccepted(
    Function(dynamic) callback,
  ) {
    _socket?.off('callAccepted');
    _socket?.on('callAccepted', callback);
  }

  void listenCallRejected(
    Function(dynamic) callback,
  ) {
    _socket?.off('callRejected');
    _socket?.on('callRejected', callback);
  }

  void listenCallEnded(
    Function(dynamic) callback,
  ) {
    _socket?.off('callEnded');
    _socket?.on('callEnded', callback);
  }

  void listenCallBusy(
    Function(dynamic) callback,
  ) {
    _socket?.off('callBusy');
    _socket?.on('callBusy', callback);
  }

  void listenMissedCall(
    Function(dynamic) callback,
  ) {
    _socket?.off('missedCall');
    _socket?.on('missedCall', callback);
  }

  void removeIncomingCallListener() {
    _socket?.off('incomingCall');
  }

  void removeCallAcceptedListener() {
    _socket?.off('callAccepted');
  }

  void removeCallRejectedListener() {
    _socket?.off('callRejected');
  }

  void removeCallEndedListener() {
    _socket?.off('callEnded');
  }

  void removeCallBusyListener() {
    _socket?.off('callBusy');
  }

  void removeMissedCallListener() {
    _socket?.off('missedCall');
  }

  // ===========================================================
  // WEBRTC
  // ===========================================================

  void listenWebRTCOffer(
    Function(dynamic) callback,
  ) {
    _socket?.off('webrtcOffer');
    _socket?.on('webrtcOffer', callback);
  }

  void listenWebRTCAnswer(
    Function(dynamic) callback,
  ) {
    _socket?.off('webrtcAnswer');
    _socket?.on('webrtcAnswer', callback);
  }

  void listenIceCandidate(
    Function(dynamic) callback,
  ) {
    _socket?.off('iceCandidate');
    _socket?.on('iceCandidate', callback);
  }

  void removeWebRTCOfferListener() {
    _socket?.off('webrtcOffer');
  }

  void removeWebRTCAnswerListener() {
    _socket?.off('webrtcAnswer');
  }

  void removeIceCandidateListener() {
    _socket?.off('iceCandidate');
  }

  // ===========================================================
  // VIDEO CALL
  // ===========================================================

  void listenVideoEnabled(
    Function(dynamic) callback,
  ) {
    _socket?.off('videoEnabled');
    _socket?.on('videoEnabled', callback);
  }

  void listenVideoDisabled(
    Function(dynamic) callback,
  ) {
    _socket?.off('videoDisabled');
    _socket?.on('videoDisabled', callback);
  }

  void listenUpgradeToVideoCall(
    Function(dynamic) callback,
  ) {
    _socket?.off('upgradeToVideoCall');
    _socket?.on('upgradeToVideoCall', callback);
  }

  void listenCameraStateChanged(
    Function(dynamic) callback,
  ) {
    _socket?.off('cameraStateChanged');
    _socket?.on('cameraStateChanged', callback);
  }

  void listenToggleCamera(
    Function(dynamic) callback,
  ) {
    _socket?.off('toggleCamera');
    _socket?.on('toggleCamera', callback);
  }

  void removeVideoEnabledListener() {
    _socket?.off('videoEnabled');
  }

  void removeVideoDisabledListener() {
    _socket?.off('videoDisabled');
  }

  void removeUpgradeToVideoCallListener() {
    _socket?.off('upgradeToVideoCall');
  }

  void removeCameraStateChangedListener() {
    _socket?.off('cameraStateChanged');
  }

  void removeToggleCameraListener() {
    _socket?.off('toggleCamera');
  }

  // ===========================================================
  // SCREEN SHARING
  // ===========================================================

  void listenScreenShareStarted(
    Function(dynamic) callback,
  ) {
    _socket?.off('screenShareStarted');
    _socket?.on('screenShareStarted', callback);
  }

  void listenScreenShareStopped(
    Function(dynamic) callback,
  ) {
    _socket?.off('screenShareStopped');
    _socket?.on('screenShareStopped', callback);
  }

  void removeScreenShareStartedListener() {
    _socket?.off('screenShareStarted');
  }

  void removeScreenShareStoppedListener() {
    _socket?.off('screenShareStopped');
  }

  // ===========================================================
  // RECORDING
  // ===========================================================

  void listenRecordingStarted(
    Function(dynamic) callback,
  ) {
    _socket?.off('recordingStarted');
    _socket?.on('recordingStarted', callback);
  }

  void listenRecordingStopped(
    Function(dynamic) callback,
  ) {
    _socket?.off('recordingStopped');
    _socket?.on('recordingStopped', callback);
  }

  void removeRecordingStartedListener() {
    _socket?.off('recordingStarted');
  }

  void removeRecordingStoppedListener() {
    _socket?.off('recordingStopped');
  }

  // ===========================================================
  // VIDEO PERMISSIONS
  // ===========================================================

  void listenVideoPermissionRequest(
    Function(dynamic) callback,
  ) {
    _socket?.off('requestVideoPermission');
    _socket?.on('requestVideoPermission', callback);
  }

  void listenVideoPermissionResponse(
    Function(dynamic) callback,
  ) {
    _socket?.off('respondVideoPermission');
    _socket?.on('respondVideoPermission', callback);
  }

  void removeVideoPermissionRequestListener() {
    _socket?.off('requestVideoPermission');
  }

  void removeVideoPermissionResponseListener() {
    _socket?.off('respondVideoPermission');
  }
}