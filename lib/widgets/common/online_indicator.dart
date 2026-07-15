import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum UserStatus {
  online,
  offline,
  away,
  busy,
}

class OnlineIndicator extends StatelessWidget {
  final UserStatus status;
  final double size;

  const OnlineIndicator({
    super.key,
    this.status = UserStatus.offline,
    this.size = 12,
  });

  Color get _statusColor {
    switch (status) {
      case UserStatus.online:
        return AppColors.success;

      case UserStatus.away:
        return Colors.orange;

      case UserStatus.busy:
        return Colors.red;

      case UserStatus.offline:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,

      decoration: BoxDecoration(
        color: _statusColor,

        shape: BoxShape.circle,

        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }
}