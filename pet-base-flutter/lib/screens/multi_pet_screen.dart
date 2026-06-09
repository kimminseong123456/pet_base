import 'package:flutter/material.dart';
import '../models/pet_status.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_ui.dart';

class MultiPetScreen extends StatelessWidget {
  const MultiPetScreen({super.key});
  @override
  Widget build(BuildContext context) => ScreenScaffold(title: '반려견 선택', subtitle: '등록된 반려견별 건강 상태를 확인해요.', showLogo: false, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SoftCard(color: AppColors.mintLight, child: Row(children: const [Icon(Icons.check_circle_rounded, color: AppColors.brand), SizedBox(width: 12), Expanded(child: Text('현재 선택: 보리', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)))])),
    const SectionTitle('등록된 반려견'),
    _PetRow(name: '보리', breed: '말티즈', weight: '4.2kg', status: PetStatus.danger, selected: true),
    _PetRow(name: '몽이', breed: '푸들', weight: '6.8kg', status: PetStatus.normal),
    _PetRow(name: '코코', breed: '포메라니안', weight: '3.9kg', status: PetStatus.interest),
    const SizedBox(height: 10),
    FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add_rounded), label: const Text('반려견 추가')),
    const SizedBox(height: 18), const DisclaimerBox(extra: '각 반려견은 별도의 프로필과 건강기록으로 관리됩니다.'),
  ]));
}
class _PetRow extends StatelessWidget {
  const _PetRow({required this.name, required this.breed, required this.weight, required this.status, this.selected = false});
  final String name, breed, weight; final PetStatus status; final bool selected;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftCard(child: Row(children: [Container(width: 54, height: 54, decoration: BoxDecoration(color: AppColors.brandSoft, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.pets_rounded, color: AppColors.brand)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), Text('$breed · $weight', style: const TextStyle(color: AppColors.textSecondary))])), StatusPill(status: status, compact: true), const SizedBox(width: 8), Icon(selected ? Icons.check_circle_rounded : Icons.chevron_right_rounded, color: selected ? AppColors.brand : AppColors.textMuted)])));
}
