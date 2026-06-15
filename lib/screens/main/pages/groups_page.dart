import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/services/group_service.dart';
import '../../../widgets/group_tile.dart';

class GroupsPage extends StatelessWidget {

  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return SafeArea(

      child: Column(

        children: [

          // SEARCH
          Padding(

            padding:
                const EdgeInsets.all(15),

            child: TextField(

              decoration: InputDecoration(

                hintText:
                    "Search name or number",

                prefixIcon:
                    const Icon(Icons.search),

                filled: true,

                fillColor:
                    Colors.grey.shade100,

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(15),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),
          ),

          // GROUP LIST
          Expanded(

            child:
                StreamBuilder<QuerySnapshot>(

              stream:
                  GroupService.getGroups(),

              builder: (context, snapshot) {

                if (!snapshot.hasData) {

                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final groups =
                    snapshot.data!.docs;

                if (groups.isEmpty) {

                  return const Center(

                    child: Text(

                      "No groups yet",

                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  );
                }

                return ListView.builder(

                  itemCount: groups.length,

                  itemBuilder:
                      (context, index) {

                    final data =
                        groups[index];

                    return GroupTile(

                      name: data['name'],

                      message:
                          data['lastMessage'],

                      time:
                          data['lastMessageTime'],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}