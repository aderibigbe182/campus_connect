import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String? fullName;
  final double radius;
  final bool isOnline;
  final bool showStoryRing;
  final VoidCallback? onTap;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.fullName,
    this.radius = 28,
    this.isOnline = false,
    this.showStoryRing = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade300,
      backgroundImage:
          _hasValidImage(imageUrl) ? NetworkImage(imageUrl!) : null,
      child: !_hasValidImage(imageUrl)
          ? Text(
              _initials(fullName),
              style: TextStyle(
                fontSize: radius * 0.55,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          : null,
    );

    if (showStoryRing) {
      avatar = Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.blue,
            width: 3,
          ),
        ),
        child: avatar,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,

          if (isOnline)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: radius * 0.42,
                height: radius * 0.42,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _hasValidImage(String? url) {
    if (url == null) return false;
    if (url.isEmpty) return false;

    return url.startsWith('http');
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return "?";
    }

    final parts = name.trim().split(" ");

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}