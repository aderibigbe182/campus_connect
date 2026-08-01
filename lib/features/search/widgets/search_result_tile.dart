import 'package:flutter/material.dart';

class SearchResultTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const SearchResultTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: leading,
        title: Text(title),
        subtitle:
            subtitle == null
                ? null
                : Text(subtitle!),
        onTap: onTap,
      ),
    );
  }
}