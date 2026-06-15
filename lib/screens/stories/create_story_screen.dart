import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/story_service.dart';

class CreateStoryScreen
    extends StatefulWidget {

  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() =>
      _CreateStoryScreenState();
}

class _CreateStoryScreenState
    extends State<CreateStoryScreen> {

  Uint8List? selectedFile;

  bool isLoading = false;

  final picker = ImagePicker();

  final captionController =
      TextEditingController();

  Future<void> pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        selectedFile = bytes;
      });
    }
  }

  Future<void> uploadStory() async {

    if (selectedFile == null) return;

    setState(() {
      isLoading = true;
    });

    await StoryService().uploadStory(

      fileBytes: selectedFile!,

      userId: 'demoUser',

      username: 'Campus User',

      mediaType: 'image',

      caption:
          captionController.text,
    );

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Create Story",
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            Expanded(

              child: selectedFile == null

                  ? Container(

                      alignment:
                          Alignment.center,

                      decoration:
                          BoxDecoration(

                        border: Border.all(
                          color: Colors.grey,
                        ),
                      ),

                      child: const Text(
                        "No Image Selected",
                      ),
                    )

                  : Image.memory(
                      selectedFile!,
                      fit: BoxFit.cover,
                    ),
            ),

            const SizedBox(height: 20),

            TextField(

              controller:
                  captionController,

              decoration:
                  const InputDecoration(

                hintText:
                    "Write a caption",

                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Row(

              children: [

                Expanded(

                  child: ElevatedButton(

                    onPressed: pickImage,

                    child: const Text(
                      "Pick Image",
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(

                  child: ElevatedButton(

                    onPressed:
                        isLoading
                            ? null
                            : uploadStory,

                    child: isLoading

                        ? const CircularProgressIndicator()

                        : const Text(
                            "Upload",
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}