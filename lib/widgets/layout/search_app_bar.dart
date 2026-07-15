import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

class SearchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final TextEditingController controller;

  final ValueChanged<String>? onChanged;

  final String hintText;

  final VoidCallback? onBack;

  final List<Widget>? actions;

  final bool autofocus;

  const SearchAppBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText = "Search...",
    this.onBack,
    this.actions,
    this.autofocus = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,

      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: AppColors.textPrimary,
        onPressed: onBack ??
            () {
              Navigator.pop(context);
            },
      ),

      titleSpacing: 0,

      title: Container(
        height: 42,

        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lgRadius,
        ),

        child: TextField(
          controller: controller,
          autofocus: autofocus,
          onChanged: onChanged,

          style: AppTextStyles.bodyLarge,

          decoration: InputDecoration(
            hintText: hintText,

            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),

            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textSecondary,
            ),

            border: InputBorder.none,

            contentPadding:
                const EdgeInsets.symmetric(
              vertical: 10,
            ),
          ),
        ),
      ),

      actions: actions,
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);
}