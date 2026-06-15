import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../models/story_model.dart';
import 'storage_service.dart';

class StoryService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // StorageService methods are static; no instance required.

  Future<void> uploadStory({

    required Uint8List fileBytes,

    required String userId,

    required String username,

    required String mediaType,

    String caption = '',
  }) async {

    final id = const Uuid().v4();

    // uploadFile returns String? so handle potential null
    final String? uploadedUrl = await StorageService.uploadFile(
      fileBytes: fileBytes,
      fileName: '$id.jpg',
    );

    if (uploadedUrl == null) {
      throw Exception('Failed to upload story media');
    }

    final String mediaUrl = uploadedUrl;

    final story = StoryModel(

      id: id,

      userId: userId,

      username: username,

      mediaUrl: mediaUrl,

      mediaType: mediaType,

      caption: caption,

      createdAt: Timestamp.now(),

      expiresAt: Timestamp.fromDate(
        DateTime.now().add(
          const Duration(hours: 24),
        ),
      ),
    );

    await _firestore
        .collection('stories')
        .doc(id)
        .set(story.toMap());
  }

  Stream<QuerySnapshot> getStories() {

    return _firestore
        .collection('stories')
        .orderBy('createdAt',
            descending: true)
        .snapshots();
  }
}