import 'package:flutter/material.dart';

class HighlightText extends StatelessWidget {
  final String text;
  final String query;

  final TextStyle? style;
  final TextStyle? highlightStyle;

  const HighlightText({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return Text(
        text,
        style: style,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final matchIndex =
        lowerText.indexOf(lowerQuery);

    if (matchIndex == -1) {
      return Text(
        text,
        style: style,
      );
    }

    final before =
        text.substring(0, matchIndex);

    final match = text.substring(
      matchIndex,
      matchIndex + query.length,
    );

    final after = text.substring(
      matchIndex + query.length,
    );

    return RichText(
      text: TextSpan(
        children: [

          TextSpan(
            text: before,
            style: style,
          ),

          TextSpan(
            text: match,
            style:
                highlightStyle ??
                    style?.copyWith(
                      color: Colors.blue,
                      fontWeight:
                          FontWeight.bold,
                    ) ??
                    const TextStyle(
                      color: Colors.blue,
                      fontWeight:
                          FontWeight.bold,
                    ),
          ),

          TextSpan(
            text: after,
            style: style,
          ),
        ],
      ),
    );
  }
}