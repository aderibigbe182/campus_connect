import 'package:flutter/material.dart';

class ConversationAppBar extends StatelessWidget {
  final String recipientName;
  final String? profilePicture;
  final bool isOnline;
  final String? lastSeen;
void _startVoiceCall(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Voice calling will be available in Phase 12.",
      ),
    ),
  );
}

void _startVideoCall(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Video calling will be available in Phase 12.",
      ),
    ),
  );
}

void _handleMenuAction(
  BuildContext context,
  String value,
) {
  switch (value) {
    case "view_profile":
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("View Profile"),
        ),
      );
      break;

    case "search":
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Search Conversation"),
        ),
      );
      break;

    case "media":
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Shared Media"),
        ),
      );
      break;

    case "mute":
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mute Conversation"),
        ),
      );
      break;

    case "block":
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Block User"),
        ),
      );
      break;

    case "report":
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Report User"),
        ),
      );
      break;
  }
}
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
              onPressed: () => _startVoiceCall(context),
              icon: const Icon(Icons.call_outlined),
            ),

            IconButton(
              onPressed: () => _startVideoCall(context),
              icon: const Icon(Icons.videocam_outlined),
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                _handleMenuAction(
                  context,
                  value,
                );
              },
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
