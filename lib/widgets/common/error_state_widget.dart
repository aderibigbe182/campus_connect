import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;
  final Widget? action;

  const ErrorStateWidget({
    super.key,
    this.title = "Something went wrong",
    this.subtitle =
        "An unexpected error occurred. Please try again.",
    this.onRetry,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [

            Icon(
              Icons.error_outline,
              size: 72,
              color: AppColors.error,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium,
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(
              height: AppSpacing.xl,
            ),

            if (action != null)
              action!
            else if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text("Try Again"),
              ),
          ],
        ),
      ),
    );
  }
}