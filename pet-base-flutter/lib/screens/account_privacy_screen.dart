import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_ui.dart';

class AccountPrivacyScreen extends StatelessWidget {
  const AccountPrivacyScreen({super.key});
  @override
  Widget build(BuildContext context) => ScreenScaffold(title: '계정 및 개인정보', subtitle: '보호자 계정과 데이터 권한을 관리해요.', showLogo: false, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SoftCard(color: AppColors.mintLight, child: Row(children: [Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.person_rounded, color: AppColors.brand, size: 36)), const SizedBox(width: 14), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('김민성', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), Text('보호자 계정', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700))]))])),
    const SectionTitle('계정'),
    SoftCard(child: Column(children: const [InfoRow(icon: Icons.mail_rounded, title: '이메일', value: '보기'), InfoRow(icon: Icons.lock_rounded, title: '비밀번호 변경', value: ''), InfoRow(icon: Icons.verified_user_rounded, title: '2단계 인증', value: 'OFF'), InfoRow(icon: Icons.logout_rounded, title: '로그아웃', value: '')])),
    const SectionTitle('개인정보 및 데이터'),
    SoftCard(child: Column(children: const [InfoRow(icon: Icons.policy_rounded, title: '개인정보 처리방침', value: ''), InfoRow(icon: Icons.health_and_safety_rounded, title: '건강 데이터 안내', value: ''), InfoRow(icon: Icons.download_rounded, title: '데이터 다운로드', value: ''), InfoRow(icon: Icons.delete_outline_rounded, title: '반려견/기록 삭제 요청', value: '')])),
    const SectionTitle('동의 및 권한'),
    SoftCard(child: Column(children: const [InfoRow(icon: Icons.notifications_rounded, title: '알림 권한', value: 'ON'), InfoRow(icon: Icons.dataset_rounded, title: '데이터 이용 동의', value: 'ON'), InfoRow(icon: Icons.campaign_rounded, title: '마케팅 정보 수신', value: 'OFF')])),
    const SizedBox(height: 18), const DisclaimerBox(extra: '반려견 프로필과 건강기록은 계정별로 안전하게 관리됩니다.'),
  ]));
}
