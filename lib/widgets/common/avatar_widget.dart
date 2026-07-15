import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double radius;
  final bool showBorder;
  final Color? borderColor;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.initials,
    this.radius = 24,
    this.showBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,

      backgroundImage:
          imageUrl != null &&
                  imageUrl!.isNotEmpty
              ? NetworkImage(imageUrl!)
              : null,

      child:
          imageUrl == null ||
                  imageUrl!.isEmpty
              ? Text(
                  (initials ?? "?")
                      .toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: radius * .75,
                  ),
                )
              : null,
    );

    if (!showBorder) {
      return avatar;
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color:
              borderColor ??
              AppColors.primary,
          width: 2,
        ),
      ),
      child: avatar,
    );
  }
}