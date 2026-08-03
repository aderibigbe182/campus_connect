import 'package:flutter/material.dart';

import '../../../widgets/avatar_widget.dart';

import '../../chat/screens/conversation_screen.dart';

import '../models/user_profile_model.dart';
import '../services/user_profile_service.dart';

import '../../../core/services/storage_service.dart';
import '../../chat/services/chat_service.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;

  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserProfileScreen> createState() =>
      _UserProfileScreenState();
}

class _UserProfileScreenState
    extends State<UserProfileScreen> {
  UserProfileModel? user;

  bool loading = true;

  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      currentUserId =
          await StorageService.getUserId();

      final profile =
          await UserProfileService
              .getUserProfile(
        widget.userId,
      );

      if (!mounted) return;

      setState(() {
        user = profile;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _openConversation() async {
    if (user == null) return;

    final conversationId =
        await UserProfileService
            .getOrCreateConversation(
      user!.id,
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationScreen(
          conversationId:
              conversationId.toString(),
          currentUserId:
              currentUserId ?? 0,
          chatName: user!.fullName,
          profileImage:
              user!.profilePicture,
          isOnline: user!.isOnline,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "User not found",
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [

            AvatarWidget(
              radius: 60,
              imageUrl:
                  user!.profilePicture,
              fullName:
                  user!.fullName,
              isOnline:
                  user!.isOnline,
            ),

            const SizedBox(height: 15),

            Text(
              user!.fullName,
              style:
                  const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "@${user!.username}",
              style:
                  const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              user!.isOnline
                  ? "Online"
                  : "Offline",
              style: TextStyle(
                color: user!.isOnline
                    ? Colors.green
                    : Colors.grey,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 30),

            _infoTile(
              "University",
              user!.university ??
                  "Not set",
            ),

            _infoTile(
              "Department",
              user!.department ??
                  "Not set",
            ),

            _infoTile(
              "Level",
              user!.level ??
                  "Not set",
            ),

            _infoTile(
              "Bio",
              user!.bio ??
                  "No bio",
            ),

            _infoTile(
              "Interests",
              user!.interests ??
                  "None",
            ),

            const SizedBox(height: 30),

            Row(
              children: [

                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed: () async {
                      print("Current User: $currentUserId");
print("Profile User: ${user!.id}");
  try {
    final conversationId =
        await ChatService.instance.getOrCreateConversation(
      user!.id,
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationScreen(
          conversationId: conversationId.toString(), // or conversationId if it's an int
          currentUserId: currentUserId ?? 0,
          chatName: user!.fullName,
          profileImage: user!.profilePicture,
          isOnline: user!.isOnline,
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
      ),
    );
  }
},
                    icon: const Icon(
                      Icons.message,
                    ),
                    label: const Text(
                      "Message",
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.call,
                    ),
                    label: const Text(
                      "Call",
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.videocam,
                    ),
                    label: const Text(
                      "Video",
                    ),
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(
    String title,
    String value,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}