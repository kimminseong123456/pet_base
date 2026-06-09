import 'dashboard.dart';

class MeasurementWindow {
  final int windowId;
  final int dogId;
  final DateTime windowStart;
  final DateTime windowEnd;
  final int totalSamples;
  final int validSamples;
  final double validRatio;
  final double? avgHrBpm;
  final double? avgRrBpm;
  final double? avgTempEstC;
  final double? avgScore;
  final PetStatus finalStatus;
  final bool alertRequired;

  const MeasurementWindow({
    required this.windowId,
    required this.dogId,
    required this.windowStart,
    required this.windowEnd,
    required this.totalSamples,
    required this.validSamples,
    required this.validRatio,
    required this.avgHrBpm,
    required this.avgRrBpm,
    required this.avgTempEstC,
    required this.avgScore,
    required this.finalStatus,
    required this.alertRequired,
  });

  factory MeasurementWindow.fromJson(Map<String, dynamic> json) {
    return MeasurementWindow(
      windowId: json['window_id'] as int,
      dogId: json['dog_id'] as int,
      windowStart: DateTime.parse(json['window_start'] as String),
      windowEnd: DateTime.parse(json['window_end'] as String),
      totalSamples: json['total_samples'] as int,
      validSamples: json['valid_samples'] as int,
      validRatio: (json['valid_ratio'] as num).toDouble(),
      avgHrBpm: (json['avg_hr_bpm'] as num?)?.toDouble(),
      avgRrBpm: (json['avg_rr_bpm'] as num?)?.toDouble(),
      avgTempEstC: (json['avg_temp_est_c'] as num?)?.toDouble(),
      avgScore: (json['avg_score'] as num?)?.toDouble(),
      finalStatus: petStatusFromApi(json['final_status'] as String),
      alertRequired: json['alert_required'] as bool? ?? false,
    );
  }
}
