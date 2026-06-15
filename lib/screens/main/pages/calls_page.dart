import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/services/call_service.dart';
import '../../../widgets/call_tile.dart';

class CallsPage extends StatefulWidget {

  const CallsPage({super.key});

  @override
  State<CallsPage> createState() =>
      _CallsPageState();
}

class _CallsPageState
    extends State<CallsPage> {

  final searchController =
      TextEditingController();

  String searchText = "";

  @override
  Widget build(BuildContext context) {

    return SafeArea(

      child: Column(

        children: [

          // ===================================
          // SEARCH BAR
          // ===================================

          Padding(

            padding: const EdgeInsets.all(15),

            child: TextField(

              controller: searchController,

              onChanged: (value) {

                setState(() {

                  searchText =
                      value.toLowerCase();
                });
              },

              decoration: InputDecoration(

                hintText: "Search calls",

                prefixIcon:
                    const Icon(Icons.search),

                filled: true,

                fillColor:
                    Colors.grey.shade100,

                border: OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                          15),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),
          ),

          // ===================================
          // ACTION BUTTONS
          // ===================================

          Padding(

            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
            ),

            child: Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                _buildAction(

                  icon: Icons.call,

                  label: "Call",

                  onTap: () {

                    Navigator.pushNamed(
                      context,
                      '/search',
                    );
                  },
                ),

                _buildAction(

                  icon: Icons.schedule,

                  label: "Schedule",

                  onTap: () {

                    _showScheduleDialog(
                        context);
                  },
                ),

                _buildAction(

                  icon: Icons.dialpad,

                  label: "Keypad",

                  onTap: () {

                    _showDialPad(context);
                  },
                ),

                _buildAction(

                  icon: Icons.favorite,

                  label: "Favorite",

                  onTap: () {

                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(

                      const SnackBar(

                        content: Text(
                          "Favorites coming soon",
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ===================================
          // RECENT TITLE
          // ===================================

          const Padding(

            padding:
                EdgeInsets.symmetric(
              horizontal: 20,
            ),

            child: Align(

              alignment:
                  Alignment.centerLeft,

              child: Text(

                "Recent",

                style: TextStyle(

                  fontSize: 24,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ===================================
          // CALL LIST
          // ===================================

          Expanded(

            child:
                StreamBuilder<QuerySnapshot>(

              stream:
                  CallService.getCalls(),

              builder:
                  (context, snapshot) {

                if (!snapshot.hasData) {

                  return const Center(

                    child:
                        CircularProgressIndicator(),
                  );
                }

                final calls =
                    snapshot.data!.docs;

                final filteredCalls =
                    calls.where((call) {

                  final data =
                      call.data()
                          as Map<String,
                              dynamic>;

                  final name =
                      data['receiverName']
                          .toString()
                          .toLowerCase();

                  return name.contains(
                    searchText,
                  );

                }).toList();

                if (filteredCalls
                    .isEmpty) {

                  return const Center(

                    child: Text(

                      "No calls yet",

                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(

                  itemCount:
                      filteredCalls.length,

                  itemBuilder:
                      (context, index) {

                    final data =
                        filteredCalls[index]
                                .data()
                            as Map<String,
                                dynamic>;

                    return CallTile(

                      name:
                          data['receiverName'] ??
                              "Unknown",

                      time:
                          data['time'] ??
                              "10:20",

                      status:
                          data['status'] ??
                              "outgoing",

                      isVideo:
                          data['isVideo'] ??
                              false,

                      onTap: () {

                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(

                          SnackBar(

                            content: Text(
                              "Calling ${data['receiverName']}",
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
    );
  }

  // ===================================
  // ACTION BUTTON
  // ===================================

  Widget _buildAction({

    required IconData icon,

    required String label,

    required VoidCallback onTap,
  }) {

    return GestureDetector(

      onTap: onTap,

      child: Column(

        children: [

          CircleAvatar(

            radius: 28,

            backgroundColor:
                Colors.grey.shade200,

            child: Icon(
              icon,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          Text(

            label,

            style: const TextStyle(
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ===================================
  // DIAL PAD
  // ===================================

  void _showDialPad(
      BuildContext context) {

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      builder: (context) {

        String number = "";

        return StatefulBuilder(

          builder:
              (context, setState) {

            return Container(

              padding:
                  const EdgeInsets.all(
                      20),

              height: 580,

              child: Column(

                children: [

                  // ===================
                  // TOP BAR
                  // ===================

                  Row(

                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [

                      TextButton(

                        onPressed: () {

                          Navigator.pop(
                              context);
                        },

                        child: const Text(

                          "Cancel",

                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),

                      const Text(

                        "Dial Pad",

                        style: TextStyle(

                          fontSize: 24,

                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      IconButton(

                        onPressed: () {

                          if (number
                              .isNotEmpty) {

                            setState(() {

                              number =
                                  number.substring(
                                0,
                                number.length -
                                    1,
                              );
                            });
                          }
                        },

                        icon: const Icon(
                          Icons.backspace,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 20),

                  // ===================
                  // NUMBER DISPLAY
                  // ===================

                  Text(

                    number.isEmpty
                        ? "Enter Number"
                        : number,

                    style:
                        const TextStyle(

                      fontSize: 32,

                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),

                  const SizedBox(
                      height: 30),

                  // ===================
                  // KEYPAD
                  // ===================

                  Expanded(

                    child:
                        GridView.builder(

                      itemCount: 12,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(

                        crossAxisCount:
                            3,

                        mainAxisSpacing:
                            15,

                        crossAxisSpacing:
                            15,
                      ),

                      itemBuilder:
                          (context,
                              index) {

                        final buttons = [

                          '1',
                          '2',
                          '3',

                          '4',
                          '5',
                          '6',

                          '7',
                          '8',
                          '9',

                          '*',
                          '0',
                          '#',
                        ];

                        return GestureDetector(

                          onTap: () {

                            setState(() {

                              number +=
                                  buttons[
                                      index];
                            });
                          },

                          child:
                              CircleAvatar(

                            radius: 35,

                            backgroundColor:
                                Colors
                                    .grey
                                    .shade200,

                            child: Text(

                              buttons[
                                  index],

                              style:
                                  const TextStyle(

                                fontSize:
                                    28,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  // ===================
                  // CALL BUTTON
                  // ===================

                  FloatingActionButton(

                    backgroundColor:
                        Colors.green,

                    onPressed: () {

                      if (number
                          .isEmpty) {
                        return;
                      }

                      Navigator.pop(
                          context);

                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(

                        SnackBar(

                          content: Text(
                            "Calling $number",
                          ),
                        ),
                      );
                    },

                    child: const Icon(
                      Icons.call,
                      color:
                          Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ===================================
  // SCHEDULE DIALOG
  // ===================================

  void _showScheduleDialog(
      BuildContext context) async {

    final selectedDate =
        await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime.now(),

      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(

            "Call scheduled for "
            "${selectedDate.day}/"
            "${selectedDate.month}/"
            "${selectedDate.year}",
          ),
        ),
      );
    }
  }
}