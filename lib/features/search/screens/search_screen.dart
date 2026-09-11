import 'dart:async';

import 'package:flutter/material.dart';

import '../../friends/models/user_search_model.dart';
import '../../friends/services/friends_service.dart';
import '../../../features/profile/screens/user_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController controller =
      TextEditingController();

  Timer? _debounce;

  List<UserSearchModel> users = [];

  bool loading = false;
  String? error;

  @override
  void dispose() {
    _debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 450),
      () => _search(value),
    );
  }

  Future<void> _search(String value) async {
    final query = value.trim();

    if (query.isEmpty) {
      setState(() {
        users = [];
        error = null;
        loading = false;
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result =
          await FriendsService.searchUsers(query);

      if (!mounted) return;

      setState(() {
        users = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search students...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
          onSubmitted: _search,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (controller.text.trim().isEmpty) {
      return const Center(
        child: Text(
          'Search for students by name or username.',
        ),
      );
    }

    if (users.isEmpty) {
      return const Center(
        child: Text('No students found.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      itemCount: users.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = users[index];

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: CircleAvatar(
            radius: 26,
            backgroundImage:
                user.profilePicture != null &&
                        user.profilePicture!
                            .isNotEmpty
                    ? NetworkImage(
                        user.profilePicture!,
                      )
                    : null,
            child:
                user.profilePicture == null ||
                        user.profilePicture!.isEmpty
                    ? Text(
                        user.fullName.isEmpty
                            ? '?'
                            : user.fullName[0]
                                .toUpperCase(),
                      )
                    : null,
          ),
          title: Text(
            user.fullName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '@${user.username}',
          ),
          trailing: const Icon(
            Icons.chevron_right,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    UserProfileScreen(
                  userId: user.id,
                ),
              ),
            );
          },
        );
      },
    );
  }
}