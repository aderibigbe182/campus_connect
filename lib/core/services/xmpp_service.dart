class XmppService {
  void connect(String userId, String password) {
    // TODO: integrate xmpp package
    print("Connecting to XMPP server...");
  }

  void sendMessage(String to, String message) {
    print("Sending message to $to: $message");
  }

  void disconnect() {
    print("Disconnected");
  }
}