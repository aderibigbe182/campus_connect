import 'package:flutter/material.dart';

import '../../friends/models/friend_model.dart';
import '../../friends/services/friends_service.dart';
import '../services/group_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({
    super.key,
  });

  @override
  State<CreateGroupScreen> createState() =>
      _CreateGroupScreenState();
}

class _CreateGroupScreenState
    extends State<CreateGroupScreen> {
  final _nameController =
      TextEditingController();

  final _descriptionController =
      TextEditingController();

  final GroupService _groupService =
      GroupService.instance;

  List<FriendModel> _friends = [];
  final Set<int> _selectedUsers = {};

  bool _loadingFriends = true;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      final friends =
          await FriendsService.getFriends();

      if (!mounted) return;

      setState(() {
        _friends = friends;
        _loadingFriends = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loadingFriends = false;
      });
    }
  }

  Future<void> _createGroup() async {
    final name =
        _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Enter a group name'),
        ),
      );
      return;
    }

    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Select at least one friend',
          ),
        ),
      );
      return;
    }

    setState(() {
      _creating = true;
    });

    try {
      await _groupService.createGroup(
        name: name,
        description:
            _descriptionController.text,
        memberIds:
            _selectedUsers.toList(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _creating = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Create Group'),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller:
                      _nameController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Group name',
                    border:
                        OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                TextField(
                  controller:
                      _descriptionController,
                  maxLines: 2,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Description',
                    border:
                        OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loadingFriends
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount:
                        _friends.length,
                    itemBuilder:
                        (context, index) {
                      final friend =
                          _friends[index];

                      final selected =
                          _selectedUsers
                              .contains(
                        friend.id,
                      );

                      return CheckboxListTile(
                        value: selected,
                        onChanged:
                            (value) {
                          setState(() {
                            if (value ==
                                true) {
                              _selectedUsers
                                  .add(
                                friend.id,
                              );
                            } else {
                              _selectedUsers
                                  .remove(
                                friend.id,
                              );
                            }
                          });
                        },
                        title: Text(
                          friend.fullName,
                        ),
                        subtitle:
                            Text(
                          '@${friend.username}',
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _creating
                      ? null
                      : _createGroup,
                  child: _creating
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Create Group',
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}