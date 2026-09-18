import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_scanner.dart';
import 'onboarding/onboarding_screen.dart';
import 'screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool onboardingCompleted =
        prefs.getBool("onboarding_completed") ?? false;

    if (!mounted || !context.mounted) return;

    // ⚠️ مؤقت للتجربة: بنروح على طول للصفحة الرئيسية من غير تسجيل دخول
    // TODO: ارجع للكود الأصلي بعد ما تخلص من التجربة
    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/images/splash_logo.png',
                width: 180,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/movie_logo.png',
                  width: 140,
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/branding.png',
                  height: 40,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
