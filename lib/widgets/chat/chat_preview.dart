import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class ChatPreview extends StatelessWidget {
  final String title;

  final String subtitle;

  final Widget? trailing;

  final bool isVerified;

  final int maxSubtitleLines;

  const ChatPreview({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.isVerified = false,
    this.maxSubtitleLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium,
                    ),
                  ),

                  if (isVerified)
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 4,
                      ),
                      child: Icon(
                        Icons.verified,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                ],
              ),

              const SizedBox(
                height: AppSpacing.xs,
              ),

              Text(
                subtitle,
                maxLines: maxSubtitleLines,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        if (trailing != null) ...[
          const SizedBox(
            width: AppSpacing.md,
          ),
          trailing!,
        ],
      ],
    );
  }
}