import 'package:cloud_firestore/cloud_firestore.dart';

class BlockService {

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  Future<void> blockUser({
    required String blockerId,
    required String blockedId,
  }) async {

    await firestore.collection("blocks").add({
      "blockerId": blockerId,
      "blockedId": blockedId,
    });
  }
}