import 'package:flutter/material.dart';

class FavoriteCallsScreen
    extends StatelessWidget {

  const FavoriteCallsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Favorites"),
      ),

      body: ListView(

        children: const [

          ListTile(

            leading: CircleAvatar(
              child: Icon(Icons.person),
            ),

            title: Text("Alex"),

            subtitle: Text("Favorite Contact"),

            trailing: Icon(Icons.call),
          ),

          ListTile(

            leading: CircleAvatar(
              child: Icon(Icons.person),
            ),

            title: Text("Justina"),

            subtitle: Text("Favorite Contact"),

            trailing: Icon(Icons.call),
          ),
        ],
      ),
    );
  }
}