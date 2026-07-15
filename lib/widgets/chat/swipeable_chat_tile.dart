import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class SwipeableChatTile extends StatelessWidget {
  final Widget child;

  final VoidCallback? onArchive;

  final VoidCallback? onDelete;

  final VoidCallback? onPin;

  const SwipeableChatTile({
    super.key,
    required this.child,
    this.onArchive,
    this.onDelete,
    this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),

      background: _buildBackground(
        color: AppColors.primary,
        icon: Icons.archive_outlined,
        alignment: Alignment.centerLeft,
      ),

      secondaryBackground: _buildBackground(
        color: AppColors.error,
        icon: Icons.delete_outline,
        alignment: Alignment.centerRight,
      ),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onArchive?.call();
        } else {
          onDelete?.call();
        }

        // Don't automatically remove the tile.
        return false;
      },

      child: child,
    );
  }

  Widget _buildBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(
        icon,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}