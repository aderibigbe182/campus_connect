class RelationshipModel {
  final String status;

  final bool canReply;

  final bool isPending;

  final bool isRequester;

  final String? pendingMessage;

  final int? requestId;

  const RelationshipModel({
    required this.status,
    required this.canReply,
    required this.isPending,
    required this.isRequester,
    this.pendingMessage,
    this.requestId,
  });

  factory RelationshipModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RelationshipModel(
      status: json["status"] ?? "none",
      canReply: json["canReply"] ?? false,
      isPending: json["pending"] ?? false,
      isRequester: json["isRequester"] ?? false,
      pendingMessage: json["pendingMessage"],
      requestId: json["requestId"],
    );
  }
}