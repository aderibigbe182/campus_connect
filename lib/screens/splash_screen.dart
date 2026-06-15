import 'dart:async';
import 'package:flutter/material.dart';
import 'package:campus_connect/widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  late Animation<double> fade;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    );

    fade = Tween(begin: 0.0, end: 1.0).animate(controller);
    scale = Tween(begin: 0.7, end: 1.0).animate(controller);
    
    controller.forward();

    Future.delayed(const Duration(seconds: 10), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLogo(),
            const SizedBox(height: 20),
            const Text(
              "Campus Connect",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Connecting Students Everywhere",
              style: TextStyle(
                fontSize: 15              
              ),
            )
          ],
        ),
      ),
    );
  }
  }