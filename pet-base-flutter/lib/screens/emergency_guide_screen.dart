import 'package:flutter/material.dart';
import '../models/pet_status.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_ui.dart';

class EmergencyGuideScreen extends StatelessWidget {
  const EmergencyGuideScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(title: '응급 대응 가이드', subtitle: '즉시 확인이 필요한 상황이에요.', showLogo: false, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SoftCard(color: AppColors.statusSoft(PetStatus.emergency), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Icon(Icons.emergency_rounded, color: AppColors.emergency, size: 42),
        SizedBox(height: 14),
        Text('지금은 즉시 대응이 필요해요', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        SizedBox(height: 8),
        Text('호흡곤란, 실신, 의식저하가 있으면 지체하지 말고 병원으로 이동하세요.', style: TextStyle(color: AppColors.textSecondary, height: 1.45, fontWeight: FontWeight.w700)),
      ])),
      const SectionTitle('즉시 내원 신호'),
      Wrap(spacing: 8, runSpacing: 8, children: const [
        ActionChipButton(label: '개구호흡', icon: Icons.warning_rounded, color: AppColors.emergency),
        ActionChipButton(label: '복식호흡', icon: Icons.warning_rounded, color: AppColors.emergency),
        ActionChipButton(label: '실신', icon: Icons.warning_rounded, color: AppColors.emergency),
        ActionChipButton(label: '의식저하', icon: Icons.warning_rounded, color: AppColors.emergency),
        ActionChipButton(label: '잇몸/혀 색 이상', icon: Icons.warning_rounded, color: AppColors.emergency),
      ]),
      const SectionTitle('즉시 할 일'),
      SoftCard(child: Column(children: const [
        InfoRow(icon: Icons.ac_unit_rounded, title: '조용하고 시원한 곳으로 이동', value: ''),
        InfoRow(icon: Icons.visibility_rounded, title: '활동 중단 후 호흡 상태 확인', value: ''),
        InfoRow(icon: Icons.no_food_rounded, title: '억지로 물이나 음식을 먹이지 않기', value: ''),
        InfoRow(icon: Icons.local_hospital_rounded, title: '빠르게 병원 이동 준비', value: ''),
      ])),
      const SectionTitle('하지 말 것'),
      SoftCard(child: Column(children: const [
        InfoRow(icon: Icons.close_rounded, title: '강한 운동 계속하기', value: ''),
        InfoRow(icon: Icons.close_rounded, title: '사람용 약 임의 투여', value: ''),
        InfoRow(icon: Icons.close_rounded, title: '무리한 강제 급수', value: ''),
      ])),
      const SizedBox(height: 18),
      const DisclaimerBox(extra: '증상이 지속되거나 악화되면 즉시 내원하세요.'),
    ]));
  }
}
