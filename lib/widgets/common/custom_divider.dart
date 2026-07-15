import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class CustomDivider extends StatelessWidget {
  final double indent;
  final double endIndent;
  final double thickness;
  final double verticalMargin;

  const CustomDivider({
    super.key,
    this.indent = 16,
    this.endIndent = 16,
    this.thickness = 0.8,
    this.verticalMargin = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalMargin,
      ),
      child: Divider(
        indent: indent,
        endIndent: endIndent,
        thickness: thickness,
        color: AppColors.divider,
        height: 1,
      ),
    );
  }
}