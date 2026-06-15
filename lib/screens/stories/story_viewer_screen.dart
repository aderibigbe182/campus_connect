import 'package:flutter/material.dart';

class StoryViewerScreen
    extends StatelessWidget {

  final String image;

  const StoryViewerScreen({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      body: Center(

        child: InteractiveViewer(

          child: Image.network(image),
        ),
      ),
    );
  }
}