import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/pet_base_ui.dart';
import 'account_privacy_screen.dart';
import 'notification_history_screen.dart';
import 'rule_guide_screen.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool normal = true;
  bool interest = true;
  bool caution = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
      children: [
        const PetBaseHeader(),
        const SizedBox(height: 28),
        const Text('알림 설정', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        const SizedBox(height: 18),
        SoftCard(
          color: AppColors.mintLight,
          borderColor: AppColors.brand.withOpacity(0.20),
          padding: const EdgeInsets.all(24),
          child: Row(
            children: const [
              MetricIcon(icon: Icons.notifications_active_rounded, color: AppColors.brand, size: 78),
              SizedBox(width: 22),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('상태 변화 알림을 설정하세요', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  SizedBox(height: 8),
                  Text('반려견의 상태 변화에 따라 필요한 알림을 받아보세요.', style: TextStyle(fontSize: 16, height: 1.45, color: AppColors.textSecondary)),
                ]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('상태별 알림', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            children: [
              _SwitchRow(icon: Icons.shield_rounded, title: '정상', subtitle: '모든 지표가 안정적인 상태', value: normal, onChanged: (v) => setState(() => normal = v)),
              const ThinDivider(),
              _SwitchRow(icon: Icons.favorite_border_rounded, title: '관심', subtitle: '가벼운 변화가 감지된 상태', value: interest, onChanged: (v) => setState(() => interest = v), iconColor: AppColors.interest),
              const ThinDivider(),
              _SwitchRow(icon: Icons.warning_amber_rounded, title: '주의', subtitle: '주의가 필요한 상태 변화', value: caution, onChanged: (v) => setState(() => caution = v), iconColor: AppColors.caution),
              const ThinDivider(),
              const _LockedAlertRow(icon: Icons.error_outline_rounded, title: '위험', subtitle: '건강에 위험이 감지된 상태'),
              const ThinDivider(),
              const _LockedAlertRow(icon: Icons.notification_important_rounded, title: '응급', subtitle: '즉시 조치가 필요한 응급 상태'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        InfoNotice(
          color: AppColors.blue,
          icon: Icons.health_and_safety_rounded,
          text: '위험 / 응급 알림은 반려견의 안전과 관련되어 항상 켜져 있습니다.',
        ),
        const SizedBox(height: 18),
        _PreviewBanner(),
        const SizedBox(height: 18),
        InfoNotice(
          icon: Icons.info_outline_rounded,
          text: '실제 푸시 알림은 MVP 범위에서 제외되며, 앱 내 경고 배너로 안내합니다.',
        ),
        const SizedBox(height: 18),
        _SettingLinks(),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged, this.iconColor = AppColors.brand});
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          MetricIcon(icon: icon, color: iconColor, size: 54),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.35)),
          ])),
          Switch(value: value, activeColor: AppColors.brand, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _LockedAlertRow extends StatelessWidget {
  const _LockedAlertRow({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          MetricIcon(icon: icon, color: AppColors.danger, size: 54),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.35)),
          ])),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: AppColors.brandSoft, borderRadius: BorderRadius.circular(999)),
                child: const Text('항상 켜짐', style: TextStyle(color: AppColors.brand, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 6),
              const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: const Color(0xFFFFFAF1),
      borderColor: AppColors.orange.withOpacity(0.28),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(child: Text('경고 배너 미리보기 · 즉시 상태를 확인해 주세요', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w900, fontSize: 16))),
              Icon(Icons.close_rounded, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
            child: Row(
              children: const [
                MetricIcon(icon: Icons.warning_amber_rounded, color: AppColors.orange, size: 58),
                SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('반려견의 상태에 주의가 필요해요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  SizedBox(height: 4),
                  Text('지금 바로 상태를 확인하고 필요시 상담을 권장합니다.', style: TextStyle(color: AppColors.textSecondary, height: 1.35)),
                ])),
                Text('지금 확인', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w900)),
                Icon(Icons.chevron_right_rounded, color: AppColors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(
        children: [
          ActionRow(icon: Icons.history_rounded, title: '알림 수신 내역', subtitle: '최근 7일 내 알림을 확인합니다.', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationHistoryScreen()))),
          const ThinDivider(),
          ActionRow(icon: Icons.rule_rounded, title: '판독 기준 설명', subtitle: '규칙 기반 판독 흐름을 확인합니다.', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RuleGuideScreen()))),
          const ThinDivider(),
          ActionRow(icon: Icons.account_circle_outlined, title: '계정 및 개인정보', subtitle: '계정, 동의, 데이터 관리를 확인합니다.', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountPrivacyScreen()))),
        ],
      ),
    );
  }
}
