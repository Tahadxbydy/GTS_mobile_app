import 'package:flutter/material.dart';
import 'package:gts/providers/home_provider.dart';
import 'package:gts/views/screens/home_screen.dart';
import '../../core/constants/assets.dart';
import 'download_screen.dart';
import '../widgets/custom_animated_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  static const routeName = '/onboarding';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.girigo),
            fit: BoxFit.cover,
          ),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(height: 40),
            CustomAnimatedButton(
              text: 'Make a wish',
              textColor: Colors.black,
              gradientColors: [
                // Theme.of(context).primaryColor,
                Colors.black,
                Colors.white,
                // Theme.of(context).primaryColor,
              ],
              onTap: () {
                Navigator.pushReplacementNamed(context, HomeScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
