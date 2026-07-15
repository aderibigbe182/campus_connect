import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [

            SizedBox(
              width: size,
              height: size,

              child: const CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),

            if (message != null) ...[
              const SizedBox(
                height: AppSpacing.md,
              ),

              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}