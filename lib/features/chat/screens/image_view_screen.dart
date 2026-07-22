import 'dart:io';

import 'package:flutter/material.dart';

class ImageViewScreen extends StatelessWidget {
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
      body: Center(
        child: Hero(
          tag: image.path,
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Image.file(image),
          ),
        ),
      ),
    );
  }
}