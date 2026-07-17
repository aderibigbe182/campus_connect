import 'package:flutter/material.dart';

class StoryError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const StoryError({
    super.key,
    this.message =
        "Something went wrong while loading stories.",
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [

              const Icon(
                Icons.cloud_off_rounded,
                color: Colors.red,
                size: 60,
              ),

              const SizedBox(height: 16),

              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              if (onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Try Again"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}