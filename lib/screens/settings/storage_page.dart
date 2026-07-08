import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/storage_settings.dart';
import '../../repositories/storage_repository.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() =>
      _StoragePageState();
}

class _StoragePageState
    extends State<StoragePage> {
  final StorageRepository repository =
      StorageRepository.instance;

  StorageSettings settings =
      StorageSettings.defaults();

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
              ? "Storage settings saved"
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

  Future<void> clearCache() async {
    final success =
        await repository.clearCache();

    if (!mounted) return;

    if (success) {
      setState(() {
        settings = settings.copyWith(
          cacheSizeMB: 0,
        );
      });
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        backgroundColor:
            success ? Colors.green : Colors.red,
        content: Text(
          success
              ? "Cache cleared successfully"
              : "Failed to clear cache",
        ),
      ),
    );
  }

  Future<void> resetSettings() async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Reset Storage Settings",
          ),
          content: const Text(
            "Restore all storage settings to default values?",
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

    settings =
        await repository.resetSettings();

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Storage settings reset",
        ),
      ),
    );
  }

  void updateSettings(
    StorageSettings newSettings,
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
            "Storage & Data",
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
            "Storage & Data",
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
                  Icons.storage_rounded,
                  size: 70,
                  color: Colors.red,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Couldn't load storage settings",
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
          "Storage & Data",
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

              buildStorageInfoTile(
                "Storage Used",
                "${settings.storageUsedMB.toStringAsFixed(2)} MB",
                Icons.storage,
              ),

              buildStorageInfoTile(
                "Media Size",
                "${settings.mediaSizeMB.toStringAsFixed(2)} MB",
                Icons.photo_library,
              ),

              buildStorageInfoTile(
                "Cache Size",
                "${settings.cacheSizeMB.toStringAsFixed(2)} MB",
                Icons.cached,
              ),

              const SizedBox(height: 18),

              buildSectionTitle(
                "Automatic Downloads",
              ),

              buildSwitchTile(
                "Photos",
                settings.autoDownloadPhotos,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      autoDownloadPhotos:
                          value,
                    ),
                  );
                },
              ),

              buildSwitchTile(
                "Videos",
                settings.autoDownloadVideos,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      autoDownloadVideos:
                          value,
                    ),
                  );
                },
              ),

              buildSwitchTile(
                "Documents",
                settings.autoDownloadDocuments,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      autoDownloadDocuments:
                          value,
                    ),
                  );
                },
              ),

              buildSwitchTile(
                "Audio",
                settings.autoDownloadAudio,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      autoDownloadAudio:
                          value,
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              buildSectionTitle(
                "Network Usage",
              ),

              buildSwitchTile(
                "Use Less Data For Calls",
                settings.useLessDataForCalls,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      useLessDataForCalls:
                          value,
                    ),
                  );
                },
              ),

              buildSwitchTile(
                "Download on Wi-Fi",
                settings.wifiOnlyDownloads,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      wifiOnlyDownloads:
                          value,
                    ),
                  );
                },
              ),

              buildSwitchTile(
                "Download on Mobile Data",
                settings.mobileDataDownloads,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      mobileDataDownloads:
                          value,
                    ),
                  );
                },
              ),

              buildSwitchTile(
                "Download While Roaming",
                settings.roamingDownloads,
                (value) {
                  updateSettings(
                    settings.copyWith(
                      roamingDownloads:
                          value,
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              buildActionTile(
                title: "Clear Cache",
                icon: Icons.cleaning_services,
                onTap: clearCache,
              ),

              const SizedBox(height: 14),

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: resetSettings,
                    icon: const Icon(
                      Icons.restart_alt,
                    ),
                    label: const Text(
                      "Reset Storage Settings",
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

  Widget buildStorageInfoTile(
    String title,
    String value,
    IconData icon,
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
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
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
            "Reset Storage Settings",
          ),
          content: const Text(
            "Are you sure you want to restore all storage and data settings to their default values?",
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