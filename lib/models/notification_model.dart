class NotificationModel {

  final String receiverId;
  final String senderId;
  final String title;
  final String body;
  final bool read;

  NotificationModel({

    required this.receiverId,
    required this.senderId,
    required this.title,
    required this.body,
    required this.read,
  });

  factory NotificationModel.fromMap(
      Map<String, dynamic> map) {

    return NotificationModel(

      receiverId:
          map['receiverId'],

      senderId:
          map['senderId'],

      title:
          map['title'],

      body:
          map['body'],

      read:
          map['read'],
    );
  }
}