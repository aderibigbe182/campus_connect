import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

class MultilineTextField extends StatelessWidget {
  final TextEditingController controller;

  final String hintText;

  final String? label;

  final int minLines;

  final int maxLines;

  final bool enabled;

  final bool readOnly;

  final ValueChanged<String>? onChanged;

  final String? Function(String?)? validator;

  const MultilineTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.label,
    this.minLines = 4,
    this.maxLines = 8,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.labelLarge,
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),
        ],

        TextFormField(
          controller: controller,

          enabled: enabled,

          readOnly: readOnly,

          validator: validator,

          onChanged: onChanged,

          minLines: minLines,

          maxLines: maxLines,

          keyboardType: TextInputType.multiline,

          style: AppTextStyles.bodyLarge,

          decoration: InputDecoration(
            hintText: hintText,

            hintStyle: AppTextStyles.bodySmall,

            alignLabelWithHint: true,

            filled: true,

            fillColor: AppColors.surface,

            contentPadding: AppSpacing.input,

            border: OutlineInputBorder(
              borderRadius: AppRadius.lgRadius,
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.lgRadius,
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.lgRadius,
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.lgRadius,
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.lgRadius,
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}