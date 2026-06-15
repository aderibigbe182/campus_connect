class GroupModel {

  final String id;
  final String name;
  final String image;
  final String lastMessage;
  final String lastMessageTime;

  GroupModel({
    required this.id,
    required this.name,
    required this.image,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory GroupModel.fromMap(
      Map<String, dynamic> map,
      String id,
      ) {

    return GroupModel(
      id: id,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime:
      map['lastMessageTime'] ?? '',
    );
  }
}