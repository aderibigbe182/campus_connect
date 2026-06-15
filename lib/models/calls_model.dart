import 'package:cloud_firestore/cloud_firestore.dart';

class CallModel {

  final String id;
  final String callerId;
  final String receiverId;
  final String callerName;
  final String receiverName;
  final String type;
  final String status;
  final int duration;
  final Timestamp timestamp;

  CallModel({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.callerName,
    required this.receiverName,
    required this.type,
    required this.status,
    required this.duration,
    required this.timestamp,
  });

  factory CallModel.fromMap(Map<String, dynamic> map, String docId) {

    return CallModel(
      id: docId,
      callerId: map['callerId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      callerName: map['callerName'] ?? '',
      receiverName: map['receiverName'] ?? '',
      type: map['type'] ?? '',
      status: map['status'] ?? '',
      duration: map['duration'] ?? 0,
      timestamp: map['timestamp'],
    );
  }
}