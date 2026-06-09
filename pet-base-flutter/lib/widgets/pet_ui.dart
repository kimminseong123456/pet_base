import 'package:flutter/material.dart';
import '../models/pet_status.dart';
import '../theme/app_colors.dart';

class PetLogo extends StatelessWidget {
  const PetLogo({super.key, this.size = 38, this.showText = true});
  final double size;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.brand,
            borderRadius: BorderRadius.circular(size * .32),
            boxShadow: [BoxShadow(color: AppColors.brand.withOpacity(.20), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: Icon(Icons.pets_rounded, color: Colors.white, size: size * .56),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          const Text('PET BASE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.brandDark)),
        ],
      ],
    );
  }
}

class BellDot extends StatelessWidget {
  const BellDot({super.key, this.onTap});
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(onPressed: onTap, icon: const Icon(Icons.notifications_none_rounded)),
        Positioned(
          right: 10,
          top: 10,
          child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.brand, shape: BoxShape.circle)),
        ),
      ],
    );
  }
}

class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({super.key, required this.title, required this.child, this.subtitle, this.showLogo = true, this.trailing, this.padding});
  final String title;
  final String? subtitle;
  final Widget child;
  final bool showLogo;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: Navigator.of(context).canPop(),
        title: showLogo ? const PetLogo(size: 34) : Text(title),
        actions: [trailing ?? const BellDot(), const SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: ListView(
          padding: padding ?? const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!, style: const TextStyle(fontSize: 14, height: 1.45, color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.color = AppColors.surface, this.onTap});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(.8)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.045), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(borderRadius: BorderRadius.circular(26), onTap: onTap, child: card);
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status, this.compact = false});
  final PetStatus status;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 5 : 7),
      decoration: BoxDecoration(color: AppColors.statusSoft(status), borderRadius: BorderRadius.circular(999)),
      child: Text(petStatusTitle(status), style: TextStyle(fontSize: compact ? 12 : 13, fontWeight: FontWeight.w900, color: AppColors.status(status))),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.title, required this.value, required this.icon, this.unit = '', this.caption, this.color = AppColors.brand});
  final String title;
  final String value;
  final String unit;
  final String? caption;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(13)),
          child: Icon(icon, color: color, size: 20),
        ),
        const Spacer(),
        Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            text: value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            children: [if (unit.isNotEmpty) TextSpan(text: ' $unit', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textSecondary))],
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 5),
          Text(caption!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ]),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 12, 2, 10),
      child: Row(children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary))),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.icon, required this.title, required this.value, this.color = AppColors.brand, this.onTap});
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 21)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
          if (onTap != null) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted)),
        ]),
      ),
    );
  }
}

class DisclaimerBox extends StatelessWidget {
  const DisclaimerBox({super.key, this.extra});
  final String? extra;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)),
      child: Text(
        '본 결과는 웨어러블 생체신호 기반의 추정 안내이며 진단이 아닙니다.${extra == null ? '' : '\n$extra'}',
        style: const TextStyle(fontSize: 12, height: 1.45, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class ActionChipButton extends StatelessWidget {
  const ActionChipButton({super.key, required this.label, required this.icon, this.onTap, this.color = AppColors.brand});
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(18)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18, color: color), const SizedBox(width: 7), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900))]),
      ),
    );
  }
}

String invalidReasonTitle(String? code) {
  switch (code) {
    case 'motion':
      return '강아지가 움직이고 있어요';
    case 'no_contact':
      return '센서 밀착이 부족할 수 있어요';
    case 'unstable':
      return '센서가 흔들리거나 값이 불안정해요';
    case 'jump':
      return '측정값이 급변했어요';
    case 'sensor_error':
      return '센서 또는 전송 오류가 의심돼요';
    default:
      return '착용 상태와 센서 품질을 확인해 주세요';
  }
}

String invalidReasonGuide(String? code) {
  switch (code) {
    case 'motion':
      return '안정된 자세로 1분 뒤 다시 측정해 주세요.';
    case 'no_contact':
      return '하네스를 조금 더 조이거나 센서 위치를 조정해 주세요.';
    case 'unstable':
      return '착용 상태를 점검한 뒤 다시 측정해 주세요.';
    case 'jump':
      return '30초 후 재측정해 주세요.';
    case 'sensor_error':
      return '앱 재시도 후 지속되면 기기 점검이 필요합니다.';
    default:
      return '움직임, 밀착, 품질 문제를 확인한 뒤 다시 측정해 주세요.';
  }
}
