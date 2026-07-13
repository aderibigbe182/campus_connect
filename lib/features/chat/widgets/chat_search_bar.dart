import 'package:flutter/material.dart';

class ChatSearchBar extends StatelessWidget {
  const ChatSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: const Color(0xffF3F5F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
