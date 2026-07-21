import 'dart:io';

class LocalImageMessage {
  final File image;
  final bool isMe;
  final DateTime createdAt;

  LocalImageMessage({
    required this.image,
    required this.isMe,
    required this.createdAt,
  });
}
