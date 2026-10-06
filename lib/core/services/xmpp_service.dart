import 'dart:developer' as developer;

class XmppService {
  void connect(String userId, String password) {
    // TODO: integrate xmpp package
    developer.log("Connecting to XMPP server...");
  }

  void sendMessage(String to, String message) {
    developer.log("Sending message to $to: $message");
  }

  void disconnect() {
    developer.log("Disconnected");
  }
}
