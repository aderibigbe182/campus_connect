import 'package:flutter/material.dart';

class SearchError extends StatelessWidget {
  final String message;

  const SearchError({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}