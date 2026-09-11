import 'package:flutter/material.dart';

import '../../../core/services/storage_service.dart';
import '../../../features/profile/models/user_profile_model.dart';
import '../../../features/profile/services/user_profile_service.dart';
import '../../../screens/auth/login_screen.dart';
import '../../../screens/edit_profile_screen.dart';
import '../../../widgets/avatar_widget.dart';
import '../../settings/help_feedback_page.dart';
import '../../settings/invite_friend_page.dart';
import '../../settings/notifications_page.dart';
import '../../settings/privacy_page.dart';
import '../../settings/storage_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfileModel? profile;

  bool loading = true;
  bool loggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final result =
          await UserProfileService.getCurrentProfile();

      if (!mounted) return;

      setState(() {
        profile = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    }
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfilePage(),
      ),
    );

    if (result == true) {
      await _loadProfile();
    }
  }

  Future<void> _logout() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Logout'),
              content: const Text(
                'Are you sure you want to logout?',
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                    context,
                    false,
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(
                    context,
                    true,
                  ),
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    setState(() => loggingOut = true);

    try {
      try {
        await UserProfileService.setOffline();
      } catch (_) {}

      await StorageService.deleteToken();
      await StorageService.deleteUserId();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (_) => false,
      );
    } finally {
      if (mounted) {
        setState(() => loggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (profile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load profile.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() => loading = true);
                  _loadProfile();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final user = profile!;

    return Scaffold(
      backgroundColor:
          Theme.of(context)
              .colorScheme
              .surface,
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  32,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.search,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.qr_code,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 8,
                      ),
                      decoration:
                          BoxDecoration(
                        color: user.isOnline
                            ? Colors.green
                            : Colors.grey,
                        borderRadius:
                            BorderRadius.circular(
                          24,
                        ),
                      ),
                      child: Text(
                        user.isOnline
                            ? 'Available'
                            : 'Offline',
                        style:
                            const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    AvatarWidget(
                      radius: 58,
                      imageUrl:
                          user.profilePicture,
                      fullName: user.fullName,
                      isOnline: user.isOnline,
                    ),

                    const SizedBox(height: 14),

                    Text(
                      user.fullName,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '@${user.username}',
                      style:
                          const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _profileCard(
                      'Name',
                      user.fullName,
                    ),

                    _profileCard(
                      'Email',
                      user.email,
                    ),

                    _profileCard(
                      'School',
                      user.university ??
                          'Not Set',
                    ),

                    _profileCard(
                      'Department',
                      user.department ??
                          'Not Set',
                    ),

                    _profileCard(
                      'Level',
                      user.level ??
                          'Not Set',
                    ),

                    _profileCard(
                      'Interests',
                      user.interests ??
                          'Not Set',
                    ),

                    _profileCard(
                      'Bio',
                      user.bio ??
                          'Not Set',
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child:
                          ElevatedButton.icon(
                        onPressed:
                            _editProfile,
                        icon: const Icon(
                          Icons.edit,
                        ),
                        label: const Text(
                          'Edit Profile',
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    _settingTile(
                      Icons.lock_outline,
                      'Privacy',
                      const PrivacyPage(),
                    ),

                    _settingTile(
                      Icons.notifications_outlined,
                      'Notifications',
                      const NotificationsPage(),
                    ),

                    _settingTile(
                      Icons.storage_outlined,
                      'Storage & Data',
                      const StoragePage(),
                    ),

                    _settingTile(
                      Icons.help_outline,
                      'Help & Feedback',
                      const HelpFeedbackPage(),
                    ),

                    _settingTile(
                      Icons.person_add_outlined,
                      'Invite a Friend',
                      const InviteFriendPage(),
                    ),

                    const SizedBox(height: 20),

                    Align(
                      alignment:
                          Alignment.centerLeft,
                      child:
                          TextButton.icon(
                        onPressed:
                            loggingOut
                                ? null
                                : _logout,
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Logout',
                          style:
                              TextStyle(
                            color: Colors.red,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (loggingOut)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding:
                        EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Logging out...'),
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

  Widget _profileCard(
    String title,
    String value,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: ListTile(
        title: Text(
          title,
          style:
              const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          value,
          maxLines: 4,
          overflow:
              TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _settingTile(
    IconData icon,
    String title,
    Widget page,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
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