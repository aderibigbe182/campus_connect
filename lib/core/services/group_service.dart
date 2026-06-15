import 'package:cloud_firestore/cloud_firestore.dart';

class GroupService {

  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  // =========================
  // GET GROUPS
  // =========================

  static Stream<QuerySnapshot> getGroups() {

    return _db
        .collection('groups')
        .orderBy(
          'updatedAt',
          descending: true,
        )
        .snapshots();
  }

  // =========================
  // CREATE GROUP
  // =========================

  static Future createGroup({

    required String name,
    required List members,

  }) async {

    await _db.collection('groups').add({

      'name': name,

      'image': '',

      'members': members,

      'lastMessage': '',

      'lastMessageTime': '',

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }
}