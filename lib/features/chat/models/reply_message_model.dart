class ReplyMessageModel {
  final int? messageId;
  final String sender;
 final String message;

  const ReplyMessageModel({
    this.messageId,
    required this.sender,
    required this.message,
  });
}