import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> searchUsers(
      String query) async {

    final result = await firestore
        .collection("users")
        .where("searchKeywords",
            arrayContains: query.toLowerCase())
        .get();

    return result.docs;
  }
}