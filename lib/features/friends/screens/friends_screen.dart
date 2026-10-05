import 'package:flutter/material.dart';

import '../models/friend_model.dart';
import '../services/friends_service.dart';
import '../../profile/screens/user_profile_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() =>
      _FriendsScreenState();
}

class _FriendsScreenState
    extends State<FriendsScreen> {
  List<FriendModel> friends = [];

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result =
          await FriendsService.getFriends();

      if (!mounted) return;

      setState(() {
        friends = result;
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

  Future<void> _removeFriend(
    FriendModel friend,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text(
              'Remove friend?',
            ),
            content: Text(
              'Remove ${friend.fullName} '
              'from your friends?',
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(
                  context,
                  false,
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pop(
                  context,
                  true,
                ),
                child: const Text('Remove'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    try {
      await FriendsService.removeFriend(
        friend.id,
      );

      if (!mounted) return;

      setState(() {
        friends.removeWhere(
          (item) => item.id == friend.id,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Friend removed successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/search',
              );
            },
            icon: const Icon(Icons.person_add),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const FriendRequestsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.person_add_alt_1,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFriends,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return ListView(
        children: [
          SizedBox(
            height: 500,
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Text(
                  error!,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (friends.isEmpty) {
      return ListView(
        children: const [
          SizedBox(
            height: 500,
            child: Center(
              child: Text(
                'You have no friends yet.',
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      itemCount: friends.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1),
      itemBuilder: (context, index) {
        final friend = friends[index];

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: CircleAvatar(
            radius: 27,
            backgroundImage:
                friend.profilePicture != null &&
                        friend.profilePicture!
                            .isNotEmpty
                    ? NetworkImage(
                        friend.profilePicture!,
                      )
                    : null,
            child:
                friend.profilePicture == null ||
                        friend.profilePicture!.isEmpty
                    ? Text(
                        friend.fullName.isEmpty
                            ? '?'
                            : friend.fullName[0]
                                .toUpperCase(),
                      )
                    : null,
          ),
          title: Text(
            friend.fullName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '@${friend.username}',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    UserProfileScreen(
                  userId: friend.id,
                ),
              ),
            );
          },
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'remove') {
                _removeFriend(friend);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'remove',
                child: Text('Remove friend'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FriendRequestsScreen
    extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() =>
      _FriendRequestsScreenState();
}

class _FriendRequestsScreenState
    extends State<FriendRequestsScreen> {
  List<_RequestWithUser> requests = [];

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final requestList =
          await FriendsService
              .getReceivedRequests();

      final results =
          <_RequestWithUser>[];

      for (final request in requestList) {
        try {
          final search =
              await FriendsService.searchUsers(
            request.senderId.toString(),
          );

          final user = search.cast<
              dynamic>().firstWhere(
            (item) =>
                item?.id == request.senderId,
            orElse: () => null,
          );

          if (user != null) {
            results.add(
              _RequestWithUser(
                request: request,
                fullName: user.fullName,
                username: user.username,
                profilePicture:
                    user.profilePicture,
              ),
            );
          } else {
            results.add(
              _RequestWithUser(
                request: request,
                fullName:
                    'Student #${request.senderId}',
                username: '',
                profilePicture: null,
              ),
            );
          }
        } catch (_) {
          results.add(
            _RequestWithUser(
              request: request,
              fullName:
                  'Student #${request.senderId}',
              username: '',
              profilePicture: null,
            ),
          );
        }
      }

      if (!mounted) return;

      setState(() {
        requests = results;
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

  Future<void> _accept(
    _RequestWithUser item,
  ) async {
    try {
      await FriendsService.acceptRequest(
        item.request.id,
      );

      if (!mounted) return;

      setState(() {
        requests.removeWhere(
          (request) =>
              request.request.id ==
              item.request.id,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request accepted.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    }
  }

  Future<void> _reject(
    _RequestWithUser item,
  ) async {
    try {
      await FriendsService.rejectRequest(
        item.request.id,
      );

      if (!mounted) return;

      setState(() {
        requests.removeWhere(
          (request) =>
              request.request.id ==
              item.request.id,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request declined.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRequests,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return ListView(
        children: [
          SizedBox(
            height: 500,
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Text(
                  error!,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (requests.isEmpty) {
      return ListView(
        children: const [
          SizedBox(
            height: 500,
            child: Center(
              child: Text(
                'No pending friend requests.',
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      itemCount: requests.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = requests[index];

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            radius: 28,
            backgroundImage:
                item.profilePicture != null &&
                        item.profilePicture!.isNotEmpty
                    ? NetworkImage(
                        item.profilePicture!)
                    : null,
            child:
                item.profilePicture == null ||
                        item.profilePicture!.isEmpty
                    ? Text(
                        item.fullName.isEmpty
                            ? '?'
                            : item.fullName[0]
                                .toUpperCase(),
                      )
                    : null,
          ),
          title: Text(
            item.fullName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: item.username.isEmpty
              ? null
              : Text('@${item.username}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Accept',
                onPressed: () =>
                    _accept(item),
                icon: const Icon(
                  Icons.check_circle,
                ),
              ),
              IconButton(
                tooltip: 'Decline',
                onPressed: () =>
                    _reject(item),
                icon: const Icon(
                  Icons.cancel_outlined,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RequestWithUser {
  final dynamic request;
  final String fullName;
  final String username;
  final String? profilePicture;

  const _RequestWithUser({
    required this.request,
    required this.fullName,
    required this.username,
    required this.profilePicture,
  });
}