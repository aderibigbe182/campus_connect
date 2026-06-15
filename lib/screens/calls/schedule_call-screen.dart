import 'package:flutter/material.dart';

class ScheduleCallScreen
    extends StatefulWidget {

  const ScheduleCallScreen({
    super.key,
  });

  @override
  State<ScheduleCallScreen> createState() =>
      _ScheduleCallScreenState();
}

class _ScheduleCallScreenState
    extends State<ScheduleCallScreen> {

  DateTime? selectedDate;

  Future<void> pickDate() async {

    final picked = await showDatePicker(

      context: context,

      firstDate: DateTime.now(),

      lastDate: DateTime(2030),

      initialDate: DateTime.now(),
    );

    if (picked != null) {

      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Schedule Call"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(

              "Select Date",

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(

              onPressed: pickDate,

              child: const Text(
                "Choose Date",
              ),
            ),

            const SizedBox(height: 20),

            if (selectedDate != null)

              Text(
                selectedDate.toString(),
              ),
          ],
        ),
      ),
    );
  }
}