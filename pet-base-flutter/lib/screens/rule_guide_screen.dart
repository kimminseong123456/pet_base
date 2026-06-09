import 'package:flutter/material.dart';
import '../models/pet_status.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_ui.dart';

class RuleGuideScreen extends StatelessWidget {
  const RuleGuideScreen({super.key});
  @override
  Widget build(BuildContext context) => ScreenScaffold(title: '판독 기준 설명', subtitle: 'PET BASE는 AI가 아니라 규칙 기반 판독을 사용합니다.', showLogo: false, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SoftCard(color: AppColors.mintLight, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('규칙 기반 판독', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)), SizedBox(height: 8), Text('stable과 SQI를 먼저 확인하고, 그 다음 T/P/R 점수를 계산하여 최종 상태를 안내합니다.', style: TextStyle(height: 1.45, color: AppColors.textSecondary, fontWeight: FontWeight.w700))])),
    const SectionTitle('판독 흐름'),
    SoftCard(child: Column(children: const [InfoRow(icon: Icons.filter_alt_rounded, title: 'stable · SQI 확인', value: '1'), InfoRow(icon: Icons.calculate_rounded, title: 'T/P/R 점수 계산', value: '2'), InfoRow(icon: Icons.health_and_safety_rounded, title: '최종 상태 안내', value: '3')])),
    const SectionTitle('상태 기준'),
    Wrap(spacing: 8, runSpacing: 8, children: [for (final s in PetStatus.values) StatusPill(status: s)]),
    const SizedBox(height: 18),
    const DisclaimerBox(extra: '측정불가는 건강등급이 아니라 데이터 품질 문제로 판독이 어려운 상태입니다.'),
  ]));
}
