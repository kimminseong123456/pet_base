import 'pet_status.dart';

class MeasurementWindow {
  const MeasurementWindow({
    required this.status,
    this.recordId,
    this.windowStart,
    this.windowEnd,
    this.hrAvg,
    this.rrAvg,
    this.tempEstAvg,
    this.sqiAvg,
    this.validRatio,
    this.invalidReason,
  });

  final int? recordId;
  final PetStatus status;
  final DateTime? windowStart;
  final DateTime? windowEnd;
  final double? hrAvg;
  final double? rrAvg;
  final double? tempEstAvg;
  final double? sqiAvg;
  final double? validRatio;
  final String? invalidReason;

  factory MeasurementWindow.fromJson(Map<String, dynamic> json) {
    return MeasurementWindow(
      recordId: _int(json['record_id'] ?? json['recordId'] ?? json['id']),
      status: petStatusFromApi(_string(json['final_status'] ?? json['status'])),
      windowStart: _date(json['window_start'] ?? json['start_at'] ?? json['measured_at']),
      windowEnd: _date(json['window_end'] ?? json['end_at']),
      hrAvg: _double(json['hr_avg'] ?? json['avg_hr_bpm'] ?? json['hr_bpm']),
      rrAvg: _double(json['rr_avg'] ?? json['avg_rr_bpm'] ?? json['rr_bpm']),
      tempEstAvg: _double(json['temp_est_avg'] ?? json['avg_temp_est_c'] ?? json['temp_est_c']),
      sqiAvg: _double(json['sqi_avg'] ?? json['avg_sqi']),
      validRatio: _double(json['valid_ratio'] ?? json['validRatio']),
      invalidReason: _string(json['invalid_reason'] ?? json['invalidReason']),
    );
  }

  static List<MeasurementWindow> demoList() {
    final now = DateTime.now();
    return [
      MeasurementWindow(status: PetStatus.danger, windowStart: now.subtract(const Duration(minutes: 15)), windowEnd: now, hrAvg: 164, rrAvg: 42, tempEstAvg: 39.8, sqiAvg: 0.86),
      MeasurementWindow(status: PetStatus.caution, windowStart: now.subtract(const Duration(minutes: 30)), windowEnd: now.subtract(const Duration(minutes: 15)), hrAvg: 138, rrAvg: 32, tempEstAvg: 38.9, sqiAvg: 0.74),
      MeasurementWindow(status: PetStatus.interest, windowStart: now.subtract(const Duration(minutes: 45)), windowEnd: now.subtract(const Duration(minutes: 30)), hrAvg: 128, rrAvg: 29, tempEstAvg: 38.6, sqiAvg: 0.82),
      MeasurementWindow(status: PetStatus.normal, windowStart: now.subtract(const Duration(minutes: 60)), windowEnd: now.subtract(const Duration(minutes: 45)), hrAvg: 118, rrAvg: 24, tempEstAvg: 38.4, sqiAvg: 0.88),
    ];
  }

  String get timeLabel {
    if (windowStart == null) return '시간 미제공';
    return '${_two(windowStart!.hour)}:${_two(windowStart!.minute)}';
  }

  String get rangeLabel {
    if (windowStart == null || windowEnd == null) return timeLabel;
    return '${_two(windowStart!.hour)}:${_two(windowStart!.minute)} - ${_two(windowEnd!.hour)}:${_two(windowEnd!.minute)}';
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
DateTime? _date(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}
