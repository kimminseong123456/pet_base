import 'dart:async';

import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/dashboard_model.dart';
import '../models/pet_status.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_base_ui.dart';
import 'emergency_guide_screen.dart';
import 'invalid_detail_screen.dart';
import 'status_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();
  Future<DashboardModel>? _future;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _timer = Timer.periodic(ApiConfig.dashboardRefreshInterval, (_) {
      if (mounted) setState(() => _future = _load());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _api.close();
    super.dispose();
  }

  Future<DashboardModel> _load() => _api.fetchDashboard();

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  void _openStatusDetail(DashboardModel data) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StatusDetailScreen.fromDashboard(data)),
    );
  }

  void _openInvalidDetail(DashboardModel data) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => InvalidDetailScreen.fromDashboard(data)),
    );
  }

  void _openEmergencyGuide() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EmergencyGuideScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardModel>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.brand));
        }
        if (snapshot.hasError) {
          return _ErrorState(message: snapshot.error.toString(), onRetry: () => setState(() => _future = _load()));
        }
        final data = snapshot.data;
        if (data == null) {
          return _ErrorState(message: '서버 대시보드 데이터가 없습니다.', onRetry: () => setState(() => _future = _load()));
        }

        final status = data.finalStatus;
        return RefreshIndicator(
          color: AppColors.brand,
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
            children: [
              const PetBaseHeader(),
              const SizedBox(height: 24),
              _DogHeader(data: data),
              if (data.alertRequired || status.isCritical) ...[
                const SizedBox(height: 18),
                _WarningBanner(onTap: status == PetStatus.emergency ? _openEmergencyGuide : () => _openStatusDetail(data)),
              ],
              const SizedBox(height: 18),
              if (status.isInvalid)
                _InvalidHero(data: data, onTap: () => _openInvalidDetail(data))
              else
                _StatusHero(data: data, onTap: () => _openStatusDetail(data)),
              const SizedBox(height: 18),
              _VitalsGrid(data: data),
              const SizedBox(height: 18),
              _DeviceSummary(data: data),
              const SizedBox(height: 18),
              _ActionGuide(status: status, onTap: status.isCritical ? _openEmergencyGuide : () => _openStatusDetail(data)),
              const SizedBox(height: 18),
              InfoNotice(
                icon: Icons.info_outline_rounded,
                color: AppColors.orange,
                text: data.disclaimer.isEmpty ? '본 결과는 웨어러블 생체신호 기반의 추정 안내이며 진단이 아닙니다.' : data.disclaimer,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DogHeader extends StatelessWidget {
  const _DogHeader({required this.data});
  final DashboardModel data;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.brandSoft,
            borderRadius: BorderRadius.circular(18),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=200'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.dogName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(_profileLine(data), style: const TextStyle(fontSize: 17, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFFF4F5F7), borderRadius: BorderRadius.circular(16)),
          child: Text('마지막 측정 ${formatTime(data.measuredAt)}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ),
      ],
    );
  }

  String _profileLine(DashboardModel d) {
    final parts = <String>[];
    if ((d.breed ?? '').trim().isNotEmpty) parts.add(d.breed!.trim());
    if (d.weightKg != null) parts.add('${d.weightKg!.toStringAsFixed(1)}kg');
    if (parts.isEmpty) return '프로필 정보 미제공';
    return parts.join(' · ');
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      color: AppColors.statusSoft(PetStatus.danger),
      borderColor: AppColors.danger.withOpacity(0.28),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Text('경고 배너 · 빠른 확인이 필요한 상태예요', style: TextStyle(color: AppColors.danger, fontSize: 17, fontWeight: FontWeight.w900)),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 30),
        ],
      ),
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.data, required this.onTap});
  final DashboardModel data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = data.finalStatus;
    final color = AppColors.status(status);
    return SoftCard(
      onTap: onTap,
      color: AppColors.statusSoft(status).withOpacity(0.72),
      borderColor: color.withOpacity(0.26),
      padding: const EdgeInsets.all(26),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(color: color.withOpacity(0.10), shape: BoxShape.circle),
            child: Center(
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(color: color.withOpacity(0.95), shape: BoxShape.circle),
                child: Icon(_statusIcon(status), color: Colors.white, size: 46),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.75), borderRadius: BorderRadius.circular(999)),
                  child: const Text('현재 상태', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 12),
                Text(status.title, style: TextStyle(color: color, fontSize: 42, fontWeight: FontWeight.w900, height: 1)),
                const SizedBox(height: 8),
                Text(status.headline, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text(status.helperText, style: const TextStyle(fontSize: 15, height: 1.45, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InvalidHero extends StatelessWidget {
  const _InvalidHero({required this.data, required this.onTap});
  final DashboardModel data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      color: AppColors.statusSoft(PetStatus.invalid),
      borderColor: AppColors.invalid.withOpacity(0.24),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const MetricIcon(icon: Icons.sensors_off_rounded, color: AppColors.invalid, size: 96),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusPill(status: PetStatus.invalid, text: '측정 상태 안내'),
                const SizedBox(height: 12),
                const Text('지금은 정확히 측정하기 어려워요', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: AppColors.invalid)),
                const SizedBox(height: 8),
                Text(_invalidMessage(data.invalidReason), style: const TextStyle(fontSize: 15, height: 1.45, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _VitalsGrid extends StatelessWidget {
  const _VitalsGrid({required this.data});
  final DashboardModel data;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 0.92,
      children: [
        _VitalCard(icon: Icons.favorite_rounded, color: AppColors.danger, title: '심박수', value: data.hrBpm?.toString() ?? '-', unit: 'bpm'),
        _VitalCard(icon: Icons.air_rounded, color: AppColors.blue, title: '호흡수', value: data.rrBpm?.toString() ?? '-', unit: '회/분'),
        _VitalCard(icon: Icons.thermostat_rounded, color: AppColors.orange, title: '체온 추정', value: data.tempEstC == null ? '-' : data.tempEstC!.toStringAsFixed(1), unit: '°C'),
        _VitalCard(icon: Icons.signal_cellular_alt_rounded, color: AppColors.brand, title: 'SQI', value: data.sqiAverage == null ? '-' : data.sqiAverage!.toStringAsFixed(2), unit: '', caption: _qualityLabel(data.sqiAverage)),
      ],
    );
  }

  String _qualityLabel(double? sqi) {
    if (sqi == null) return '측정 품질 미제공';
    if (sqi >= 0.80) return '측정 품질 양호';
    if (sqi >= 0.60) return '측정 품질 보통';
    return '측정 품질 낮음';
  }
}

class _VitalCard extends StatelessWidget {
  const _VitalCard({required this.icon, required this.color, required this.title, required this.value, required this.unit, this.caption});
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String unit;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              MetricIcon(icon: icon, color: color, size: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 32, height: 0.95, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (caption == null)
            SizedBox(height: 26, width: double.infinity, child: Sparkline(color: color))
          else
            Text(caption!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _DeviceSummary extends StatelessWidget {
  const _DeviceSummary({required this.data});
  final DashboardModel data;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(child: _MiniSummary(icon: Icons.watch_rounded, label: '기기 연결', value: data.deviceId == null ? '미제공' : '정상')),
          Container(width: 1, height: 42, color: AppColors.border),
          Expanded(child: _MiniSummary(icon: Icons.battery_5_bar_rounded, label: '배터리', value: data.batteryPct == null ? '-' : '${data.batteryPct}%')),
          Container(width: 1, height: 42, color: AppColors.border),
          Expanded(child: _MiniSummary(icon: Icons.check_rounded, label: '측정 가능 상태', value: data.finalStatus.isInvalid ? '점검' : '양호')),
        ],
      ),
    );
  }
}

class _MiniSummary extends StatelessWidget {
  const _MiniSummary({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MetricIcon(icon: icon, color: AppColors.brand, size: 42),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontSize: 17, color: AppColors.brand, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _ActionGuide extends StatelessWidget {
  const _ActionGuide({required this.status, required this.onTap});
  final PetStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final items = status.isCritical
        ? ['보리를 조용하고 편안한 환경에서 안정시키기', '10~30분 후 다시 측정하여 상태 변화 확인', '호흡이 더 힘들거나 상태가 악화되면 병원으로 이동']
        : status.isInvalid
            ? ['하네스와 센서 밀착 상태 확인', '강아지가 안정된 자세인지 확인', '1분 뒤 다시 측정']
            : ['평소 관리 루틴 유지', '다음 15분 요약 기록 확인', '환경과 자세가 안정적인지 확인'];
    return SoftCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_turned_in_rounded, color: AppColors.brand, size: 28),
              SizedBox(width: 10),
              Text('지금 할 일', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.brand, size: 22),
                    const SizedBox(width: 12),
                    Expanded(child: Text(e, style: const TextStyle(fontSize: 15, height: 1.35, color: AppColors.textPrimary))),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SoftCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 46, color: AppColors.textSecondary),
              const SizedBox(height: 14),
              const Text('대시보드 데이터를 불러오지 못했습니다', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('다시 조회')),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _statusIcon(PetStatus status) {
  switch (status) {
    case PetStatus.normal:
      return Icons.shield_rounded;
    case PetStatus.interest:
      return Icons.favorite_border_rounded;
    case PetStatus.caution:
      return Icons.warning_amber_rounded;
    case PetStatus.danger:
      return Icons.notification_important_rounded;
    case PetStatus.emergency:
      return Icons.warning_rounded;
    case PetStatus.invalid:
      return Icons.sensors_off_rounded;
  }
}

String _invalidMessage(String? reason) {
  switch (reason) {
    case 'motion':
      return '강아지가 움직이고 있어요. 안정된 자세에서 다시 확인해 주세요.';
    case 'no_contact':
      return '센서 밀착이 부족할 수 있어요. 착용 위치를 먼저 확인해 주세요.';
    case 'unstable':
      return '센서가 흔들리거나 값이 불안정해요. 착용 상태를 점검해 주세요.';
    case 'jump':
      return '측정값이 급변했어요. 30초 후 다시 측정해 주세요.';
    case 'sensor_error':
      return '센서 또는 전송 오류가 의심돼요. 기기 상태를 확인해 주세요.';
    default:
      return '움직임, 밀착, 품질 문제일 수 있으니 착용을 점검한 뒤 다시 측정해 주세요.';
  }
}
