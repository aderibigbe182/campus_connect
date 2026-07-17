import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/services/storage_service.dart';
import '../../../screens/edit_profile_screen.dart';
import '../../settings/privacy_page.dart';
import '../../settings/notifications_page.dart';
import '../../settings/storage_page.dart';
import '../../settings/invite_friend_page.dart';
import '../../settings/help_feedback_page.dart';
import '../../../screens/auth/login_screen.dart';
import '/widgets/avatar_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isLoggingOut = false;

  static const baseUrl =
      'https://campus-connect-backend-6pwg.onrender.com';

  Future<bool> performLogout() async {
    try {
      await StorageService.deleteToken();
      return true;
    } catch (e) {
      print("Logout failed: $e");
      return false;
    }
  }

  Future<void> checkSession() async {
    final token = await StorageService.getToken();

    if (token == null) {
      return;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/check-session'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final valid = response.statusCode == 200;
  if (!mounted) return;

  if (!valid) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Your session has expired. Please login again.",
        ),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }
}

Future<bool> showLogoutDialog() async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20),
        ),

        title: const Row(
          children: [

            Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),

            SizedBox(width: 10),

            Text("Logout"),

          ],
        ),

        content: const Text(
          "Are you sure you want to logout of your Campus Connect account?\n\nYou'll need to login again to continue using the app.",
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

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
            },
          ),

        ],
      );
    },
  );

  return result ?? false;
}
  Future<void> logout() async {
  final confirm = await showLogoutDialog();

  if (!confirm) return;

  setState(() {
    isLoggingOut = true;
  });

  if (!mounted) return;

  final success = await performLogout();

  setState(() {
    isLoggingOut = false;
  });

  if (success) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Logout failed. Please try again.",
        ),
      ),
    );
  }
}

  @override
void initState() {
  super.initState();
  loadUser();
  // TEMPORARILY DISABLED
  // We currently validate the session using
  // /api/auth/me instead of /check-session.
  //
  // checkSession();
}
  Future<void> loadUser() async {
    final token = await StorageService.getToken();

    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("FULL USER DATA = ${jsonEncode(data)}");
        print("PROFILE PICTURE URL = ${data['profile_picture']}");
        print("FULL RESPONSE = $data");

        if (!mounted) return;

        setState(() {
          userData = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  void openEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfilePage(),
      ),
    ).then((value) {
      if (value == true) {
        loadUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (userData == null) {
      return const Scaffold(
        body: Center(
          child: Text("User not logged in"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: loadUser,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // SEARCH + QR
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: const [
                          Icon(
                            Icons.search,
                            size: 30,
                          ),
                          Icon(
                            Icons.qr_code,
                            size: 30,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // STATUS
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        userData!['is_online'] == true
                            ? "Available"
                            : "Offline",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // PROFILE IMAGE
                    // PROFILE IMAGE
                    AvatarWidget(
                      radius: 55,
                      imageUrl: userData!['profile_picture'],
                      fullName: userData!['full_name'],
                      isOnline: userData!['is_online'] == true,
                    ),

                    const SizedBox(height: 20),

                    // PROFILE CARDS
                    _profileCard(
                      "Name",
                      userData!['full_name'] ?? '',
                    ),

                    _profileCard(
                      "Email",
                      userData!['email'] ?? '',
                    ),

                    _profileCard(
                      "School",
                      userData!['university'] ?? '',
                    ),

                    _profileCard(
                      "Department",
                      userData!['department'] ?? 'Not Set',
                    ),

                    _profileCard(
                      "Level",
                      userData!['level'] ?? 'Not Set',
                    ),

                    _profileCard(
                      "Interests",
                      userData!['interests'] ?? 'Not Set',
                    ),

                    _profileCard(
                      "Bio",
                      userData!['bio'] ?? 'Not Set',
                    ),

                    const SizedBox(height: 30),

                    // SETTINGS
                    _settingTile(
                      Icons.lock,
                      "Privacy",
                      const PrivacyPage(),
                    ),

                    _settingTile(
                      Icons.notifications,
                      "Notifications",
                      const NotificationsPage(),
                    ),

                    _settingTile(
                      Icons.storage,
                      "Storage & Data",
                      const StoragePage(),
                    ),

                    _settingTile(
                      Icons.help_outline,
                      "Help & Feedback",
                      const HelpFeedbackPage(),
                    ),

                    _settingTile(
                      Icons.person_add,
                      "Invite a Friend",
                      const InviteFriendPage(),
                    ),

                    const SizedBox(height: 20),

                    // EDIT PROFILE BUTTON
                    ElevatedButton.icon(
                      onPressed: openEditProfile,
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        "Edit Profile",
                      ),
                    ),

                    const SizedBox(height: 30),

                    // LOGOUT BUTTON
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 30,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: logout,
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.red,
                          ),
                          label: const Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (isLoggingOut)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),

                        SizedBox(height: 18),

                        Text(
                          "Logging out...",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =========================
  // PROFILE CARD
  // =========================
  Widget _profileCard(
    String title,
    String value,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 12,
      ),
      child: ListTile(
        title: Text(
          "$title:",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(value),
      ),
    );
  }

  // =========================
  // SETTINGS TILE
  // =========================
  Widget _settingTile(
    IconData icon,
    String title,
    Widget page,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blue,
        ),
       title: Text(
  title,
  style: const TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  ),
),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.blue,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        },
      ),
    );
  }
}