import 'search_chat_model.dart';
import 'search_message_model.dart';
import 'search_user_model.dart';

class LiveSearchModel {
  final List<SearchUserModel> users;

  final List<SearchChatModel> chats;

  final List<SearchMessageModel> messages;

  LiveSearchModel({
    required this.users,
    required this.chats,
    required this.messages,
  });

  factory LiveSearchModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return LiveSearchModel(
      users: (json["users"] as List? ?? [])
          .map(
            (e) => SearchUserModel.fromJson(e),
          )
          .toList(),

      chats: (json["chats"] as List? ?? [])
          .map(
            (e) => SearchChatModel.fromJson(e),
          )
          .toList(),

      messages:
          (json["messages"] as List? ?? [])
              .map(
                (e) =>
                    SearchMessageModel.fromJson(e),
              )
              .toList(),
    );
  }
}