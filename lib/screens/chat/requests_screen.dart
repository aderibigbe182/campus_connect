import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestsScreen extends StatelessWidget {

  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Message Requests"),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("chat_requests")
            .where("receiverId",
                isEqualTo:
                    "CURRENT_USER_ID")
            .where("status",
                isEqualTo: "pending")
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final requests =
              snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,

            itemBuilder: (context, index) {

              final request =
                  requests[index];

              return ListTile(

                title: Text(
                    request["firstMessage"]),

                subtitle: Text(
                    request["senderId"]),

                trailing: ElevatedButton(

                  child:
                      const Text("Accept"),

                  onPressed: () async {

                    await FirebaseFirestore
                        .instance
                        .collection(
                            "chat_requests")
                        .doc(request.id)
                        .update({
                      "status": "accepted"
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}