import 'package:flutter/material.dart';

class CallTile extends StatelessWidget {

  final String name;
  final String time;
  final String status;

  // NEW
  final bool isVideo;

  // NEW
  final VoidCallback? onTap;

  const CallTile({
    super.key,

    required this.name,
    required this.time,
    required this.status,

    // NEW
    this.isVideo = false,

    // NEW
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    IconData statusIcon;
    Color statusColor;

    // =========================
    // CALL STATUS ICONS
    // =========================

    if (status == "missed") {

      statusIcon =
          Icons.call_received;

      statusColor = Colors.red;

    } else if (status == "incoming") {

      statusIcon =
          Icons.call_received;

      statusColor = Colors.green;

    } else {

      statusIcon =
          Icons.call_made;

      statusColor = Colors.blue;
    }

    return ListTile(

      onTap: onTap,

      leading: CircleAvatar(

        radius: 25,

        backgroundColor:
            Colors.grey.shade300,

        child: const Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),

      // =========================
      // NAME
      // =========================

      title: Text(

        name,

        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      // =========================
      // STATUS
      // =========================

      subtitle: Row(

        children: [

          Icon(
            statusIcon,
            size: 16,
            color: statusColor,
          ),

          const SizedBox(width: 5),

          Text(status),
        ],
      ),

      // =========================
      // TRAILING
      // =========================

      trailing: Column(

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Text(

            time,

            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 5),

          Icon(

            isVideo
                ? Icons.videocam
                : Icons.call,

            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}