import 'package:flutter/material.dart';

class ChatErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const ChatErrorState({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 90,
              color: Colors.red.shade400,
            ),

            const SizedBox(height: 20),

            Text(
              "Couldn't load chats",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Check your internet connection and try again.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
