class ConversationStatusModel {
  final String status;

  final bool canReply;

  final bool pending;

  final bool isRequester;

  final String? pendingMessage;

  final int? conversationId;

  final int? requestId;

  const ConversationStatusModel({
    required this.status,
    required this.canReply,
    required this.pending,
    required this.isRequester,
    this.pendingMessage,
    this.conversationId,
    this.requestId,
  });

  factory ConversationStatusModel.fromJson(
  Map<String, dynamic> json,
) {
  return ConversationStatusModel(
    status:
        json["status"]?.toString() ?? "none",

    canReply:
        json["canReply"] ?? false,

    pending:
        json["pending"] ?? false,

    isRequester:
        json["isRequester"] ?? false,

    pendingMessage:
        json["pendingMessage"]?.toString(),

    conversationId:
        json["conversationId"] == null
            ? null
            : int.parse(
                json["conversationId"].toString(),
              ),

    requestId:
        json["requestId"] == null
            ? null
            : int.parse(
                json["requestId"].toString(),
              ),
  );
}
}