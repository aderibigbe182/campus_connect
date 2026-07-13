import 'package:flutter/material.dart';

class ChatRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const ChatRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xff2563EB),
      backgroundColor: Colors.white,
      strokeWidth: 3,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
