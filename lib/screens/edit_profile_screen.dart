import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../features/profile/services/user_profile_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  final departmentController = TextEditingController();
  final levelController = TextEditingController();

  Uint8List? imageBytes;

  bool loading = true;
  bool saving = false;

  List<String> interests = [];
  String searchInterest = '';

  final Map<String, List<String>> availableInterests = {
    'Entertainment': [
      'Movies',
      'TV Shows',
      'Anime',
      'Music',
      'Netflix / Streaming',
      'Comedy',
      'Celebrity News',
    ],
    'Gaming': [
      'Mobile Games',
      'Console Gaming',
      'PC Gaming',
      'Esports',
      'Game Development',
    ],
    'Tech & Internet': [
      'Artificial Intelligence',
      'Programming / Coding',
      'Gadgets',
      'Social Media',
      'Startups',
      'Cybersecurity',
    ],
    'Creativity': [
      'Photography',
      'Graphic Design',
      'Drawing / Art',
      'Fashion Design',
      'Writing / Blogging',
      'Video Editing',
    ],
    'Sports & Fitness': [
      'Football',
      'Basketball',
      'Gym / Fitness',
      'Running',
      'Martial Arts',
      'Yoga',
    ],
    'Lifestyle': [
      'Travel',
      'Food & Cooking',
      'Fashion',
      'Relationships',
      'Self Improvement',
      'Motivation',
    ],
    'Education & Career': [
      'Business',
      'Entrepreneurship',
      'Finance / Investing',
      'Science',
      'Engineering',
      'Medicine',
    ],
    'Hobbies': [
      'Reading',
      'Gardening',
      'Music Production',
      'Dancing',
      'Cars & Bikes',
      'Nature / Wildlife',
    ],
    'Other': [
      'Memes',
      'News & Politics',
      'Spirituality',
      'Psychology',
      'DIY / Crafts',
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
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

  Future<void> _loadProfile() async {
    try {
      final profile =
          await UserProfileService.getCurrentProfile();

      final rawInterests =
          profile.interests ?? '';

      setState(() {
        nameController.text = profile.fullName;
        usernameController.text = profile.username;
        bioController.text = profile.bio ?? '';
        departmentController.text =
            profile.department ?? '';
        levelController.text = profile.level ?? '';

        interests = rawInterests
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    if (!mounted) return;

    setState(() {
      imageBytes = bytes;
    });
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (interests.contains(interest)) {
        interests.remove(interest);
      } else {
        interests.add(interest);
      }
    });
  }

  Future<void> _saveProfile() async {
    if (saving) return;

    if (nameController.text.trim().isEmpty) {
      _showError('Full name is required.');
      return;
    }

    if (usernameController.text.trim().isEmpty) {
      _showError('Username is required.');
      return;
    }

    setState(() => saving = true);

    try {
      await UserProfileService.updateProfile(
        fullName: nameController.text,
        username: usernameController.text,
        bio: bioController.text,
        department: departmentController.text,
        level: levelController.text,
        interests: interests,
      );

      if (imageBytes != null) {
        await UserProfileService.uploadProfilePicture(
          imageBytes: imageBytes!,
          fileName: 'profile.jpg',
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showError(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 62,
                        backgroundColor:
                            Colors.grey.shade300,
                        backgroundImage:
                            imageBytes != null
                                ? MemoryImage(imageBytes!)
                                : null,
                        child: imageBytes == null
                            ? const Icon(
                                Icons.person,
                                size: 55,
                              )
                            : null,
                      ),
                      Container(
                        padding:
                            const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context)
                                  .colorScheme
                                  .primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              TextField(
                controller: nameController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: usernameController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText: 'Username',
                  prefixText: '@',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: bioController,
                maxLines: 4,
                maxLength: 160,
                decoration:
                    const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 4),

              TextField(
                controller: departmentController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: levelController,
                textInputAction:
                    TextInputAction.done,
                decoration:
                    const InputDecoration(
                  labelText: 'Level',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Interests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                decoration:
                    const InputDecoration(
                  hintText: 'Search interests...',
                  prefixIcon:
                      Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchInterest =
                        value.toLowerCase().trim();
                  });
                },
              ),

              if (interests.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      interests.map((interest) {
                    return Chip(
                      label: Text(interest),
                      deleteIcon:
                          const Icon(Icons.close),
                      onDeleted: () =>
                          _toggleInterest(
                            interest,
                          ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 20),

              ...availableInterests.entries.map(
                (entry) {
                  final filtered =
                      entry.value.where(
                    (interest) =>
                        interest
                            .toLowerCase()
                            .contains(
                              searchInterest,
                            ),
                  ).toList();

                  if (filtered.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            filtered.map(
                          (interest) {
                            return FilterChip(
                              label:
                                  Text(interest),
                              selected:
                                  interests.contains(
                                interest,
                              ),
                              onSelected: (_) =>
                                  _toggleInterest(
                                interest,
                              ),
                            );
                          },
                        ).toList(),
                      ),
                      const SizedBox(height: 18),
                    ],
                  );
                },
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      saving ? null : _saveProfile,
                  child: saving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}