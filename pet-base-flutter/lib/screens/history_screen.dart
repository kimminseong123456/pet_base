import 'package:flutter/material.dart';

import '../models/measurement_window.dart';
import '../models/health_record.dart';
import '../models/pet_status.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_base_ui.dart';
import 'status_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _api = ApiService();
  late Future<List<MeasurementWindow>> _future;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchMeasurementWindows();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _future = _api.fetchMeasurementWindows());
    await _future;
  }

  void _openDetail(MeasurementWindow item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StatusDetailScreen(record: HealthRecord.fromWindow(item)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MeasurementWindow>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.brand));
        }
        if (snapshot.hasError) {
          return _HistoryError(message: snapshot.error.toString(), onRetry: () => setState(() => _future = _api.fetchMeasurementWindows()));
        }
        final items = snapshot.data ?? const <MeasurementWindow>[];
        return RefreshIndicator(
          color: AppColors.brand,
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
            children: [
              const PetBaseHeader(),
              const SizedBox(height: 28),
              const Text('기록', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('측정 기록과 요약을 확인할 수 있어요.', style: TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 22),
              _SegmentedTabs(index: _tabIndex, onChanged: (value) => setState(() => _tabIndex = value)),
              const SizedBox(height: 18),
              _DateSelector(),
              const SizedBox(height: 18),
              if (_tabIndex == 0) ...[
                _LineChartCard(items: items),
                const SizedBox(height: 18),
                SoftCard(
                  color: const Color(0xFFF3F8FF),
                  borderColor: AppColors.blue.withOpacity(0.20),
                  child: Row(
                    children: const [
                      MetricIcon(icon: Icons.air_rounded, color: AppColors.blue, size: 58),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('최근 15분 동안 호흡수가 평소보다 높게 유지됐어요.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, height: 1.35)),
                            SizedBox(height: 5),
                            Text('충분한 휴식과 수분 섭취를 권장해요.', style: TextStyle(color: AppColors.textSecondary, height: 1.35)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _RecentList(items: items, onTap: _openDetail),
              ] else
                const _DailySummaryPlaceholder(),
            ],
          ),
        );
      },
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(8),
      radius: 20,
      child: Row(
        children: [
          Expanded(child: _SegmentButton(text: '15분 요약', active: index == 0, onTap: () => onChanged(0))),
          const SizedBox(width: 8),
          Expanded(child: _SegmentButton(text: '일간 요약', active: index == 1, onTap: () => onChanged(1))),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({required this.text, required this.active, required this.onTap});
  final String text;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.brandSoft : const Color(0xFFF5F6F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: TextStyle(color: active ? AppColors.brand : AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: const [
          Icon(Icons.chevron_left_rounded, size: 32, color: AppColors.textSecondary),
          Spacer(),
          Text('오늘', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          SizedBox(width: 14),
          Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary),
          Spacer(),
          Icon(Icons.chevron_right_rounded, size: 32, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _LineChartCard extends StatelessWidget {
  const _LineChartCard({required this.items});
  final List<MeasurementWindow> items;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('오늘 15분 요약 추이', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              SizedBox(width: 6),
              Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              _LegendDot(color: Color(0xFFFF6473), text: '심박수'),
              SizedBox(width: 10),
              _LegendDot(color: AppColors.blue, text: '호흡수'),
              SizedBox(width: 10),
              _LegendDot(color: AppColors.orange, text: '체온 추정'),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 210,
            width: double.infinity,
            child: ClipRect(child: CustomPaint(painter: _TrendChartPainter())),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.text});
  final Color color;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    const labelsY = ['160', '120', '80', '40', '0'];
    for (var i = 0; i < 5; i++) {
      final y = 8 + (size.height - 34) * i / 4;
      canvas.drawLine(Offset(44, y), Offset(size.width - 10, y), gridPaint);
      textPainter.text = TextSpan(text: labelsY[i], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary));
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }
    _drawLine(canvas, size, const Color(0xFFFF6473), [112, 104, 115, 120, 116, 111, 105, 124, 119, 125, 117, 113, 130, 122, 118, 124, 121, 126, 133]);
    _drawLine(canvas, size, AppColors.blue, [23, 26, 27, 24, 31, 25, 32, 28, 38, 35, 36, 39, 40]);
    _drawLine(canvas, size, AppColors.orange, [38.6, 38.5, 38.4, 38.5, 38.6, 38.7, 38.8, 38.8, 38.9, 39.0], min: 37, max: 41);

    final labels = ['15분 전', '10분 전', '5분 전', '현재'];
    for (var i = 0; i < labels.length; i++) {
      final x = 44 + (size.width - 64) * i / (labels.length - 1);
      textPainter.text = TextSpan(text: labels[i], style: const TextStyle(fontSize: 13, color: AppColors.textSecondary));
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - textPainter.height));
    }
  }

  void _drawLine(Canvas canvas, Size size, Color color, List<num> values, {double min = 0, double max = 160}) {
    final path = Path();
    final width = size.width - 64;
    final height = size.height - 34;
    for (var i = 0; i < values.length; i++) {
      final x = 44 + width * i / (values.length - 1);
      final y = height - ((values[i].toDouble() - min) / (max - min)) * (height - 16);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
    final dot = Paint()..color = color;
    for (var i = 0; i < values.length; i += 2) {
      final x = 44 + width * i / (values.length - 1);
      final y = height - ((values[i].toDouble() - min) / (max - min)) * (height - 16);
      canvas.drawCircle(Offset(x, y), 3.4, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RecentList extends StatelessWidget {
  const _RecentList({required this.items, required this.onTap});
  final List<MeasurementWindow> items;
  final ValueChanged<MeasurementWindow> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SoftCard(child: Text('서버에서 15분 요약 기록이 아직 내려오지 않았습니다.', style: TextStyle(color: AppColors.textSecondary)));
    }
    final visible = items.take(4).toList();
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('최근 15분 기록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ...visible.map((item) => _HistoryRow(item: item, onTap: () => onTap(item))),
          const SizedBox(height: 10),
          const Center(child: Text('ⓘ  측정불가 구간은 대시보드에서 안내됩니다.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item, required this.onTap});
  final MeasurementWindow item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.status(item.status);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.7)))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(child: Text(item.timeLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                StatusPill(status: item.status),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 19),
              child: Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _SmallValue(icon: Icons.favorite_border_rounded, text: '${_num(item.hrAvg)} bpm'),
                  _SmallValue(icon: Icons.air_rounded, text: '${_num(item.rrAvg)} 회/분'),
                  _SmallValue(icon: Icons.thermostat_outlined, text: '${_temp(item.tempEstAvg)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _num(double? value) => value == null ? '-' : value.toStringAsFixed(0);
  String _temp(double? value) => value == null ? '-' : '${value.toStringAsFixed(1)}°C';
}

class _SmallValue extends StatelessWidget {
  const _SmallValue({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: AppColors.textSecondary),
          const SizedBox(width: 3),
          Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
        ],
      );
}

class _DailySummaryPlaceholder extends StatelessWidget {
  const _DailySummaryPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const SoftCard(
      child: Text('일간 요약은 다음 단계에서 /measurements/daily/{dog_id} API와 연결합니다. 현재 MVP에서는 15분 요약 기록을 우선 표시합니다.', style: TextStyle(height: 1.5, color: AppColors.textSecondary)),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SoftCard(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.history_toggle_off_rounded, size: 46, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text('기록을 불러오지 못했습니다', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('다시 조회')),
          ]),
        ),
      ),
    );
  }
}
