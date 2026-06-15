import 'package:flutter/material.dart';

class TypingIndicator
    extends StatelessWidget {

  final String username;

  const TypingIndicator({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),

      child: Text(
        "$username is typing...",
      ),
    );
  }
}