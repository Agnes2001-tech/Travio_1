import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import '../widgets/stardust_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: StardustBackground(
        opacity: 0.1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.send_rounded, color: AppColors.primary, size: 42),
            ),
            const SizedBox(height: 24),
            const Text(
              'Travio',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -1,
              ),
            ),
            const Text(
              'PREMIUM TRAVEL',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.primary,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                children: [
                   ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const SizedBox(
                      height: 2,
                      child: LinearProgressIndicator(
                        backgroundColor: AppColors.obsidianSecondary,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'INITIALIZING EXPERIENCE',
                    style: TextStyle(fontSize: 9, color: AppColors.textGrey, letterSpacing: 1, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
