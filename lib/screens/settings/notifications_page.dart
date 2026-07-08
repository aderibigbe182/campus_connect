import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/notification_settings.dart';
import '../../repositories/notification_repository.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState
    extends State<NotificationsPage> {
  final NotificationRepository repository =
      NotificationRepository.instance;

  NotificationSettings settings =
      NotificationSettings.defaults();

  bool isLoading = true;
  bool isSaving = false;

  String? errorMessage;

  String syncStatus = "All changes saved";

  Timer? saveTimer;

  @override
  void initState() {
    super.initState();
    initializePage();
  }

  Future<void> initializePage() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      settings = await repository.syncSettings();
    } catch (e) {
      errorMessage = e.toString();
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveSettings() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
      syncStatus = "Saving...";
    });

    final success =
        await repository.save(settings);

    if (!mounted) return;

    setState(() {
      isSaving = false;

      syncStatus = success
          ? "All changes saved"
          : "Failed to sync";
    });

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            success ? Colors.green : Colors.red,
        duration: const Duration(milliseconds: 800),
        content: Text(
          success
              ? "Notification settings saved"
              : "Couldn't sync settings",
        ),
      ),
    );
  }

  void debounceSave() {
    saveTimer?.cancel();

    saveTimer = Timer(
      const Duration(milliseconds: 600),
      () {
        saveSettings();
      },
    );
  }

  Future<void> resetSettings() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Reset Notifications",
          ),
          content: const Text(
            "Reset all notification settings to default?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text("Reset"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    settings =
        await repository.resetSettings();

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Settings reset successfully",
        ),
      ),
    );
  }

  @override
  void dispose() {
    saveTimer?.cancel();
    super.dispose();
  }

  void updateSettings(
    NotificationSettings newSettings,
  ) {
    setState(() {
      settings = newSettings;
    });

    debounceSave();
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F2F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.blue,
          ),
          title: const Text(
            "Notifications",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F2F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.blue,
          ),
          title: const Text(
            "Notifications",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [

                const Icon(
                  Icons.cloud_off,
                  color: Colors.red,
                  size: 70,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Couldn't load notification settings",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: initializePage,
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.blue,
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: initializePage,

        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              if (isSaving)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(12),
                  color: Colors.blue.shade50,
                  child: const Row(
                    children: [

                      SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),

                      SizedBox(width: 12),

                      Text(
                        "Saving settings...",
                      ),

                    ],
                  ),
                ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  syncStatus,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              buildSectionTitle("Messages"),

              buildSwitchTile(
                "Message Notifications",
                "Receive notifications for new messages",
                settings.messageNotifications,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      messageNotifications:
                          value,
                    ),
                  );
                },
              ),

              buildSwitchTile(
                "Message Preview",
                "Show message content in notifications",
                settings.messagePreview,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      messagePreview: value,
                    ),
                  );
                },
              ),

              buildSectionTitle("Groups"),

              buildSwitchTile(
                "Group Notifications",
                "Receive group message notifications",
                settings.groupNotifications,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      groupNotifications:
                          value,
                    ),
                  );
                },
              ),

              buildSwitchTile(
                "Group Preview",
                "Show previews for group messages",
                settings.groupPreview,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      groupPreview: value,
                    ),
                  );
                },
              ),

              buildSectionTitle("Calls"),

              buildSwitchTile(
                "Call Notifications",
                "Receive incoming call alerts",
                settings.callNotifications,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      callNotifications:
                          value,
                    ),
                  );
                },
              ),

              buildSectionTitle("General"),

              buildSwitchTile(
                "Notification Sound",
                "Play sound for notifications",
                settings.notificationSound,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      notificationSound:
                          value,
                    ),
                  );
                },
              ),

              buildSwitchTile(
                "Vibration",
                "Vibrate when notifications arrive",
                settings.vibration,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      vibration: value,
                    ),
                  );
                },
              ),

              buildSwitchTile(
                "Popup Notification",
                "Display pop-up notifications",
                settings.popupNotification,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      popupNotification:
                          value,
                    ),
                  );
                },
              ),

              buildSwitchTile(
                "High Priority",
                "Show notifications at the top",
                settings.highPriority,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      highPriority: value,
                    ),
                  );
                },
              ),

              buildSwitchTile(
                "Reaction Notifications",
                "Notify when someone reacts",
                settings.reactionNotifications,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      reactionNotifications:
                          value,
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: showResetDialog,
                    icon: const Icon(
                      Icons.restart_alt,
                    ),
                    label: const Text(
                      "Reset Notification Settings",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue,
                      foregroundColor:
                          Colors.white,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        value: value,
        activeColor: Colors.blue,
        onChanged: onChanged,
      ),
    );
  }

  Widget buildInfoTile(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blue,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget buildActionTile(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blue,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.blue,
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> showResetDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
          title: const Text(
            "Reset Notifications",
          ),
          content: const Text(
            "Are you sure you want to restore all notification settings to their default values?",
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                "Cancel",
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blue,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                "Reset",
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      resetSettings();
    }
  }
}