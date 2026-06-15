import 'package:flutter/material.dart';

class StoryScreen extends StatelessWidget {

  const StoryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Stories"),
      ),

      body: const Center(

        child: Text(

          "Stories Page",

          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}