import 'package:flutter/material.dart';

class RequestBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  final String? primaryText;
  final VoidCallback? onPrimary;

  final String? secondaryText;
  final VoidCallback? onSecondary;

  const RequestBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.primaryText,
    this.onPrimary,
    this.secondaryText,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Icon(
                Icons.person_add_alt_1,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),

              const SizedBox(height: 15),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                subtitle,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  if (secondaryText != null)
                    OutlinedButton(
                      onPressed: onSecondary,
                      child: Text(secondaryText!),
                    ),

                  if (secondaryText != null)
                    const SizedBox(width: 12),

                  if (primaryText != null)
                    ElevatedButton(
                      onPressed: onPrimary,
                      child: Text(primaryText!),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}