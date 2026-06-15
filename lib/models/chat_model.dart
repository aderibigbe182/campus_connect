class ChatModel {

  final String chatId;
  final List members;
  final String lastMessage;

  ChatModel({

    required this.chatId,
    required this.members,
    required this.lastMessage,
  });

  factory ChatModel.fromMap(
      Map<String, dynamic> map) {

    return ChatModel(

      chatId: map['chatId'],

      members: map['members'],

      lastMessage:
          map['lastMessage'] ?? '',
    );
  }
}