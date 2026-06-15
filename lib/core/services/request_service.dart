import 'package:cloud_firestore/cloud_firestore.dart';

class RequestService {

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  Future<void> sendRequest({
    required String senderId,
    required String receiverId,
    required String firstMessage,
  }) async {

    await firestore.collection("chat_requests").add({
      "senderId": senderId,
      "receiverId": receiverId,
      "firstMessage": firstMessage,
      "status": "pending",
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptRequest(String requestId) async {

    await firestore
        .collection("chat_requests")
        .doc(requestId)
        .update({
      "status": "accepted"
    });
  }
}