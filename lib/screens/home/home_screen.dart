import 'package:flutter/material.dart';

import '../../core/services/presence_service.dart';

import '/screens/main/pages/profile_page.dart';
import '/features/chat/screens/chat_home_screen.dart';

class HomeScreen extends StatefulWidget {
  final int currentUserId;

  const HomeScreen({
    super.key,
    required this.currentUserId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  // ============================================================
  // CURRENT TAB
  // ============================================================

  int currentIndex = 3;

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _setUserOnline();
  }

  // ============================================================
  // APP LIFECYCLE
  // ============================================================

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _setUserOnline();
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _setUserOffline();
        break;
    }
  }

  // ============================================================
  // PRESENCE
  // ============================================================

  Future<void> _setUserOnline() async {
    try {
      await PresenceService.setOnline();

      debugPrint('[HomeScreen] User online.');
    } catch (e) {
      debugPrint('[HomeScreen] Online error: $e');
    }
  }

  Future<void> _setUserOffline() async {
    try {
      await PresenceService.setOffline();

      debugPrint('[HomeScreen] User offline.');
    } catch (e) {
      debugPrint('[HomeScreen] Offline error: $e');
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _openSearch() {
    Navigator.pushNamed(
      context,
      '/search',
    );
  }

  // ============================================================
  // PAGE TITLE
  // ============================================================

  String get _pageTitle {
    switch (currentIndex) {
      case 0:
        return 'Stories';

      case 1:
        return 'Calls';

      case 2:
        return 'Groups';

      case 3:
        return 'Campus Connect';

      case 4:
        return 'Me';

      default:
        return 'Campus Connect';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,

        title: Text(
          _pageTitle,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: _openSearch,
            icon: const Icon(
              Icons.search,
              color: Colors.black,
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: IndexedStack(
        index: currentIndex,
        children: [
          const ComingSoonPage(
            icon: Icons.history,
            title: 'Stories',
            subtitle: 'Stories screen will be built later.',
          ),

          const ComingSoonPage(
            icon: Icons.call,
            title: 'Calls',
            subtitle: 'Calls screen will be built later.',
          ),

          const ComingSoonPage(
            icon: Icons.groups,
            title: 'Groups',
            subtitle: 'Groups screen will be built later.',
          ),

          // ====================================================
          // CHAT LIST
          // ====================================================

          ChatListScreen(
            currentUserId: widget.currentUserId,
          ),

          // ====================================================
          // PROFILE
          // ====================================================

          const ProfilePage(),
        ],
      ),

      // ========================================================
      // FLOATING ACTION BUTTON
      // ========================================================

      floatingActionButton: currentIndex == 3
          ? FloatingActionButton(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              onPressed: _openSearch,
              child: const Icon(
                Icons.add,
              ),
            )
          : null,

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          if (index == currentIndex) {
            return;
          }

          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Stories',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Calls',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Groups',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _setUserOffline();

    super.dispose();
  }
}

// ==================================================================
// COMING SOON PAGE
// ==================================================================

class ComingSoonPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ComingSoonPage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}