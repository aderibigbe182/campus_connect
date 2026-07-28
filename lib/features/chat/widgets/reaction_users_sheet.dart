import 'package:flutter/material.dart';

import '../models/reaction_model.dart';

class ReactionUsersSheet extends StatelessWidget {
  final String emoji;
  final List<ReactionModel> reactions;

  const ReactionUsersSheet({
    super.key,
    required this.emoji,
    required this.reactions,
  });

  @override
  Widget build(BuildContext context) {
    final users = reactions
        .where((e) => e.emoji == emoji)
        .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Text(
              "$emoji ${users.length}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ...users.map(
              (reaction) => ListTile(
                leading: CircleAvatar(
                  child: Text(
                    reaction.userId.toString(),
                  ),
                ),
                title: Text(
                  "User ${reaction.userId}",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}