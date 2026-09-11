class FriendRequestModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String status;
  final DateTime? createdAt;

  const FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    this.createdAt,
  });

  factory FriendRequestModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FriendRequestModel(
      id: int.tryParse('${json['id']}') ?? 0,
      senderId: int.tryParse('${json['sender_id']}') ?? 0,
      receiverId:
          int.tryParse('${json['receiver_id']}') ?? 0,
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(
              json['created_at'].toString(),
            ),
    );
  }
}