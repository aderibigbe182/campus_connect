import 'package:flutter/material.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/chat/conversation_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/requests_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/profiles/profile_screen.dart';
import '../screens/stories/story_screen.dart';
import '../screens/stories/create_story_screen.dart';
import '../screens/calls/calls_screen.dart';
import '../screens/groups/groups_screen.dart';
import '../screens/groups/group_chat_screen.dart';

class AppRoutes {

  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String chats = '/chats';
  static const String chat = '/chat';
  static const String search = '/search';
  static const String requests = '/requests';
  static const String profile = '/profile';
  static const String story = '/story';
  static const String createStory = '/create-story';
  static const String calls = '/calls';
  static const String groups = '/groups';
  static const String groupChat = '/group-chat';
  static Map<String, WidgetBuilder> routes = {
    onboarding: (context) =>
        const OnboardingScreen(),
    login: (context) =>
        const LoginScreen(),
    register: (context) =>
        const RegisterScreen(),
    home: (context) =>
        const HomeScreen(),

    chats: (context) =>
        const ChatListScreen(),
    chat: (context) =>
        const ConversationScreen(
          conversationId: 0,
        ),
    search: (context) =>
        const SearchScreen(),
    requests: (context) =>
        const RequestsScreen(),
    profile: (context) =>
        const ProfileScreen(),
    story: (context) =>
        const StoryScreen(),
    createStory: (context) =>
        const CreateStoryScreen(),
    calls: (context) =>
        const CallsScreen(),
    groups: (context) =>
        const GroupsScreen(),
    groupChat: (context) =>
        const GroupChatScreen(),
  };
}