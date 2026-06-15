import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../widgets/user_tile.dart';

class SearchScreen extends StatefulWidget {

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen> {

  final searchController =
      TextEditingController();

  String searchText = '';

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: TextField(

          controller: searchController,

          autofocus: true,

          decoration: const InputDecoration(

            hintText:
                "Search username, email or phone",

            border: InputBorder.none,
          ),

          onChanged: (value) {

            setState(() {

              searchText =
                  value.toLowerCase();
            });
          },
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection('users')
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final users =
              snapshot.data!.docs;

          final filteredUsers =
              users.where((user) {

            final data =
                user.data()
                    as Map<String, dynamic>;

            final username =
                data['username']
                        ?.toString()
                        .toLowerCase() ??
                    '';

            final email =
                data['email']
                        ?.toString()
                        .toLowerCase() ??
                    '';

            final phone =
                data['phone']
                        ?.toString()
                        .toLowerCase() ??
                    '';

            return username.contains(
                    searchText) ||
                email.contains(
                    searchText) ||
                phone.contains(
                    searchText);
          }).toList();

          if (filteredUsers.isEmpty) {

            return const Center(
              child: Text(
                "No users found",
              ),
            );
          }

          return ListView.builder(

            itemCount:
                filteredUsers.length,

            itemBuilder: (context, index) {

              final data =
                  filteredUsers[index]
                          .data()
                      as Map<String, dynamic>;

              return UserTile(

                uid: data['uid'],

                name:
                    data['fullName'] ??
                        '',

                username:
                    data['username'] ??
                        '',

                image:
                    data['profileImage'] ??
                        '',

                online:
                    data['online'] ??
                        false,
              );
            },
          );
        },
      ),
    );
  }
}