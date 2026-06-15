import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  Stream<QuerySnapshot> getMessages(
      String chatId) {

    return firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp')
        .snapshots();
  }

  Future<void> sendMessage({

    required String chatId,
    required String senderId,
    required String text,

  }) async {

    await firestore
        .collection('messages')
        .add({

      "chatId": chatId,
      "senderId": senderId,
      "text": text,
      "seen": false,

      "timestamp":
          FieldValue.serverTimestamp(),
    });
  }
}