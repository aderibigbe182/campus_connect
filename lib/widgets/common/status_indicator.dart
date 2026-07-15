import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum StatusType {
  success,
  warning,
  error,
  info,
  pending,
}

class StatusIndicator extends StatelessWidget {
  final StatusType status;
  final String text;
  final IconData? icon;

  const StatusIndicator({
    super.key,
    required this.status,
    required this.text,
    this.icon,
  });

  Color get _color {
    switch (status) {
      case StatusType.success:
        return AppColors.success;

      case StatusType.warning:
        return Colors.orange;

      case StatusType.error:
        return Colors.red;

      case StatusType.info:
        return AppColors.primary;

      case StatusType.pending:
        return Colors.grey;
    }
  }

  IconData get _defaultIcon {
    switch (status) {
      case StatusType.success:
        return Icons.check_circle;

      case StatusType.warning:
        return Icons.warning_amber;

      case StatusType.error:
        return Icons.error;

      case StatusType.info:
        return Icons.info;

      case StatusType.pending:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: _color.withOpacity(.12),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(
            icon ?? _defaultIcon,
            color: _color,
            size: 16,
          ),

          const SizedBox(width: 6),

          Text(
            text,
            style: TextStyle(
              color: _color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}