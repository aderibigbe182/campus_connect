import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? label;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.label,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
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
          const SizedBox(height: AppSpacing.sm),
        ],

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          enabled: enabled,
          readOnly: readOnly,
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,

          style: AppTextStyles.bodyLarge,

          decoration: InputDecoration(
            hintText: hintText,

            hintStyle: AppTextStyles.bodySmall,

            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,

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