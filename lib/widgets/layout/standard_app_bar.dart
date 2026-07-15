import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class StandardAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  final Widget? leading;

  final List<Widget>? actions;

  final bool centerTitle;

  final bool automaticallyImplyLeading;

  final Color? backgroundColor;

  final double elevation;

  const StandardAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          backgroundColor ??
          AppColors.background,

      elevation: elevation,

      centerTitle: centerTitle,

      automaticallyImplyLeading:
          automaticallyImplyLeading,

      leading: leading,

      title: Text(
        title,
        style: AppTextStyles.titleLarge,
      ),

      actions: actions,

      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
      ),

      surfaceTintColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);
}