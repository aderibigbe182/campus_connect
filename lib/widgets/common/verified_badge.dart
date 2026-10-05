import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class VerifiedBadge extends StatelessWidget {
  final double size;
  final String? tooltip;

  const VerifiedBadge({
    super.key,
    this.size = 18,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? "Verified Account",

      child: Container(
        width: size,
        height: size,

        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),

        child: Icon(
          Icons.check,
          size: size * 0.65,
          color: Colors.white,
        ),
      ),
    );
  }
}