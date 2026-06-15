import 'package:flutter/material.dart';
import '../../widgets/onboarding_page.dart';
import '../../widgets/custom_button.dart';
import '../../core/services/local_storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {

  final controller = PageController();

  int index = 0;

  final pages = const [

    OnboardingPage(
      title: "Connect",
      desc: "Meet students",
      image: "assets/images/onboarding1.jpeg",
    ),

    OnboardingPage(
      title: "Learn",
      desc: "Access campus updates",
      image: "assets/images/onboarding2.jpeg",
    ),

    OnboardingPage(
      title: "Grow",
      desc: "Build your network",
      image: "assets/images/onboarding3.jpeg",
    ),
  ];

  // 🔥 UPDATED FUNCTION
  void next() async {

    // LAST PAGE
    if (index == pages.length - 1) {

      // SAVE THAT USER HAS SEEN ONBOARDING
      await LocalStorageService.setOnboardingSeen();

      // GO TO LOGIN
      Navigator.pushReplacementNamed(
        context,
        '/login',
      );

    } else {

      // GO TO NEXT PAGE
      controller.nextPage(
        duration: const Duration(
          milliseconds: 300,
        ),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Column(

        children: [

          Expanded(

            child: PageView(

              controller: controller,

              onPageChanged: (i) {

                setState(() {
                  index = i;
                });
              },

              children: pages,
            ),
          ),

          Padding(

            padding: const EdgeInsets.all(20),

            child: CustomButton(

              text: index == 2
                  ? "Get Started"
                  : "Next",

              onPressed: next,
            ),
          ),
        ],
      ),
    );
  }
}