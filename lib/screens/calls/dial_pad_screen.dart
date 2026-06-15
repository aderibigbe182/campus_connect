import 'package:flutter/material.dart';

class DialPadScreen extends StatefulWidget {

  const DialPadScreen({super.key});

  @override
  State<DialPadScreen> createState() =>
      _DialPadScreenState();
}

class _DialPadScreenState
    extends State<DialPadScreen> {

  String number = '';

  void addNumber(String value) {

    setState(() {
      number += value;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Dial Pad"),
      ),

      body: Column(

        children: [

          const SizedBox(height: 30),

          Text(

            number,

            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          Expanded(

            child: GridView.count(

              crossAxisCount: 3,

              children: [

                ...[
                  '1','2','3',
                  '4','5','6',
                  '7','8','9',
                  '*','0','#',
                ].map((e) {

                  return GestureDetector(

                    onTap: () => addNumber(e),

                    child: Center(

                      child: CircleAvatar(

                        radius: 35,

                        child: Text(

                          e,

                          style: const TextStyle(
                            fontSize: 28,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          Padding(

            padding: const EdgeInsets.all(20),

            child: CircleAvatar(

              radius: 35,

              backgroundColor: Colors.green,

              child: IconButton(

                onPressed: () {

                  // START CALL
                },

                icon: const Icon(
                  Icons.call,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}