class PetDevice {
  const PetDevice({
    required this.deviceId,
    required this.model,
    required this.firmwareVersion,
    required this.batteryPct,
    required this.lastSeenAt,
    required this.isActive,
    this.sqiPpg,
    this.sqiRr,
    this.sqiTemp,
  });

  final String deviceId;
  final String model;
  final String firmwareVersion;
  final int? batteryPct;
  final DateTime? lastSeenAt;
  final bool isActive;
  final double? sqiPpg;
  final double? sqiRr;
  final double? sqiTemp;

  factory PetDevice.fromJson(Map<String, dynamic> json) {
    return PetDevice(
      deviceId: _string(json['device_id'] ?? json['deviceId']) ?? 'dog-001',
      model: _string(json['model']) ?? 'PET BASE Harness',
      firmwareVersion: _string(json['firmware_version'] ?? json['firmwareVersion']) ?? 'sim-0.1.0',
      batteryPct: _int(json['last_battery_pct'] ?? json['battery_pct'] ?? json['batteryPct']),
      lastSeenAt: _date(json['last_seen_at'] ?? json['lastSeenAt'] ?? json['measured_at']),
      isActive: _bool(json['is_active'] ?? json['isActive']) ?? true,
      sqiPpg: _double(json['sqi_ppg'] ?? json['sqiPpg']),
      sqiRr: _double(json['sqi_rr'] ?? json['sqiRr']),
      sqiTemp: _double(json['sqi_temp'] ?? json['sqiTemp']),
    );
  }

  static PetDevice demo() => PetDevice(
        deviceId: 'dog-001',
        model: 'PET BASE Harness',
        firmwareVersion: 'sim-0.1.0',
        batteryPct: 82,
        lastSeenAt: DateTime.now(),
        isActive: true,
        sqiPpg: 0.91,
        sqiRr: 0.88,
        sqiTemp: 0.79,
      );

  String get lastSeenLabel {
    final value = lastSeenAt;
    if (value == null) return '수신 시간 미제공';
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
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
