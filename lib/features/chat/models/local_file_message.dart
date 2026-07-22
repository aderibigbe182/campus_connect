import 'dart:io';

class LocalFileMessage {
  final File file;
  final String name;
  final int size;
  final bool isMe;
  final DateTime createdAt;

  LocalFileMessage({
    required this.file,
    required this.name,
    required this.size,
    required this.isMe,
    required this.createdAt,
  });
}