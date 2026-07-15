import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class UnreadBadge extends StatelessWidget {
  final int count;
  final double minSize;

  const UnreadBadge({
    super.key,
    required this.count,
    this.minSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    final String displayText =
        count > 99 ? '99+' : count.toString();

    return Container(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),

      alignment: Alignment.center,

      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.all(
          Radius.circular(999),
        ),
      ),

      child: Text(
        displayText,
        textAlign: TextAlign.center,
        style: AppTextStyles.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}