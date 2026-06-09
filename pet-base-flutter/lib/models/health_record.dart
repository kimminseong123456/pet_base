import 'dashboard_model.dart';
import 'measurement_window.dart';
import 'pet_status.dart';

class HealthRecord {
  const HealthRecord({
    this.recordId,
    required this.dogId,
    required this.dogName,
    required this.status,
    this.measuredAt,
    this.windowStart,
    this.windowEnd,
    this.hrBpm,
    this.rrBpm,
    this.tempEstC,
    this.sqiPpg,
    this.sqiRr,
    this.sqiTemp,
    this.invalidReason,
    this.tScore,
    this.pScore,
    this.rScore,
    this.avgScore,
    this.redFlag = false,
  });

  final int? recordId;
  final int dogId;
  final String dogName;
  final PetStatus status;
  final DateTime? measuredAt;
  final DateTime? windowStart;
  final DateTime? windowEnd;
  final int? hrBpm;
  final int? rrBpm;
  final double? tempEstC;
  final double? sqiPpg;
  final double? sqiRr;
  final double? sqiTemp;
  final String? invalidReason;
  final int? tScore;
  final int? pScore;
  final int? rScore;
  final double? avgScore;
  final bool redFlag;

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      recordId: _int(json['record_id'] ?? json['recordId'] ?? json['id']),
      dogId: _int(json['dog_id'] ?? json['dogId']) ?? 0,
      dogName: _string(json['dog_name'] ?? json['dogName']) ?? '보리',
      status: petStatusFromApi(_string(json['final_status'] ?? json['status'])),
      measuredAt: _date(json['measured_at'] ?? json['measuredAt']),
      windowStart: _date(json['window_start'] ?? json['windowStart']),
      windowEnd: _date(json['window_end'] ?? json['windowEnd']),
      hrBpm: _int(json['hr_bpm'] ?? json['hrBpm']),
      rrBpm: _int(json['rr_bpm'] ?? json['rrBpm']),
      tempEstC: _double(json['temp_est_c'] ?? json['tempEstC']),
      sqiPpg: _double(json['sqi_ppg'] ?? json['sqiPpg']),
      sqiRr: _double(json['sqi_rr'] ?? json['sqiRr']),
      sqiTemp: _double(json['sqi_temp'] ?? json['sqiTemp']),
      invalidReason: _string(json['invalid_reason'] ?? json['invalidReason']),
      tScore: _int(json['t_score'] ?? json['tScore']),
      pScore: _int(json['p_score'] ?? json['pScore']),
      rScore: _int(json['r_score'] ?? json['rScore']),
      avgScore: _double(json['avg_score'] ?? json['avgScore']),
      redFlag: _bool(json['red_flag'] ?? json['redFlag']) ?? false,
    );
  }

  factory HealthRecord.fromDashboard(DashboardModel data) {
    return HealthRecord(
      dogId: data.dogId,
      dogName: data.dogName,
      status: data.finalStatus,
      measuredAt: data.measuredAt,
      hrBpm: data.hrBpm,
      rrBpm: data.rrBpm,
      tempEstC: data.tempEstC,
      sqiPpg: data.sqiPpg,
      sqiRr: data.sqiRr,
      sqiTemp: data.sqiTemp,
      invalidReason: data.invalidReason,
      redFlag: data.redFlag,
    );
  }

  factory HealthRecord.fromWindow(MeasurementWindow item) {
    return HealthRecord(
      recordId: item.recordId,
      dogId: 1,
      dogName: '보리',
      status: item.status,
      windowStart: item.windowStart,
      windowEnd: item.windowEnd,
      hrBpm: item.hrAvg?.round(),
      rrBpm: item.rrAvg?.round(),
      tempEstC: item.tempEstAvg,
      sqiPpg: item.sqiAvg,
      sqiRr: item.sqiAvg,
      sqiTemp: item.sqiAvg,
      invalidReason: item.invalidReason,
    );
  }

  double? get sqiAverage {
    final values = [sqiPpg, sqiRr, sqiTemp].whereType<double>().toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  String get timeRangeLabel {
    final start = windowStart ?? measuredAt;
    final end = windowEnd;
    if (start == null) return '시간 미제공';
    if (end == null) return '${_two(start.hour)}:${_two(start.minute)}';
    return '${_two(start.hour)}:${_two(start.minute)} - ${_two(end.hour)}:${_two(end.minute)}';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}

String? _string(dynamic value) => value == null ? null : value.toString();
int? _int(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
double? _double(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
bool? _bool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  final text = value.toString().toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return null;
}
DateTime? _date(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}
