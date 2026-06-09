import 'package:flutter/material.dart';
import '../models/pet_status.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_ui.dart';

class NotificationHistoryScreen extends StatelessWidget {
  const NotificationHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => ScreenScaffold(title: '알림 수신 내역', subtitle: '최근 위험/응급/주의/측정불가 이벤트를 확인해요.', showLogo: false, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SoftCard(color: AppColors.mintLight, child: Row(children: const [Icon(Icons.info_rounded, color: AppColors.brand), SizedBox(width: 12), Expanded(child: Text('위험 / 응급 알림은 항상 켜짐이며, 최근 수신한 알림 내역을 확인할 수 있어요.', style: TextStyle(fontWeight: FontWeight.w800)))])),
    const SectionTitle('오늘'),
    _Row(name: '보리', status: PetStatus.danger, msg: '빠른 확인이 필요해요', time: '14:20'),
    _Row(name: '보리', status: PetStatus.invalid, msg: '센서 밀착을 확인해 주세요', time: '13:55'),
    const SectionTitle('어제'),
    _Row(name: '몽이', status: PetStatus.emergency, msg: '즉시 대응이 필요해요', time: '어제 21:10'),
    _Row(name: '코코', status: PetStatus.caution, msg: '조금 더 세심한 관찰이 필요해요', time: '어제 18:30'),
    const SizedBox(height: 12), const Text('최근 7일 내 알림을 확인할 수 있어요', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
  ]));
}
class _Row extends StatelessWidget { const _Row({required this.name, required this.status, required this.msg, required this.time}); final String name, msg, time; final PetStatus status; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftCard(padding: const EdgeInsets.all(16), child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.statusSoft(status), borderRadius: BorderRadius.circular(16)), child: Icon(Icons.notifications_active_rounded, color: AppColors.status(status))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(width: 8), StatusPill(status: status, compact: true)]), const SizedBox(height: 5), Text(msg, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700))])), Text(time, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))]))); }
