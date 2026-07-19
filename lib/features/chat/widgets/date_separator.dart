import 'package:flutter/material.dart';

class DateSeparator extends StatelessWidget {
  final String label;

  const DateSeparator({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Divider(),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
            ),
          ),

          const Expanded(
            child: Divider(),
          ),
        ],
      ),
    );
  }
}