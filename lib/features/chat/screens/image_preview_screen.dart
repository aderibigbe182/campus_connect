import 'dart:io';

import 'package:flutter/material.dart';

class ImagePreviewScreen extends StatefulWidget {
  final File imageFile;

  const ImagePreviewScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<ImagePreviewScreen> createState() =>
      _ImagePreviewScreenState();
}

class _ImagePreviewScreenState
    extends State<ImagePreviewScreen> {
  final TextEditingController _captionController =
      TextEditingController();

  bool _sending = false;

  Future<void> _sendImage() async {
    setState(() {
      _sending = true;
    });

    // Temporary upload delay.
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    Navigator.pop(
      context,
      {
        "image": widget.imageFile,
        "caption":
            _captionController.text.trim(),
      },
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

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
        title: const Text(
          "Preview",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: Center(
                child: Hero(
                  tag: widget.imageFile.path,
                  child: InteractiveViewer(
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black87,
              child: Column(
                children: [

                  TextField(
                    controller: _captionController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText:
                          "Add a caption...",
                      hintStyle: TextStyle(
                        color:
                            Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor:
                          Colors.grey.shade900,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [

                      Expanded(
                        child: OutlinedButton(
                          onPressed: _sending
                              ? null
                              : () {
                                  Navigator.pop(
                                      context);
                                },
                          style:
                              OutlinedButton.styleFrom(
                            foregroundColor:
                                Colors.white,
                          ),
                          child: const Text(
                            "Cancel",
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _sending
                              ? null
                              : _sendImage,
                          icon: _sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                    color:
                                        Colors
                                            .white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                ),
                          label: Text(
                            _sending
                                ? "Sending..."
                                : "Send",
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
