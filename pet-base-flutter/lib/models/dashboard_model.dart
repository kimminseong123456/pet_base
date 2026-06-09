import 'pet_status.dart';

class DashboardModel {
  const DashboardModel({
    required this.dogId,
    required this.dogName,
    required this.finalStatus,
    required this.headline,
    required this.alertRequired,
    required this.disclaimer,
    this.breed,
    this.weightKg,
    this.baselineTempC,
    this.heartRiskMode,
    this.hrBpm,
    this.rrBpm,
    this.tempEstC,
    this.sqiPpg,
    this.sqiRr,
    this.sqiTemp,
    this.invalidReason,
    this.measuredAt,
    this.deviceId,
    this.batteryPct,
    this.redFlag = false,
  });

  final int dogId;
  final String dogName;
  final String? breed;
  final double? weightKg;
  final double? baselineTempC;
  final bool? heartRiskMode;
  final PetStatus finalStatus;
  final String headline;
  final int? hrBpm;
  final int? rrBpm;
  final double? tempEstC;
  final double? sqiPpg;
  final double? sqiRr;
  final double? sqiTemp;
  final String? invalidReason;
  final DateTime? measuredAt;
  final String? deviceId;
  final int? batteryPct;
  final bool alertRequired;
  final bool redFlag;
  final String disclaimer;

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final status = petStatusFromApi(_string(json['final_status'] ?? json['finalStatus'] ?? json['status']));
    return DashboardModel(
      dogId: _int(json['dog_id'] ?? json['dogId']) ?? 0,
      dogName: _string(json['dog_name'] ?? json['dogName'] ?? json['name']) ?? '보리',
      breed: _string(json['breed']) ?? '말티즈',
      weightKg: _double(json['weight_kg'] ?? json['weightKg']) ?? 4.2,
      baselineTempC: _double(json['baseline_temp_c'] ?? json['baselineTempC']),
      heartRiskMode: _bool(json['heart_risk_mode'] ?? json['heartRiskMode']),
      finalStatus: status,
      headline: _string(json['headline']) ?? petStatusHeadline(status),
      hrBpm: _int(json['hr_bpm'] ?? json['hrBpm']),
      rrBpm: _int(json['rr_bpm'] ?? json['rrBpm']),
      tempEstC: _double(json['temp_est_c'] ?? json['tempEstC']),
      sqiPpg: _double(json['sqi_ppg'] ?? json['sqiPpg']),
      sqiRr: _double(json['sqi_rr'] ?? json['sqiRr']),
      sqiTemp: _double(json['sqi_temp'] ?? json['sqiTemp']),
      invalidReason: _string(json['invalid_reason'] ?? json['invalidReason']),
      measuredAt: _date(json['measured_at'] ?? json['measuredAt']),
      deviceId: _string(json['device_id'] ?? json['deviceId']) ?? 'dog-001',
      batteryPct: _int(json['battery_pct'] ?? json['batteryPct']),
      alertRequired: _bool(json['alert_required'] ?? json['alertRequired']) ?? petStatusIsCritical(status),
      redFlag: _bool(json['red_flag'] ?? json['redFlag']) ?? false,
      disclaimer: _string(json['disclaimer']) ?? '본 결과는 웨어러블 생체신호 기반의 추정 안내이며 진단이 아닙니다.',
    );
  }

  static DashboardModel demo({PetStatus status = PetStatus.normal}) {
    return DashboardModel(
      dogId: 1,
      dogName: '보리',
      breed: '말티즈',
      weightKg: 4.2,
      baselineTempC: 38.1,
      finalStatus: status,
      headline: petStatusHeadline(status),
      alertRequired: petStatusIsCritical(status),
      disclaimer: '본 결과는 웨어러블 생체신호 기반의 추정 안내이며 진단이 아닙니다.',
      hrBpm: status == PetStatus.danger ? 164 : 118,
      rrBpm: status == PetStatus.danger ? 42 : 24,
      tempEstC: status == PetStatus.danger ? 39.8 : 38.4,
      sqiPpg: 0.91,
      sqiRr: 0.88,
      sqiTemp: 0.79,
      deviceId: 'dog-001',
      batteryPct: 82,
      invalidReason: status == PetStatus.invalid ? 'no_contact' : null,
      measuredAt: DateTime.now(),
    );
  }

  double? get sqiAverage {
    final values = [sqiPpg, sqiRr, sqiTemp].whereType<double>().toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  String get measuredAtLabel {
    final value = measuredAt;
    if (value == null) return '측정 시간 미제공';
    return '${_two(value.hour)}:${_two(value.minute)}';
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
