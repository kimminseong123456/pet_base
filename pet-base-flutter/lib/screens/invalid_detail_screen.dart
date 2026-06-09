import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../models/health_record.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_ui.dart';
import 'device_management_screen.dart';
import 'wear_guide_screen.dart';

class InvalidDetailScreen extends StatelessWidget {
  const InvalidDetailScreen({super.key, required this.record});

  factory InvalidDetailScreen.fromDashboard(DashboardModel data) {
    return InvalidDetailScreen(record: HealthRecord.fromDashboard(data));
  }

  final HealthRecord record;

  @override
  Widget build(BuildContext context) {
    final reason = record.invalidReason ?? 'no_contact';
    return ScreenScaffold(
      title: '측정불가 상세',
      subtitle: '오늘 ${record.timeRangeLabel}',
      showLogo: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SoftCard(color: AppColors.statusSoft(record.status), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('측정 상태 안내', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          const Text('지금은 정확히 측정하기 어려워요', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(invalidReasonTitle(reason), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.invalid)),
          const SizedBox(height: 6),
          Text(invalidReasonGuide(reason), style: const TextStyle(height: 1.45, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ActionChipButton(label: reason, icon: Icons.code_rounded, color: AppColors.invalid),
        ])),
        const SectionTitle('무엇을 확인할까요?'),
        SoftCard(child: Column(children: const [
          InfoRow(icon: Icons.check_circle_rounded, title: '하네스가 너무 느슨하지 않은지 확인', value: ''),
          InfoRow(icon: Icons.sensors_rounded, title: '센서가 피부에 잘 닿는지 확인', value: ''),
          InfoRow(icon: Icons.self_improvement_rounded, title: '강아지가 안정된 자세인지 확인', value: ''),
        ])),
        const SectionTitle('재측정 안내'),
        SoftCard(child: Column(children: const [
          InfoRow(icon: Icons.tune_rounded, title: '착용 상태 조정', value: '1'),
          InfoRow(icon: Icons.timer_rounded, title: '1분 뒤 다시 측정', value: '2'),
          InfoRow(icon: Icons.devices_rounded, title: '반복되면 기기 관리 화면 확인', value: '3'),
        ])),
        const SectionTitle('바로가기'),
        Wrap(spacing: 10, runSpacing: 10, children: [
          ActionChipButton(label: '착용 가이드 보기', icon: Icons.checkroom_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WearGuideScreen()))),
          ActionChipButton(label: '기기 관리로 이동', icon: Icons.devices_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeviceManagementScreen()))),
        ]),
        const SizedBox(height: 18),
        const DisclaimerBox(extra: '측정불가는 건강등급이 아니라 현재 데이터 품질로는 판독하기 어렵다는 뜻입니다.'),
      ]),
    );
  }
}
