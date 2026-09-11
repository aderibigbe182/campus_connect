import 'package:flutter/material.dart';

import '../models/group_model.dart';
import '../services/group_service.dart';
import 'create_group_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({
    super.key,
  });

  @override
  State<GroupsScreen> createState() =>
      _GroupsScreenState();
}

class _GroupsScreenState
    extends State<GroupsScreen> {
  final GroupService _service =
      GroupService.instance;

  List<GroupModel> _groups = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final groups =
          await _service.getGroups();

      if (!mounted) return;

      setState(() {
        _groups = groups;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            onPressed: _loadGroups,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: () async {
          final created =
              await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CreateGroupScreen(),
            ),
          );

          if (created == true) {
            _loadGroups();
          }
        },
        child: const Icon(Icons.group_add),
      ),
      body: RefreshIndicator(
        onRefresh: _loadGroups,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _groups.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null &&
        _groups.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 180),
          Center(
            child: Padding(
              padding:
                  const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_off,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    textAlign:
                        TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadGroups,
                    child:
                        const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_groups.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 190),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.groups_outlined,
                  size: 58,
                ),
                SizedBox(height: 16),
                Text(
                  'No groups yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Create a group to get started.',
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics:
          const AlwaysScrollableScrollPhysics(),
      itemCount: _groups.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1),
      itemBuilder: (context, index) {
        final group = _groups[index];

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 7,
          ),
          leading: CircleAvatar(
            radius: 27,
            backgroundImage:
                group.image != null &&
                        group.image!.isNotEmpty
                    ? NetworkImage(
                        group.image!,
                      )
                    : null,
            child: group.image == null ||
                    group.image!.isEmpty
                ? Text(
                    _initials(group.name),
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  )
                : null,
          ),
          title: Text(
            group.name,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            group.description
                    ?.isNotEmpty ==
                true
                ? group.description!
                : '${group.memberCount} members',
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
          ),
          onTap: () {},
        );
      },
    );
  }
}