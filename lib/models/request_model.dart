class FriendRequestModel {

  final String senderId;
  final String receiverId;
  final String status;

  FriendRequestModel({
    required this.senderId,
    required this.receiverId,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "receiverId": receiverId,
      "status": status,
    };
  }
}