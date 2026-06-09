import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/pet_status.dart';
import '../theme/app_colors.dart';

class PetBaseHeader extends StatelessWidget {
  const PetBaseHeader({super.key, this.showBell = true});
  final bool showBell;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.brand, width: 2),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.pets_rounded, color: AppColors.brand, size: 19),
        ),
        const SizedBox(width: 10),
        const Text(
          'PET BASE',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.brand),
        ),
        const Spacer(),
        if (showBell)
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded, size: 30, color: AppColors.textPrimary),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(color: AppColors.brand, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding, this.color, this.borderColor, this.radius = 24, this.onTap});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? AppColors.border.withOpacity(0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return content;
    return InkWell(borderRadius: BorderRadius.circular(radius), onTap: onTap, child: content);
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status, this.text});
  final PetStatus status;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.status(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.statusSoft(status),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(text ?? status.title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900)),
    );
  }
}

class MetricIcon extends StatelessWidget {
  const MetricIcon({super.key, required this.icon, required this.color, this.size = 50});
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: size * 0.50),
    );
  }
}

class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.color, this.values = const [2, 3, 2, 4, 3, 3, 5, 2, 2, 3, 4, 3, 5, 4]});
  final Color color;
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: double.infinity,
      child: CustomPaint(painter: _SparklinePainter(color: color, values: values)),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.color, required this.values});
  final Color color;
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final span = (maxV - minV).abs() < 0.001 ? 1.0 : maxV - minV;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height - ((values[i] - minV) / span) * size.height * 0.75 - size.height * 0.12;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
    for (var i = 0; i < values.length; i += 2) {
      final x = size.width * i / (values.length - 1);
      final y = size.height - ((values[i] - minV) / span) * size.height * 0.75 - size.height * 0.12;
      canvas.drawCircle(Offset(x, y), 2.4, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => oldDelegate.color != color || oldDelegate.values != values;
}

class InfoNotice extends StatelessWidget {
  const InfoNotice({super.key, required this.text, this.color = AppColors.blue, this.icon = Icons.info_outline_rounded});
  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(height: 1.45, color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class ActionRow extends StatelessWidget {
  const ActionRow({super.key, required this.icon, required this.title, this.subtitle, this.trailing, this.onTap, this.iconColor = AppColors.brand});
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            MetricIcon(icon: icon, color: iconColor, size: 42),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: const TextStyle(fontSize: 13, height: 1.35, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class ThinDivider extends StatelessWidget {
  const ThinDivider({super.key});
  @override
  Widget build(BuildContext context) => Divider(height: 1, color: AppColors.border.withOpacity(0.75));
}

String formatTime(DateTime? value) {
  if (value == null) return '14:20';
  final local = value.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}
