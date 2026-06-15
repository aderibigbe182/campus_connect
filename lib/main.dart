import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

import 'routes/app_routes.dart';

import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

import 'core/services/local_storage_service.dart';
import 'core/services/presence_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // =========================
  // FIREBASE INIT
  // =========================

  await Firebase.initializeApp(

    options:
        DefaultFirebaseOptions
            .currentPlatform,
  );

  // =========================
  // LOCK PORTRAIT MODE
  // =========================

  await SystemChrome.setPreferredOrientations([

    DeviceOrientation.portraitUp,
  ]);

  runApp(const CampusConnectApp());
}

class CampusConnectApp
    extends StatelessWidget {

  const CampusConnectApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'Campus Connect',

      debugShowCheckedModeBanner:
          false,

      theme: ThemeData(

        primarySwatch: Colors.blue,

        scaffoldBackgroundColor:
            Colors.white,

        appBarTheme: const AppBarTheme(

          backgroundColor:
              Colors.white,

          elevation: 0,

          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
      ),

      // =========================
      // START SCREEN
      // =========================

      home: const StartScreen(),

      // =========================
      // ROUTES
      // =========================

      routes: AppRoutes.routes,
    );
  }
}

// ===================================
// START SCREEN
// ===================================

class StartScreen
    extends StatefulWidget {

  const StartScreen({
    super.key,
  });

  @override
  State<StartScreen> createState() =>
      _StartScreenState();
}

class _StartScreenState
    extends State<StartScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {

    super.initState();

    // APP LIFECYCLE LISTENER
    WidgetsBinding.instance
        .addObserver(this);

    // USER ONLINE
    _setUserOnline();
  }

  @override
  void dispose() {

    WidgetsBinding.instance
        .removeObserver(this);

    super.dispose();
  }

  // ===================================
  // APP STATE
  // ===================================

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state) {

    if (FirebaseAuth.instance
            .currentUser ==
        null) return;

    // ONLINE
    if (state ==
        AppLifecycleState.resumed) {

      PresenceService.setOnline();
    }

    // OFFLINE
    if (state ==
            AppLifecycleState.paused ||
        state ==
            AppLifecycleState.detached) {

      PresenceService.setOffline();
    }
  }

  // ===================================
  // SET USER ONLINE
  // ===================================

  Future<void> _setUserOnline() async {

    if (FirebaseAuth.instance
            .currentUser !=
        null) {

      await PresenceService
          .setOnline();
    }
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<bool>(

      future:
          LocalStorageService
              .hasSeenOnboarding(),

      builder: (context, snapshot) {

        // =========================
        // LOADING
        // =========================

        if (!snapshot.hasData) {

          return const Scaffold(

            body: Center(

              child:
                  CircularProgressIndicator(),
            ),
          );
        }

        // =========================
        // FIRST APP OPEN
        // =========================

        final hasSeenOnboarding =
            snapshot.data ?? false;

        if (!hasSeenOnboarding) {

          return const OnboardingScreen();
        }

        // =========================
        // USER LOGGED IN
        // =========================

        final user =
            FirebaseAuth
                .instance
                .currentUser;

        if (user != null) {

          return const HomeScreen();
        }

        // =========================
        // NOT LOGGED IN
        // =========================

        return const LoginScreen();
      },
    );
  }
}