import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const SearchTextField({
    super.key,
    required this.controller,
    this.hintText = "Search...",
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,

      style: AppTextStyles.bodyLarge,

      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodySmall,

        filled: true,
        fillColor: AppColors.surface,

        contentPadding: AppSpacing.input,

        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textSecondary,
        ),

        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  controller.clear();

                  if (onClear != null) {
                    onClear!();
                  }
                },
              )
            : null,

        border: OutlineInputBorder(
          borderRadius: AppRadius.pillRadius,
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.pillRadius,
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.pillRadius,
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}