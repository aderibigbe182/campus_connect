import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
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
              icon,
              size: 72,
              color: AppColors.textSecondary.withOpacity(.6),
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

            if (action != null) ...[
              const SizedBox(
                height: AppSpacing.xl,
              ),

              action!,
            ],
          ],
        ),
      ),
    );
  }
}