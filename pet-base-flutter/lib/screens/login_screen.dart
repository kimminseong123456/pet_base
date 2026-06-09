import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_ui.dart';
import 'main_shell_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _enter(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShellScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(22, 22, 22, 28), children: [
          const PetLogo(size: 36),
          const SizedBox(height: 28),
          SoftCard(
            color: AppColors.mintLight,
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('PET BASE에 오신 것을 환영합니다', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                SizedBox(height: 8),
                Text('계정별로 반려견 프로필과 건강기록이 안전하게 관리됩니다.', style: TextStyle(color: AppColors.textSecondary, height: 1.45, fontWeight: FontWeight.w600)),
              ])),
              Container(width: 74, height: 74, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)), child: const Icon(Icons.pets_rounded, color: AppColors.brand, size: 42)),
            ]),
          ),
          const SizedBox(height: 22),
          const _LoginField(label: '이메일', icon: Icons.mail_outline_rounded),
          const SizedBox(height: 12),
          const _LoginField(label: '비밀번호', icon: Icons.lock_outline_rounded, obscure: true),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('비밀번호를 잊으셨나요?'))),
          FilledButton(onPressed: () => _enter(context), child: const Text('로그인')),
          const SizedBox(height: 14),
          Center(child: TextButton(onPressed: () {}, child: const Text.rich(TextSpan(text: '아직 계정이 없나요? ', children: [TextSpan(text: '회원가입', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.brand))])))),
          const SizedBox(height: 12),
          const Center(child: Text('또는', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700))),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => _enter(context), child: const Text('카카오'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: () => _enter(context), child: const Text('구글'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: () => _enter(context), child: const Text('애플'))),
          ]),
          const SizedBox(height: 18),
          const Text('데모 시연에서는 로그인 버튼을 누르면 앱으로 바로 진입합니다.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ]),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({required this.label, required this.icon, this.obscure = false});
  final String label;
  final IconData icon;
  final bool obscure;
  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.border)),
      ),
    );
  }
}
