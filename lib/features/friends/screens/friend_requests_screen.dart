import 'package:flutter/material.dart';
import '../models/friend_request_model.dart';
import '../services/friends_service.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() =>
      _FriendRequestsScreenState();
}

class _FriendRequestsScreenState
    extends State<FriendRequestsScreen> {
  List<FriendRequestModel> requests = [];

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
      final result =
          await FriendsService.getReceivedRequests();

      if (!mounted) return;

      setState(() {
        requests = result;
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
    FriendRequestModel request,
  ) async {
    try {
      await FriendsService.acceptRequest(
        request.id,
      );

      if (!mounted) return;

      setState(() {
        requests.removeWhere(
          (item) => item.id == request.id,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Friend request accepted.',
          ),
        ),
      );
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _decline(
    FriendRequestModel request,
  ) async {
    try {
      await FriendsService.rejectRequest(
        request.id,
      );

      if (!mounted) return;

      setState(() {
        requests.removeWhere(
          (item) => item.id == request.id,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Friend request declined.',
          ),
        ),
      );
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.toString().replaceFirst(
                'Exception: ',
                '',
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Friend Requests',
        ),
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
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadRequests,
                      child:
                          const Text('Retry'),
                    ),
                  ],
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
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 60,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No pending friend requests.',
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics:
          const AlwaysScrollableScrollPhysics(),
      itemCount: requests.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1),
      itemBuilder: (context, index) {
        final request = requests[index];

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            radius: 28,
            child: Text(
              request.senderId
                  .toString(),
            ),
          ),
          title: Text(
            'User ${request.senderId}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: const Text(
            'Sent you a friend request',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Accept',
                onPressed: () =>
                    _accept(request),
                icon: const Icon(
                  Icons.check_circle,
                ),
              ),
              IconButton(
                tooltip: 'Decline',
                onPressed: () =>
                    _decline(request),
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