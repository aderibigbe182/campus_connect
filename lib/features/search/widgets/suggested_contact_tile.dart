import 'package:flutter/material.dart';

class SuggestedContactTile extends StatelessWidget {
  final String fullName;
  final String username;
  final String? profilePicture;
  final bool isOnline;
  final VoidCallback? onTap;

  const SuggestedContactTile({
    super.key,
    required this.fullName,
    required this.username,
    required this.profilePicture,
    required this.isOnline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              profilePicture != null
                  ? NetworkImage(profilePicture!)
                  : null,
          child:
              profilePicture == null
                  ? const Icon(Icons.person)
                  : null,
        ),
        title: Text(fullName),
        subtitle: Text("@$username"),
        trailing: Icon(
          Icons.circle,
          color:
              isOnline
                  ? Colors.green
                  : Colors.grey,
          size: 12,
        ),
        onTap: onTap,
      ),
    );
  }
}