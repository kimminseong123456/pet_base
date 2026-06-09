import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_ui.dart';

class BaselineScreen extends StatelessWidget {
  const BaselineScreen({super.key});
  @override
  Widget build(BuildContext context) => ScreenScaffold(title: '기준선 생성', subtitle: '보리의 안정/휴식/수면 구간으로 개인 기준선을 만들어요.', showLogo: false, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SoftCard(color: AppColors.mintLight, child: Column(children: const [
      SizedBox(height: 10),
      SizedBox(width: 120, height: 120, child: CircularProgressIndicator(value: .68, strokeWidth: 12, color: AppColors.brand, backgroundColor: Colors.white)),
      SizedBox(height: 16),
      Text('2일차 / 3일 · 68%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.brandDark)),
      SizedBox(height: 8),
      Text('보리의 평소 상태를 더 정확히 이해하고 있어요', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
    ])),
    const SectionTitle('진행 단계'),
    SoftCard(child: Column(children: const [InfoRow(icon: Icons.download_done_rounded, title: '데이터 수집', value: '완료'), InfoRow(icon: Icons.filter_alt_rounded, title: '안정 구간 선별', value: '진행 중'), InfoRow(icon: Icons.flag_rounded, title: '기준선 생성 완료', value: '대기')])),
    const SectionTitle('완료를 위해 해주세요'),
    SoftCard(child: Column(children: const [InfoRow(icon: Icons.check_circle_rounded, title: '안정된 자세에서 착용', value: ''), InfoRow(icon: Icons.check_circle_rounded, title: '꾸준히 착용 유지', value: ''), InfoRow(icon: Icons.check_circle_rounded, title: '충전 상태 확인', value: '')])),
    const SizedBox(height: 18), const DisclaimerBox(extra: '체온은 반드시 체온 추정으로 안내됩니다.'),
  ]));
}
