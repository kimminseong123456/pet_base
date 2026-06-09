import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_ui.dart';

class WearGuideScreen extends StatelessWidget {
  const WearGuideScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(title: '착용 가이드', subtitle: '정확한 측정을 위해 착용 위치와 밀착 상태를 확인해 주세요.', showLogo: false, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SoftCard(color: AppColors.mintLight, child: Column(children: [
        Container(width: 150, height: 110, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)), child: const Icon(Icons.pets_rounded, color: AppColors.brand, size: 82)),
        const SizedBox(height: 18),
        const InfoRow(icon: Icons.favorite_rounded, title: '가슴 부위', value: 'MAX30102 + BMI270'),
        const InfoRow(icon: Icons.thermostat_rounded, title: '목·경부', value: 'TMP117'),
        const InfoRow(icon: Icons.memory_rounded, title: '등 부위', value: 'ESP32 + 배터리'),
      ])),
      const SectionTitle('착용 순서'),
      SoftCard(child: Column(children: const [
        InfoRow(icon: Icons.looks_one_rounded, title: '하네스를 몸에 맞게 착용', value: ''),
        InfoRow(icon: Icons.looks_two_rounded, title: '센서가 피부에 밀착되도록 조정', value: ''),
        InfoRow(icon: Icons.looks_3_rounded, title: '앱에서 연결과 측정 상태 확인', value: ''),
      ])),
      const SectionTitle('꼭 확인하세요'),
      SoftCard(child: Column(children: const [
        InfoRow(icon: Icons.check_circle_rounded, title: '너무 헐겁지 않게 조정', value: ''),
        InfoRow(icon: Icons.check_circle_rounded, title: '털이 많이 끼지 않도록 정리', value: ''),
        InfoRow(icon: Icons.check_circle_rounded, title: '안정된 자세에서 측정', value: ''),
        InfoRow(icon: Icons.check_circle_rounded, title: '측정불가가 반복되면 위치 재조정', value: ''),
      ])),
      const SizedBox(height: 18),
      const DisclaimerBox(extra: '체온은 반드시 체온 추정으로 안내되며, 움직임이 많은 구간은 측정불가가 될 수 있어요.'),
    ]));
  }
}
