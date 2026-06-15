import 'package:flutter/material.dart';

class CallsScreen extends StatelessWidget {

  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Calls"),
      ),

      body: const Center(

        child: Text(

          "Call Logs",

          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}