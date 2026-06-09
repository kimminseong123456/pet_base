import 'package:flutter/material.dart';

import '../models/dashboard_model.dart';
import '../models/health_record.dart';
import '../models/pet_status.dart';
import '../models/measurement_window.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_ui.dart';
import 'emergency_guide_screen.dart';

class StatusDetailScreen extends StatelessWidget {
  const StatusDetailScreen({super.key, required this.record});

  factory StatusDetailScreen.fromDashboard(DashboardModel data) {
    return StatusDetailScreen(record: HealthRecord.fromDashboard(data));
  }

  factory StatusDetailScreen.fromWindow(MeasurementWindow item) {
    return StatusDetailScreen(record: HealthRecord.fromWindow(item));
  }

  final HealthRecord record;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.status(record.status);
    return ScreenScaffold(
      title: '상태 상세',
      subtitle: '오늘 ${record.timeRangeLabel}',
      showLogo: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SoftCard(color: AppColors.statusSoft(record.status), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Text('15분 요약 결과', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textSecondary)), const Spacer(), StatusPill(status: record.status)]),
          const SizedBox(height: 22),
          Text(petStatusTitle(record.status), style: TextStyle(fontSize: 44, height: 1, color: color, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(_summary(record.status), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(_detail(record.status), style: const TextStyle(color: AppColors.textSecondary, height: 1.45, fontWeight: FontWeight.w700)),
        ])),
        const SectionTitle('생체신호 상세'),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            MetricTile(title: '심박수', value: record.hrBpm?.toString() ?? '-', unit: 'bpm', icon: Icons.favorite_rounded, color: Colors.redAccent),
            MetricTile(title: '호흡수', value: record.rrBpm?.toString() ?? '-', unit: '회/분', icon: Icons.air_rounded, color: Colors.blueAccent),
            MetricTile(title: '체온 추정', value: record.tempEstC?.toStringAsFixed(1) ?? '-', unit: '°C', icon: Icons.thermostat_rounded, color: Colors.orangeAccent),
            MetricTile(title: 'SQI', value: record.sqiAverage?.toStringAsFixed(2) ?? '-', icon: Icons.graphic_eq_rounded, color: AppColors.brand, caption: '측정 품질'),
          ],
        ),
        const SectionTitle('가능한 원인'),
        SoftCard(child: Column(children: [
          InfoRow(icon: Icons.thermostat_rounded, title: '흥분·더위·스트레스 영향 가능', value: ''),
          InfoRow(icon: Icons.healing_rounded, title: '통증 또는 불편감 가능성', value: ''),
          InfoRow(icon: Icons.monitor_heart_rounded, title: '반복되면 심폐 부담 가능성 고려', value: ''),
        ])),
        const SectionTitle('지금 할 일'),
        SoftCard(child: Column(children: [
          InfoRow(icon: Icons.ac_unit_rounded, title: '조용하고 시원한 환경으로 이동', value: ''),
          InfoRow(icon: Icons.refresh_rounded, title: '10~30분 후 다시 확인', value: ''),
          InfoRow(icon: Icons.local_hospital_rounded, title: '숨이 더 힘들어 보이면 즉시 병원 이동', value: '', color: AppColors.emergency, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyGuideScreen()))),
        ])),
        const SectionTitle('즉시 내원 신호'),
        Wrap(spacing: 8, runSpacing: 8, children: const [
          ActionChipButton(label: '개구호흡', icon: Icons.warning_rounded, color: AppColors.emergency),
          ActionChipButton(label: '복식호흡', icon: Icons.warning_rounded, color: AppColors.emergency),
          ActionChipButton(label: '실신', icon: Icons.warning_rounded, color: AppColors.emergency),
          ActionChipButton(label: '의식저하', icon: Icons.warning_rounded, color: AppColors.emergency),
        ]),
        const SizedBox(height: 18),
        const DisclaimerBox(extra: '증상이 지속되거나 악화되면 수의사 상담 또는 내원을 권장합니다.'),
      ]),
    );
  }

  String _summary(PetStatus status) {
    if (status == PetStatus.danger || status == PetStatus.emergency) return '맥박과 호흡이 함께 상승했습니다.';
    if (status == PetStatus.caution) return '조금 더 세심한 관찰이 필요해요.';
    if (status == PetStatus.interest) return '가벼운 변화가 감지됐어요.';
    return '현재 생체신호가 안정적입니다.';
  }

  String _detail(PetStatus status) {
    if (status == PetStatus.danger || status == PetStatus.emergency) return '흥분, 스트레스, 통증, 더움 등이 가능해요. 안정 후에도 지속되면 내원을 권장합니다.';
    return petStatusHelper(status);
  }
}
