import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../widgets/story_tile.dart';
import '../../stories/create_story_screen.dart';
import '../../stories/story_viewer_screen.dart';

class StoriesPage extends StatelessWidget {

  const StoriesPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: Padding(

          padding:
              const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Row(

                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [

                  const Text(

                    "Stories",

                    style: TextStyle(
                      fontSize: 30,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  IconButton(

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              const CreateStoryScreen(),
                        ),
                      );
                    },

                    icon: const Icon(
                      Icons.add_circle,
                      size: 30,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(

                child: StreamBuilder<QuerySnapshot>(

                  stream:
                      FirebaseFirestore.instance
                          .collection(
                              'stories')
                          .snapshots(),

                  builder:
                      (context, snapshot) {

                    if (!snapshot.hasData) {

                      return const Center(
                        child:
                            CircularProgressIndicator(),
                      );
                    }

                    final docs =
                        snapshot.data!.docs;

                    if (docs.isEmpty) {

                      return const Center(

                        child: Text(
                          "No stories yet",
                        ),
                      );
                    }

                    return GridView.builder(

                      itemCount: docs.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(

                        crossAxisCount: 3,
                      ),

                      itemBuilder:
                          (context, index) {

                        final data =
                            docs[index];

                        return StoryTile(

                          image:
                              data['mediaUrl'],

                          username:
                              data['username'],

                          onTap: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) =>
                                    StoryViewerScreen(
                                  image: data[
                                      'mediaUrl'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}