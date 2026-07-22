class ForwardChatModel {
  final int id;
  final String name;
  final String? profilePicture;

  const ForwardChatModel({
    required this.id,
    required this.name,
    this.profilePicture,
  });
}