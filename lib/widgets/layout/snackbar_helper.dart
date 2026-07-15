import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SnackbarHelper {
  SnackbarHelper._();

  static void showSuccess(
    BuildContext context,
    String message,
  ) {
    _show(
      context,
      message,
      AppColors.success,
      Icons.check_circle,
    );
  }

  static void showError(
    BuildContext context,
    String message,
  ) {
    _show(
      context,
      message,
      AppColors.error,
      Icons.error,
    );
  }

  static void showInfo(
    BuildContext context,
    String message,
  ) {
    _show(
      context,
      message,
      AppColors.primary,
      Icons.info,
    );
  }

  static void showWarning(
    BuildContext context,
    String message,
  ) {
    _show(
      context,
      message,
      AppColors.warning,
      Icons.warning,
    );
  }

  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: color,
          duration: const Duration(
            seconds: 3,
          ),
          content: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}