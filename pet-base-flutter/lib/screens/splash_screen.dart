import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_ui.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FBF7),
      body: SafeArea(
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const PetLogo(size: 78, showText: false),
            const SizedBox(height: 20),
            const Text('PET BASE', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.brandDark, letterSpacing: .5)),
            const SizedBox(height: 8),
            const Text('반려견 건강상태 알림 프로그램', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 44),
            SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 4, color: AppColors.brand.withOpacity(.85))),
            const SizedBox(height: 16),
            const Text('우리 아이의 상태를 확인하는 중이에요', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}
