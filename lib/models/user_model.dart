import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {

  final String uid;
  final String fullName;
  final String username;
  final String email;
  final String profileImage;
  final String phone;
  final bool online;
  final Timestamp? lastSeen;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.username,
    required this.email,
    required this.profileImage,
    required this.phone,
    required this.online,
    required this.lastSeen,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {

    return UserModel(

      uid: map['uid'] ?? '',

      fullName: map['fullName'] ?? '',

      username: map['username'] ?? '',

      email: map['email'] ?? '',

      profileImage: map['profileImage'] ?? '',

      phone: map['phone'] ?? '',

      online: map['online'] ?? false,

      lastSeen: map['lastSeen'],
    );
  }

  Map<String, dynamic> toMap() {

    return {

      'uid': uid,

      'fullName': fullName,

      'username': username,

      'email': email,

      'profileImage': profileImage,

      'phone': phone,

      'online': online,

      'lastSeen': lastSeen,
    };
  }
}