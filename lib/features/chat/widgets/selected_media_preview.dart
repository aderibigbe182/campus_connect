import 'dart:io';

import 'package:flutter/material.dart';

class SelectedMediaPreview extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const SelectedMediaPreview({
    super.key,
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.fromLTRB(
        12,
        8,
        12,
        0,
      ),
      AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: 1,
        child: Hero(
            tag: image.path,
            child: Image.file(
            image,
            width: 140,
            height: 140,
            fit: BoxFit.cover,
            ),
        ),
        )
      alignment: Alignment.centerLeft,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(14),
            child: Image.file(
              image,
              width: 140,
              height: 140,
              fit: BoxFit.cover,
              Hero(
                tag: image.path,
                child: Image.file(
                    image,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                ),
              )
            ),
          ),

          Positioned(
            top: 6,
            right: 6,
            child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onRemove,
                child: Container(
              onTap: onRemove,
              child: Container(
                decoration:
                    const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding:
                    const EdgeInsets.all(4),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}