import 'dart:io';

import 'package:flutter/material.dart';

class ImageViewScreen extends StatelessWidget {
  final TransformationController
    _controller = TransformationController();
  final File image;

  const ImageViewScreen({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      @override
        void dispose() {
          _controller.dispose();
          super.dispose();
        }
      body: Center(
        child: Hero(
          transitionOnUserGestures: true,
          tag: image.path,
          child: InteractiveViewer(
              clipBehavior: Clip.none,
              boundaryMargin:
                  const EdgeInsets.all(60),
               GestureDetector(
  onDoubleTap: () {
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();
    } else {
      _controller.value =
          Matrix4.identity()
            ..scale(2.5);
    }
  },
  child: InteractiveViewer(
    transformationController: _controller, 
              minScale: 1,
              maxScale: 5,
            minScale: 1,
            maxScale: 5,
            child: Image.file(image),
          ),
        ),
      ),
    );
  }
}