import 'package:flutter/material.dart';

import '../models/dashboard_model.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_base_ui.dart';
import 'baseline_screen.dart';
import 'device_management_screen.dart';
import 'multi_pet_screen.dart';
import 'wear_guide_screen.dart';

class PetProfileScreen extends StatefulWidget {
  const PetProfileScreen({super.key});

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  final ApiService _api = ApiService();
  late Future<DashboardModel> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchDashboard();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardModel>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.brand));
        }
        if (snapshot.hasError) {
          return Center(child: Padding(padding: const EdgeInsets.all(24), child: SoftCard(child: Text(snapshot.error.toString()))));
        }
        final data = snapshot.data;
        if (data == null) return const Center(child: Text('서버 프로필 데이터가 없습니다.'));
        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
          children: [
            const PetBaseHeader(),
            const SizedBox(height: 26),
            const Text('반려견 관리', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            const SizedBox(height: 18),
            _HeroProfile(data: data),
            const SizedBox(height: 18),
            _ProfileRows(data: data),
            const SizedBox(height: 18),
            _DeviceCard(data: data, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DeviceManagementScreen()))),
            const SizedBox(height: 18),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.brand, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '위 프로필 정보는 반려견의 생체신호 및 건강 상태 해석에 사용됩니다. 정확한 정보를 유지해 주세요.',
                          style: TextStyle(height: 1.55, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.edit_rounded), label: const Text('프로필 수정')),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DeviceManagementScreen())),
                    icon: const Icon(Icons.devices_rounded),
                    label: const Text('기기 정보 보기'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _QuickLinks(),
          ],
        );
      },
    );
  }
}

class _HeroProfile extends StatelessWidget {
  const _HeroProfile({required this.data});
  final DashboardModel data;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: AppColors.brandSoft,
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=300'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 26),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(data.dogName, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, height: 1))),
                    const SizedBox(width: 10),
                    const Icon(Icons.verified_rounded, color: AppColors.brand),
                  ],
                ),
                const SizedBox(height: 8),
                Text(data.breed ?? '품종 미제공', style: const TextStyle(fontSize: 22, color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 16,
                  runSpacing: 10,
                  children: [
                    _ProfileBadge(icon: Icons.monitor_weight_outlined, text: data.weightKg == null ? '몸무게 미제공' : '${data.weightKg!.toStringAsFixed(1)}kg'),
                    _ProfileBadge(icon: Icons.thermostat_rounded, text: data.baselineTempC == null ? '기준 체온 추정 미제공' : '기준 체온 ${data.baselineTempC!.toStringAsFixed(1)}°C'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_rounded, color: AppColors.brand)),
        ],
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 21, color: AppColors.textSecondary), const SizedBox(width: 7), Text(text, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w700))]);
}

class _ProfileRows extends StatelessWidget {
  const _ProfileRows({required this.data});
  final DashboardModel data;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          _InfoRow(icon: Icons.person_rounded, label: '이름', value: data.dogName),
          const ThinDivider(),
          _InfoRow(icon: Icons.pets_rounded, label: '품종', value: data.breed ?? '서버 미제공'),
          const ThinDivider(),
          _InfoRow(icon: Icons.monitor_weight_rounded, label: '몸무게', value: data.weightKg == null ? '서버 미제공' : '${data.weightKg!.toStringAsFixed(1)} kg'),
          const ThinDivider(),
          _InfoRow(icon: Icons.thermostat_rounded, label: '기준 체온 추정값', value: data.baselineTempC == null ? '서버 미제공' : '${data.baselineTempC!.toStringAsFixed(1)} °C'),
          const ThinDivider(),
          _InfoRow(icon: Icons.favorite_rounded, label: '심장 위험 모드', value: data.heartRiskMode == true ? 'ON' : 'OFF', trailing: Switch(value: data.heartRiskMode == true, onChanged: (_) {})),
          const ThinDivider(),
          const _InfoRow(icon: Icons.verified_user_rounded, label: '활성 상태', value: '활성'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value, this.trailing});
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          MetricIcon(icon: icon, color: AppColors.brand, size: 42),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
          if (trailing != null) trailing! else Text(value, style: const TextStyle(fontSize: 17, color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.data, required this.onTap});
  final DashboardModel data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      color: AppColors.mintLight,
      borderColor: AppColors.brand.withOpacity(0.16),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(color: AppColors.brandSoft, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.shopping_bag_outlined, color: AppColors.brand, size: 38),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('연결 기기', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(data.deviceId ?? 'dog-001', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('배터리 ${data.batteryPct ?? 82}%  |  최근 확인 ${formatTime(data.measuredAt)}', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.brandSoft, borderRadius: BorderRadius.circular(999)),
            child: const Text('연결됨', style: TextStyle(color: AppColors.brand, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(
        children: [
          ActionRow(icon: Icons.pets_rounded, title: '다중 반려견 선택', subtitle: '여러 반려견을 개별적으로 관리합니다.', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MultiPetScreen()))),
          const ThinDivider(),
          ActionRow(icon: Icons.auto_graph_rounded, title: '기준선 생성', subtitle: '보리의 평소 상태 기준을 확인합니다.', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BaselineScreen()))),
          const ThinDivider(),
          ActionRow(icon: Icons.menu_book_rounded, title: '착용 가이드 보기', subtitle: '하네스와 센서 밀착 위치를 확인합니다.', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WearGuideScreen()))),
        ],
      ),
    );
  }
}
