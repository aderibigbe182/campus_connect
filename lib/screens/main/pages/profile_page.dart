import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/services/storage_service.dart';
import '../../../screens/edit_profile_screen.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  static const baseUrl =
      'https://campus-connect-backend-6pwg.onrender.com';

  @override
  void initState() {
    super.initState();
    loadUser();
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

  // ✅ NEW NAVIGATION WITH REFRESH
  void openEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfilePage(),
      ),
    ).then((value) {
      if (value == true) {
        loadUser(); // refresh profile after edit
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userData == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // SEARCH + QR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.search, size: 30),
                    Icon(Icons.qr_code, size: 30),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                    )
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
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.deepPurple,
                backgroundImage: userData!['profile_picture'] != null
                    ? NetworkImage(userData!['profile_picture'])
                    : null,
                child: userData!['profile_picture'] == null
                    ? const Icon(
                        Icons.person,
                        size: 55,
                        color: Colors.white,
                      )
                    : null,
              ),

              const SizedBox(height: 15),

              Chip(
                label: Text(
                  userData!['is_online'] == true
                      ? 'Available'
                      : 'Offline',
                ),
              ),

              const SizedBox(height: 20),

              // PROFILE CARDS
              _profileCard("Name", userData!['full_name'] ?? ''),
              _profileCard("Email", userData!['email'] ?? ''),
              _profileCard("School", userData!['university'] ?? ''),
              _profileCard(
                  "Department", userData!['department'] ?? 'Not Set'),
              _profileCard("Level", userData!['level'] ?? 'Not Set'),
              _profileCard("Interests", userData!['interests'] ?? 'Not Set'),

              const SizedBox(height: 30),

              // SETTINGS
              _settingTile(Icons.lock, "Privacy"),
              _settingTile(Icons.notifications, "Notifications"),
              _settingTile(Icons.storage, "Storage & Data"),

              const SizedBox(height: 20),

              _settingTile(Icons.help_outline, "Help & Feedback"),
              _settingTile(Icons.group_add, "Invite a Friend"),

              const SizedBox(height: 20),

              // EDIT PROFILE BUTTON (UPDATED)
              ElevatedButton.icon(
                onPressed: openEditProfile,
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // PROFILE CARD
  // =========================
  Widget _profileCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        title: Text(
          "$title:",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value),
      ),
    );
  }

  // =========================
  // SETTINGS TILE
  // =========================
  Widget _settingTile(IconData icon, String title) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {},
      ),
    );
  }
}