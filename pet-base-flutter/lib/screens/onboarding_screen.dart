import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_ui.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _goLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(22, 22, 22, 28), children: [
          const PetLogo(size: 34),
          const SizedBox(height: 28),
          const Text('반려견 건강을\n더 안심하게', style: TextStyle(fontSize: 34, height: 1.1, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          const Text('심박·호흡·체온 추정·움직임을 기반으로 현재 상태와 행동 가이드를 안내합니다.', style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          SoftCard(
            color: AppColors.mintLight,
            child: Column(children: [
              Container(width: 128, height: 128, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(42)), child: const Icon(Icons.pets_rounded, size: 70, color: AppColors.brand)),
              const SizedBox(height: 18),
              const _Benefit(icon: Icons.favorite_rounded, title: '심박·호흡·체온 추정을 한눈에 확인'),
              const _Benefit(icon: Icons.warning_amber_rounded, title: '위험·응급 상태를 빠르게 안내'),
              const _Benefit(icon: Icons.fact_check_rounded, title: '측정불가 사유와 재측정 가이드 제공'),
            ]),
          ),
          const SizedBox(height: 18),
          const DisclaimerBox(extra: '체온은 표면온 기반 체온 추정으로 안내돼요.'),
          const SizedBox(height: 22),
          FilledButton(onPressed: () => _goLogin(context), child: const Text('시작하기')),
          TextButton(onPressed: () => _goLogin(context), child: const Text('로그인 / 회원가입')),
        ]),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.brand.withOpacity(.12), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: AppColors.brand)),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary))),
      ]),
    );
  }
}
