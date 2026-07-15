import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CampusSliverAppBar extends StatelessWidget {
  final String title;

  final Widget? flexibleSpace;

  final List<Widget>? actions;

  final double expandedHeight;

  final bool pinned;

  final bool floating;

  final bool snap;

  final Widget? leading;

  const CampusSliverAppBar({
    super.key,
    required this.title,
    this.flexibleSpace,
    this.actions,
    this.expandedHeight = 220,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.background,

      surfaceTintColor: Colors.transparent,

      expandedHeight: expandedHeight,

      pinned: pinned,

      floating: floating,

      snap: snap,

      elevation: 0,

      leading: leading,

      actions: actions,

      title: Text(
        title,
        style: AppTextStyles.titleLarge,
      ),

      flexibleSpace: flexibleSpace,
    );
  }
}