import 'package:flutter/material.dart';
import 'package:movies_app/login_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_content.dart';
import 'onboarding_data.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _controller;
  int currentPage = 0;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (currentPage == pagesData.length - 1) {
      _completeOnboarding();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarding_completed", true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, LoginScaner.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (index) {
          setState(() => currentPage = index);
        },
        itemCount: pagesData.length,
        itemBuilder: (context, index) {
          return OnboardingContent(
            image: pagesData[index]["image"]!,
            title: pagesData[index]["title"]!,
            desc: pagesData[index]["desc"] ?? "",
            isFirst: index == 0,
            isLast: index == pagesData.length - 1,
            onNext: _nextPage,
            onBack: _previousPage,
          );
        },
      ),
    );
  }
}