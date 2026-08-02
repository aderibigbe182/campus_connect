import 'package:flutter/material.dart';
import 'highlight_text.dart';

class SearchResultTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final String searchQuery;

  const SearchResultTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: leading,
        title: HighlightText(
  text: title,
  query: searchQuery,
  style: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
  ),
),
        subtitle:
            subtitle == null
                ? null
                : HighlightText(
                    text: subtitle!,
                    query: searchQuery,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
        onTap: onTap,
      ),
    );
  }
}