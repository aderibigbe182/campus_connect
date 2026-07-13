import 'package:flutter/material.dart';

class ChatFilterChips extends StatefulWidget {
  const ChatFilterChips({super.key});

  @override
  State<ChatFilterChips> createState() =>
      _ChatFilterChipsState();
}

class _ChatFilterChipsState
    extends State<ChatFilterChips> {

  int selected = 0;

  final filters = const [
    "All",
    "Unread",
    "Groups",
    "Requests",
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final active = selected == index;

          return ChoiceChip(
            label: Text(filters[index]),
            selected: active,
            onSelected: (_) {
              setState(() {
                selected = index;
              });
            },
          );
        },
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemCount: filters.length,
      ),
    );
  }
}
