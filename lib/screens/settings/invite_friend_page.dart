import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/invite_friend_model.dart';
import '../../repositories/invite_friend_repository.dart';

class InviteFriendPage extends StatefulWidget {
  const InviteFriendPage({super.key});

  @override
  State<InviteFriendPage> createState() =>
      _InviteFriendPageState();
}

class _InviteFriendPageState
    extends State<InviteFriendPage> {
  final InviteFriendRepository repository =
      InviteFriendRepository.instance;

  InviteFriendSettings settings =
      InviteFriendSettings.defaults();

  bool isLoading = true;
  bool isSaving = false;
  bool isGenerating = false;

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
        backgroundColor:
            success ? Colors.green : Colors.red,
        duration:
            const Duration(milliseconds: 900),
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
      saveSettings,
    );
  }

  void updateSettings(
    InviteFriendSettings newSettings,
  ) {
    setState(() {
      settings = newSettings;
    });

    debounceSave();
  }

  Future<void> generateInviteLink() async {
    setState(() {
      isGenerating = true;
    });

    final link =
        await repository.generateInviteLink();

    if (!mounted) return;

    setState(() {
      isGenerating = false;

      if (link != null) {
        settings = settings.copyWith(
          inviteLink: link,
        );
      }
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          link != null
              ? "Invite link generated"
              : "Unable to generate link",
        ),
      ),
    );
  }

  Future<void> copyInviteLink() async {
    if (settings.inviteLink.isEmpty) return;

    await Clipboard.setData(
      ClipboardData(
        text: settings.inviteLink,
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Invite link copied",
        ),
      ),
    );
  }

  Future<void> shareInvite() async {
    if (settings.inviteLink.isEmpty) {
      await generateInviteLink();
    }

    if (settings.inviteLink.isEmpty) return;

    await Share.share(
      '''
Join me on Campus Connect!

Referral Code:
${settings.referralCode}

Download here:
${settings.inviteLink}
''',
    );

    await repository.registerInviteSent();
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
            "Invite a Friend",
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
            "Invite a Friend",
            style: TextStyle(color: Colors.black),
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
                  Icons.group_add_outlined,
                  size: 70,
                  color: Colors.red,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Couldn't load invite information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

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
          "Invite a Friend",
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

              const SizedBox(height: 18),

              buildReferralCard(
                code: settings.referralCode,
                link: settings.inviteLink,
              ),

              const SizedBox(height: 16),

              buildStatisticsCard(
                totalInvites:
                    settings.totalInvites,
                successfulInvites:
                    settings.successfulInvites,
                rewardPoints:
                    settings.rewardPoints,
              ),

              const SizedBox(height: 16),

              buildSwitchTile(
                "Invite Notifications",
                settings.notificationsEnabled,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      notificationsEnabled:
                          value,
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        isGenerating
                            ? null
                            : generateInviteLink,
                    icon:
                        isGenerating
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.white,
                              ),
                            )
                            : const Icon(
                              Icons.refresh,
                            ),
                    label: const Text(
                      "Generate Invite Link",
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

              const SizedBox(height: 12),

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(
                  children: [

                    Expanded(
                      child:
                          OutlinedButton.icon(
                        onPressed:
                            copyInviteLink,
                        icon: const Icon(
                          Icons.copy,
                        ),
                        label: const Text(
                          "Copy Link",
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child:
                          ElevatedButton.icon(
                        onPressed:
                            shareInvite,
                        icon: const Icon(
                          Icons.share,
                        ),
                        label: const Text(
                          "Share",
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blue,
                          foregroundColor:
                              Colors.white,
                        ),
                      ),
                    ),

                  ],
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

  Widget buildReferralCard({
    required String code,
    required String link,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const Icon(
              Icons.card_giftcard,
              size: 48,
              color: Colors.blue,
            ),

            const SizedBox(height: 16),

            const Text(
              "Your Referral Code",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 8),

            SelectableText(
              code.isEmpty ? "Not Generated" : code,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: SelectableText(
                link.isEmpty
                    ? "No invite link generated"
                    : link,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget buildStatisticsCard({
    required int totalInvites,
    required int successfulInvites,
    required int rewardPoints,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,
          children: [

            buildStatItem(
              "Invites",
              totalInvites.toString(),
            ),

            buildStatItem(
              "Joined",
              successfulInvites.toString(),
            ),

            buildStatItem(
              "Rewards",
              rewardPoints.toString(),
            ),

          ],
        ),
      ),
    );
  }

  Widget buildStatItem(
    String title,
    String value,
  ) {
    return Column(
      children: [

        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),

      ],
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