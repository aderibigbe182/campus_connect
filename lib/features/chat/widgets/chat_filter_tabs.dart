import 'package:flutter/material.dart';

class ChatFilterTabs extends StatefulWidget {
  final Function(int)? onChanged;

  const ChatFilterTabs({
    super.key,
    this.onChanged,
  });

  @override
  State<ChatFilterTabs> createState() =>
      _ChatFilterTabsState();
}

class _ChatFilterTabsState
    extends State<ChatFilterTabs> {
  int selectedIndex = 0;

  final List<String> tabs = [
    "All",
    "Unread",
    "Groups",
    "Requests",
    "Archived",
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
          final selected =
              selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });

              widget.onChanged?.call(index);
            },
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 250,
              ),
              curve: Curves.easeInOut,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xff2563EB)
                    : Colors.grey.shade200,
                borderRadius:
                    BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.black87,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) =>
            const SizedBox(width: 10),
        itemCount: tabs.length,
      ),
    );
  }
}
