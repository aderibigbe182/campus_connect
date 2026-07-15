import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_radius.dart';
import '/core/theme/app_spacing.dart';
import '/core/theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final double? width;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,

        style: ElevatedButton.styleFrom(
          elevation: 0,

          backgroundColor: AppColors.primary,

          foregroundColor: Colors.white,

          disabledBackgroundColor:
              AppColors.primary.withOpacity(.45),

          padding: AppSpacing.button,

          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgRadius,
          ),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],

            Text(
              text,
              style: AppTextStyles.button,
            ),
          ],
        ),
      ),
    );
  }
}