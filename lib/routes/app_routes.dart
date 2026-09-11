import 'package:flutter/material.dart';

import '../features/chat/screens/chat_list_screen.dart';
import '../features/chat/screens/conversation_screen.dart';
import '../features/friends/screens/friend_requests_screen.dart';
import '../features/friends/screens/friends_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/groups/screens/groups_screen.dart';
import '../features/groups/screens/create_group_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String search = '/search';
  static const String friends = '/friends';
  static const String friendRequests =
      '/friend-requests';
  static const String chats = '/chats';
  static const String groups = '/groups';
  static const String createGroup =
    '/create-group';

  static const String conversation =
      '/conversation';

  static Route<dynamic>? onGenerateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case search:
        return MaterialPageRoute(
          builder: (_) =>
              const SearchScreen(),
        );

      case friends:
        return MaterialPageRoute(
          builder: (_) =>
              const FriendsScreen(),
        );

      case friendRequests:
        return MaterialPageRoute(
          builder: (_) =>
              const FriendRequestsScreen(),
        );
      case groups:
  return MaterialPageRoute(
    builder: (_) => const GroupsScreen(),
  );

case createGroup:
  return MaterialPageRoute(
    builder: (_) =>
        const CreateGroupScreen(),
  );

      case chats:
        return MaterialPageRoute(
          builder: (_) =>
              const ChatListScreen(),
        );

      case conversation:
        final args =
            settings.arguments
                as Map<String, dynamic>;
      

        return MaterialPageRoute(
          builder: (_) =>
              ConversationScreen(
            conversationId:
                args['conversationId'] as int,
            recipientId:
                args['recipientId'] as int,
            name:
                args['name'] as String,
            profilePicture:
                args['profilePicture']
                    as String?,
          ),
        );

      default:
        return null;
    }
  }
}