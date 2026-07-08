import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/help_feedback_model.dart';
import '../../repositories/help_feedback_repository.dart';

class HelpFeedbackPage extends StatefulWidget {
  const HelpFeedbackPage({super.key});

  @override
  State<HelpFeedbackPage> createState() =>
      _HelpFeedbackPageState();
}

class _HelpFeedbackPageState
    extends State<HelpFeedbackPage> {
  final HelpFeedbackRepository repository =
      HelpFeedbackRepository.instance;

  HelpFeedbackSettings settings =
      HelpFeedbackSettings.defaults();

  bool isLoading = true;
  bool isSaving = false;

  String? errorMessage;

  String syncStatus = "All changes saved";

  Timer? saveTimer;

  final TextEditingController subjectController =
      TextEditingController();

  final TextEditingController messageController =
      TextEditingController();

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
      settings =
          await repository.syncSettings();
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

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        duration:
            const Duration(milliseconds: 800),
        backgroundColor:
            success ? Colors.green : Colors.red,
        content: Text(
          success
              ? "Settings saved"
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

  Future<void> submitFeedback() async {
    if (subjectController.text.trim().isEmpty ||
        messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please complete all fields.",
          ),
        ),
      );
      return;
    }

    final success =
        await repository.sendFeedback(
      subject: subjectController.text.trim(),
      message: messageController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        backgroundColor:
            success ? Colors.green : Colors.red,
        content: Text(
          success
              ? "Feedback sent successfully."
              : "Failed to send feedback.",
        ),
      ),
    );

    if (success) {
      subjectController.clear();
      messageController.clear();
    }
  }

  void updateSettings(
    HelpFeedbackSettings newSettings,
  ) {
    setState(() {
      settings = newSettings;
    });

    debounceSave();
  }

  @override
  void dispose() {
    saveTimer?.cancel();
    subjectController.dispose();
    messageController.dispose();
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
            "Help & Feedback",
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
            "Help & Feedback",
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
                  Icons.support_agent,
                  size: 70,
                  color: Colors.red,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Couldn't load settings",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

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
          "Help & Feedback",
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

                      Text("Saving settings..."),

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

              buildInfoTile(
                title: "App Version",
                value: settings.appVersion,
                icon: Icons.info_outline,
              ),

              buildInfoTile(
                title: "Support Email",
                value: settings.supportEmail,
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 16),

              buildSwitchTile(
                "Crash Reports",
                settings.crashReports,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      crashReports: value,
                    ),
                  );
                },
              ),

              buildSwitchTile(
                "Diagnostics",
                settings.diagnostics,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      diagnostics: value,
                    ),
                  );
                },
              ),

              buildSwitchTile(
                "Usage Analytics",
                settings.usageAnalytics,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      usageAnalytics: value,
                    ),
                  );
                },
              ),

              buildSwitchTile(
                "Receive Replies",
                settings.contactReplies,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      contactReplies: value,
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              buildTextField(
                controller: subjectController,
                label: "Subject",
              ),

              buildTextField(
                controller: messageController,
                label: "Message",
                maxLines: 6,
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: submitFeedback,
                    icon: const Icon(Icons.send),
                    label: const Text(
                      "Send Feedback",
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
        contentPadding:
            const EdgeInsets.symmetric(
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
  Widget buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
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
        subtitle: Text(value),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.blue,
            ),
          ),
        ),
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
}