class MessageModel {

  final String senderId;
  final String receiverId;
  final String text;
  final bool seen;
  final bool delivered;
  final DateTime timestamp;

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.seen,
    required this.delivered,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "receiverId": receiverId,
      "text": text,
      "seen": seen,
      "delivered": delivered,
      "timestamp": timestamp,
    };
  }
}