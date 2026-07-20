import 'package:flutter/material.dart';

class AttachmentSheet extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final VoidCallback onDocument;
  final VoidCallback onLocation;
  final VoidCallback onContact;

  const AttachmentSheet({
    super.key,
    required this.onGallery,
    required this.onCamera,
    required this.onDocument,
    required this.onLocation,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    Widget item(
      IconData icon,
      Color color,
      String title,
      VoidCallback onTap,
    ) {
      return GestureDetector(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color,
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(title),
          ],
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 30,
          runSpacing: 24,
          children: [
            item(
              Icons.photo,
              Colors.purple,
              "Gallery",
              onGallery,
            ),
            item(
              Icons.camera_alt,
              Colors.red,
              "Camera",
              onCamera,
            ),
            item(
              Icons.insert_drive_file,
              Colors.blue,
              "Document",
              onDocument,
            ),
            item(
              Icons.location_on,
              Colors.green,
              "Location",
              onLocation,
            ),
            item(
              Icons.person,
              Colors.orange,
              "Contact",
              onContact,
            ),
          ],
        ),
      ),
    );
  }
}