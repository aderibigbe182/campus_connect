import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/services/storage_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController levelController = TextEditingController();

  Uint8List? imageBytes;
  bool loading = false;

  List<String> interests = [];
  String searchInterest = "";

  static const baseUrl =
      "https://campus-connect-backend-6pwg.onrender.com";

  final Map<String, List<String>> availableInterests = {
    "Entertainment": ["Movies", "TV Shows", "Anime", "Music", "Netflix / Streaming", "Comedy", "Celebrity News"],
    "Gaming": ["Mobile Games", "Console Gaming", "PC Gaming", "Esports", "Game Development"],
    "Tech & Internet": ["Artificial Intelligence", "Programming / Coding", "Gadgets", "Social Media", "Startups", "Cybersecurity"],
    "Creativity": ["Photography", "Graphic Design", "Drawing / Art", "Fashion Design", "Writing / Blogging", "Video Editing"],
    "Sports & Fitness": ["Football", "Basketball", "Gym / Fitness", "Running", "Martial Arts", "Yoga"],
    "Lifestyle": ["Travel", "Food & Cooking", "Fashion", "Relationships", "Self Improvement", "Motivation"],
    "Education & Career": ["Business", "Entrepreneurship", "Finance / Investing", "Science", "Engineering", "Medicine"],
    "Hobbies": ["Reading", "Gardening", "Music Production", "Dancing", "Cars & Bikes", "Nature / Wildlife"],
    "Other": ["Memes", "News & Politics", "Spirituality", "Psychology", "DIY / Crafts"],
  };

  Future<void> loadCurrentProfile() async {
    final token = await StorageService.getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/users/profile"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          nameController.text = data["full_name"] ?? "";
          usernameController.text = data["username"] ?? "";
          bioController.text = data["bio"] ?? "";
          departmentController.text = data["department"] ?? "";
          levelController.text = data["level"] ?? "";

          final raw = data["interests"];

          if (raw is List) {
            interests = List<String>.from(raw);
          } else if (raw is String && raw.isNotEmpty) {
            interests = raw.split(",").map((e) => e.trim()).toList();
          } else {
            interests = [];
          }
        });
      }
    } catch (e) {
      debugPrint("LOAD PROFILE ERROR = $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadCurrentProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    departmentController.dispose();
    levelController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    if (!mounted) return;

    setState(() {
      imageBytes = bytes;
    });
  }

  void toggleInterest(String interest) {
    setState(() {
      if (interests.contains(interest)) {
        interests.remove(interest);
      } else {
        interests.add(interest);
      }
      interests.sort();
    });
  }

  Future<void> saveProfile() async {
    setState(() => loading = true);

    try {
      final token = await StorageService.getToken();
      if (token == null) throw Exception("Not authenticated");

      final response = await http.put(
        Uri.parse("$baseUrl/api/users/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "full_name": nameController.text.trim(),
          "username": usernameController.text.trim(),
          "bio": bioController.text.trim(),
          "department": departmentController.text.trim(),
          "level": levelController.text.trim(),
          "interests": interests.join(","),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      if (imageBytes != null) {
        final request = http.MultipartRequest(
          "POST",
          Uri.parse("$baseUrl/api/users/profile_picture"),
        );

        request.headers["Authorization"] = "Bearer $token";
        request.files.add(
          http.MultipartFile.fromBytes(
            "image",
            imageBytes!,
            filename: "profile.jpg",
          ),
        );

        final res = await request.send();

        final body =
            await res.stream.bytesToString();
        print("UPLOAD STATUS = ${res.statusCode}");
        print("UPLOAD BODY = $body");

        if (res.statusCode != 200) {
          throw Exception("Image upload failed: $body");
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    imageBytes != null ? MemoryImage(imageBytes!) : null,
                child: imageBytes == null
                    ? const Icon(Icons.camera_alt, size: 35)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder())),
            const SizedBox(height: 10),

            TextField(controller: usernameController, decoration: const InputDecoration(labelText: "Username", border: OutlineInputBorder())),
            const SizedBox(height: 10),

            TextField(controller: bioController, maxLines: 3, decoration: const InputDecoration(labelText: "Bio", border: OutlineInputBorder())),
            const SizedBox(height: 10),

            TextField(controller: departmentController, decoration: const InputDecoration(labelText: "Department", border: OutlineInputBorder())),
            const SizedBox(height: 10),

            TextField(controller: levelController, decoration: const InputDecoration(labelText: "Level", border: OutlineInputBorder())),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Interests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 10),

            TextField(
              decoration: const InputDecoration(
                hintText: "Search interests...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchInterest = value.toLowerCase();
                });
              },
            ),

            const SizedBox(height: 15),

            if (interests.isNotEmpty)
              Wrap(
                spacing: 8,
                children: interests.map((e) {
                  return Chip(
                    label: Text(e),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => toggleInterest(e),
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),

            ...availableInterests.entries.map((category) {
              final filtered = category.value.where(
                (i) => i.toLowerCase().contains(searchInterest),
              );

              if (filtered.isEmpty) return const SizedBox();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.key,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    children: filtered.map((i) {
                      return FilterChip(
                        label: Text(i),
                        selected: interests.contains(i),
                        onSelected: (_) => toggleInterest(i),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                ],
              );
            }),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : saveProfile,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}