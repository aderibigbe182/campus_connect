import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class FloatingComposeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool mini;

  const FloatingComposeButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.edit,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: mini,
      tooltip: tooltip,
      onPressed: onPressed,
      backgroundColor:
          backgroundColor ?? AppColors.primary,
      foregroundColor:
          foregroundColor ?? Colors.white,
      child: Icon(icon),
    );
  }
}