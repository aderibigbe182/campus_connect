import 'package:flutter/material.dart';

class ConversationAppBar extends StatelessWidget {
  final String recipientName;
  final String? profilePicture;
  final bool isOnline;
  final String? lastSeen;

  const ConversationAppBar({
    super.key,
    required this.recipientName,
    this.profilePicture,
    required this.isOnline,
    this.lastSeen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios_new),
            ),

            Hero(
              tag: "avatar_$recipientName",
              flightShuttleBuilder: (
                flightContext,
                animation,
                direction,
                fromContext,
                toContext,
              ) {
                return ScaleTransition(
                  scale: animation,
                  child: toContext.widget,
                );
              },
              child: CircleAvatar(
                radius: 22,
                backgroundImage: profilePicture != null
                    ? NetworkImage(profilePicture!)
                    : null,
                child: profilePicture == null
                    ? Text(
                        recipientName[0].toUpperCase(),
                      )
                    : null,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    recipientName,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Row(
                      key: ValueKey(isOnline),
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isOnline
                                ? Colors.green
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                  
                        const SizedBox(width: 6),
                  
                        Text(
                          isOnline
                              ? "Online"
                              : (lastSeen ?? "Offline"),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.call_outlined),
            ),

            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.videocam_outlined),
            ),

            PopupMenuButton<String>(
              onSelected: (_) {},
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: "view_profile",
                  child: Text("View Profile"),
                ),
                PopupMenuItem(
                  value: "search",
                  child: Text("Search"),
                ),
                PopupMenuItem(
                  value: "media",
                  child: Text("Media"),
                ),
                PopupMenuItem(
                  value: "mute",
                  child: Text("Mute"),
                ),
                PopupMenuItem(
                  value: "block",
                  child: Text("Block"),
                ),
                PopupMenuItem(
                  value: "report",
                  child: Text("Report"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
