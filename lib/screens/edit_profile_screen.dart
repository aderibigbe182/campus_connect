import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/services/storage_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState
    extends State<EditProfilePage> {

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController bioController =
      TextEditingController();

  final TextEditingController departmentController =
      TextEditingController();

  final TextEditingController levelController =
      TextEditingController();

  Uint8List? imageBytes;

  bool loading = false;

  static const baseUrl =
      "https://campus-connect-backend-6pwg.onrender.com";
Future<void> loadCurrentProfile() async {

  final token =
      await StorageService.getToken();

  if (token == null) return;

  try {

    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/users/profile",
      ),
      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

    if (response.statusCode == 200) {

      final data =
          jsonDecode(response.body);

      setState(() {

        nameController.text =
            data["full_name"] ?? "";

        usernameController.text =
            data["username"] ?? "";

        bioController.text =
            data["bio"] ?? "";

        departmentController.text =
            data["department"] ?? "";

        levelController.text =
            data["level"] ?? "";
      });
    }

  } catch (e) {

    print(
      "LOAD PROFILE ERROR = $e",
    );
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

  // =========================
  // PICK IMAGE
  // =========================

  Future<void> pickImage() async {

    final picker = ImagePicker();

    final picked =
        await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null) return;

    final bytes =
        await picked.readAsBytes();

    setState(() {
      imageBytes = bytes;
    });
  }

  // =========================
  // SAVE PROFILE
  // =========================

  Future<void> saveProfile() async {

    setState(() {
      loading = true;
    });

    try {

      final token =
          await StorageService.getToken();

      final response = await http.put(
        Uri.parse(
          "$baseUrl/api/users/profile",
        ),
        headers: {
          "Content-Type":
              "application/json",
          "Authorization":
              "Bearer $token",
        },
        body: jsonEncode({
          "full_name":
              nameController.text.trim(),
          "username":
              usernameController.text.trim(),
          "bio":
              bioController.text.trim(),
          "department":
              departmentController.text.trim(),
          "level":
              levelController.text.trim(),
        }),
      );

      print(
        "UPDATE STATUS = ${response.statusCode}",
      );

      print(
        "UPDATE BODY = ${response.body}",
      );

      if (response.statusCode == 200) {

        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Profile updated successfully",
            ),
          ),
        );

        Navigator.pop(
          context,
          true,
        );

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              response.body,
            ),
          ),
        );
      }

    } catch (e) {

      print("UPDATE ERROR = $e");

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }

    setState(() {
      loading = false;
    });
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Edit Profile",
        ),
        backgroundColor: Colors.blue,
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(height: 20),

            GestureDetector(

              onTap: pickImage,

              child: CircleAvatar(

                radius: 60,

                backgroundColor:
                    Colors.grey.shade300,

                backgroundImage:
                    imageBytes != null
                        ? MemoryImage(
                            imageBytes!,
                          )
                        : null,

                child: imageBytes == null
                    ? const Icon(
                        Icons.camera_alt,
                        size: 35,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller:
                  nameController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Full Name",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  usernameController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Username",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  bioController,
              maxLines: 3,
              decoration:
                  const InputDecoration(
                labelText: "Bio",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  departmentController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Department",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  levelController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Level",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    loading
                        ? null
                        : saveProfile,
                child: loading
                    ? const CircularProgressIndicator(
                        color:
                            Colors.white,
                      )
                    : const Text(
                        "Save Changes",
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}