import 'package:flutter/material.dart';

class StoryLoading extends StatelessWidget {
  const StoryLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 6,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade300,
              ),

              const SizedBox(height: 8),

              Container(
                width: 60,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}