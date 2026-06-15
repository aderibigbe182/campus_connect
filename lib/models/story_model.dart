import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {

  final String id;
  final String userId;
  final String username;
  final String mediaUrl;
  final String mediaType;
  final String caption;
  final Timestamp createdAt;
  final Timestamp expiresAt;

  StoryModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.mediaUrl,
    required this.mediaType,
    required this.caption,
    required this.createdAt,
    required this.expiresAt,
  });

  factory StoryModel.fromMap(Map<String, dynamic> map) {

    return StoryModel(

      id: map['id'],

      userId: map['userId'],

      username: map['username'],

      mediaUrl: map['mediaUrl'],

      mediaType: map['mediaType'],

      caption: map['caption'],

      createdAt: map['createdAt'],

      expiresAt: map['expiresAt'],
    );
  }

  Map<String, dynamic> toMap() {

    return {

      'id': id,

      'userId': userId,

      'username': username,

      'mediaUrl': mediaUrl,

      'mediaType': mediaType,

      'caption': caption,

      'createdAt': createdAt,

      'expiresAt': expiresAt,
    };
  }
}