import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class PagePadding extends StatelessWidget {
  final Widget child;

  final EdgeInsetsGeometry? padding;

  const PagePadding({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.all(
            AppSpacing.lg,
          ),
      child: child,
    );
  }
}