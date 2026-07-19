import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  final String username;

  const TypingIndicator({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 14,
        bottom: 10,
        top: 4,
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 8,
            height: 8,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),

          const SizedBox(width: 10),

          Text(
            "$username is typing...",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}