import 'package:cloud_firestore/cloud_firestore.dart';

class CallService {

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static Future<void> createCall({
    required String callerId,
    required String receiverId,
    required String callerName,
    required String receiverName,
    required String type,
  }) async {

    await _firestore.collection('calls').add({

      'callerId': callerId,
      'receiverId': receiverId,

      'callerName': callerName,
      'receiverName': receiverName,

      'type': type,

      'status': 'outgoing',

      'duration': 0,

      'timestamp': Timestamp.now(),
    });
  }

  static Stream<QuerySnapshot> getCalls() {

    return _firestore
        .collection('calls')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}