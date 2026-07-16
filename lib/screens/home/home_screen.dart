import 'package:flutter/material.dart';

import '../../core/services/presence_service.dart';

import '/screens/main/pages/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {

  int currentIndex = 3;

  late final List<Widget> pages = [
  const ComingSoonPage(
    icon: Icons.history,
    title: "Stories",
    subtitle: "Stories screen will be built later.",
  ),

  const ComingSoonPage(
    icon: Icons.call,
    title: "Calls",
    subtitle: "Calls screen will be built later.",
  ),

  const ComingSoonPage(
    icon: Icons.groups,
    title: "Groups",
    subtitle: "Groups screen will be built later.",
  ),

  const ComingSoonPage(
    icon: Icons.chat,
    title: "Chats",
    subtitle: "Chats screen will be built later.",
  ),

  const ProfilePage(),
];



  // =========================
  // INIT STATE
  // =========================
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    Future.delayed(const Duration(milliseconds: 500),(){
      _setUserOnline();
    });
  

    // mark user online when app opens Home
    _setUserOnline();
  }

  // =========================
  // DISPOSE
  // =========================
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // mark user offline when leaving Home
    _setUserOffline();

    super.dispose();
  }

  // =========================
  // APP LIFECYCLE HANDLER
  // =========================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _setUserOnline();
    }

    if (state == AppLifecycleState.paused) {
      _setUserOffline();
    }
  }

  // =========================
  // PRESENCE FUNCTIONS
  // =========================
  Future<void> _setUserOnline() async {
    try {
      await PresenceService.setOnline();
      print("user online success");
    } catch (e) {
      print("Online error: $e");
    }
  }

  Future<void> _setUserOffline() async {
    try {
      await PresenceService.setOffline();
    } catch (e) {
      print("Offline error: $e");
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // =========================
      // FLOATING BUTTON
      // =========================
      floatingActionButton: currentIndex == 3
          ? FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () {
                Navigator.pushNamed(context, '/search');
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

      // =========================
      // APP BAR
      // =========================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          currentIndex == 0
              ? "Stories"
              : currentIndex == 1
                  ? "Calls"
                  : currentIndex == 2
                      ? "Groups"
                      : currentIndex == 3
                          ? "Campus Connect"
                          : "Me",
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
            icon: const Icon(Icons.search, color: Colors.black),
          ),
        ],
      ),

      // =========================
      // BODY
      // =========================
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      // =========================
      // BOTTOM NAV
      // =========================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Stories",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: "Calls",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: "Groups",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Me",
          ),
        ],
      ),
    );
  }
}
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