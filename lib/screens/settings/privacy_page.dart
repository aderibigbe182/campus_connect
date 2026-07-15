import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/privacy_settings.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() =>
      _PrivacyPageState();
}

class _PrivacyPageState
    extends State<PrivacyPage> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

  PrivacySettings settings =
      PrivacySettings.defaults();

  bool isLoading = true;
  bool isSaving = false;

  String? errorMessage;

  String syncStatus = "All changes saved";

  Timer? saveTimer;

  final List<String> privacyOptions = const [
    "Everyone",
    "My contacts",
    "Nobody",
  ];

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

    final bool success = await Future<bool>.delayed(
      const Duration(milliseconds: 300),
      () => true,
    );

    if (!mounted) return;

    setState(() {
      isSaving = false;
      syncStatus = success ? "All changes saved" : "Failed to save changes";
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 800),
        backgroundColor: success ? Colors.green : Colors.red,
        content: Text(
          success
              ? "Privacy settings saved"
              : "Failed to save privacy settings",
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
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Reset Privacy Settings",
          ),
          content: const Text(
            "Restore all privacy settings to their default values?",
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

    if (confirm != true) return;


    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Privacy settings reset",
        ),
      ),
    );
  }

  void updateSettings(
    PrivacySettings newSettings,
  ) {
    setState(() {
      settings = newSettings;
    });

    debounceSave();
  }

  @override
  void dispose() {
    saveTimer?.cancel();
    super.dispose();
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
            "Privacy",
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
            "Privacy",
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
                  Icons.lock_outline,
                  color: Colors.red,
                  size: 70,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Couldn't load privacy settings",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: initializePage,
                  child: const Text(
                    "Retry",
                  ),
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
          "Privacy",
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

              const SizedBox(height: 20),

              buildDropdownTile(
                title: "Last Seen & Online",
                value: settings.lastSeen,
                items: privacyOptions,
                onChanged: (value) {
                  updateSettings(
                    settings.copyWith(
                      lastSeen: value!,
                    ),
                  );
                },
              ),

              buildDropdownTile(
                title: "Profile Photo",
                value: settings.profilePhoto,
                items: privacyOptions,
                onChanged: (value) {
                  updateSettings(
                    settings.copyWith(
                      profilePhoto: value!,
                    ),
                  );
                },
              ),

              buildDropdownTile(
                title: "About",
                value: settings.about,
                items: privacyOptions,
                onChanged: (value) {
                  updateSettings(
                    settings.copyWith(
                      about: value!,
                    ),
                  );
                },
              ),

              buildDropdownTile(
                title: "Status",
                value: settings.status,
                items: privacyOptions,
                onChanged: (value) {
                  updateSettings(
                    settings.copyWith(
                      status: value!,
                    ),
                  );
                },
              ),

              buildDropdownTile(
                title: "Groups",
                value: settings.groups,
                items: privacyOptions,
                onChanged: (value) {
                  updateSettings(
                    settings.copyWith(
                      groups: value!,
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              buildSwitchTile(
                "Read Receipts",
                settings.readReceipts,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      readReceipts: value,
                    ),
                  );
                },
              ),

              buildSwitchTile(
                "Automatically Accept Requests",
                settings.autoAcceptRequests,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      autoAcceptRequests:
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
                    onPressed: resetSettings,
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
                    icon: const Icon(
                      Icons.restart_alt,
                    ),
                    label: const Text(
                      "Reset Privacy Settings",
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

Widget buildDropdownTile({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.blue,
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget buildSwitchTile(
    String title,
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
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        value: value,
        activeColor: Colors.blue,
        onChanged: onChanged,
      ),
    );
  }

  Widget buildActionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
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
          color: Colors.blue,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> showResetDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
          title: const Text(
            "Reset Privacy Settings",
          ),
          content: const Text(
            "Are you sure you want to restore all privacy settings to their default values?",
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
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
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