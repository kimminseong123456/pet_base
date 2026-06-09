enum PetStatus {
  normal,
  interest,
  caution,
  danger,
  emergency,
  invalid,
}

PetStatus petStatusFromApi(String value) {
  switch (value) {
    case 'NORMAL':
      return PetStatus.normal;
    case 'INTEREST':
      return PetStatus.interest;
    case 'CAUTION':
      return PetStatus.caution;
    case 'DANGER':
      return PetStatus.danger;
    case 'EMERGENCY':
      return PetStatus.emergency;
    case 'INVALID':
      return PetStatus.invalid;
    default:
      return PetStatus.invalid;
  }
}

String petStatusApiCode(PetStatus status) {
  switch (status) {
    case PetStatus.normal:
      return 'NORMAL';
    case PetStatus.interest:
      return 'INTEREST';
    case PetStatus.caution:
      return 'CAUTION';
    case PetStatus.danger:
      return 'DANGER';
    case PetStatus.emergency:
      return 'EMERGENCY';
    case PetStatus.invalid:
      return 'INVALID';
  }
}

String petStatusTitle(PetStatus status) {
  switch (status) {
    case PetStatus.normal:
      return '정상';
    case PetStatus.interest:
      return '관심';
    case PetStatus.caution:
      return '주의';
    case PetStatus.danger:
      return '위험';
    case PetStatus.emergency:
      return '응급';
    case PetStatus.invalid:
      return '측정불가';
  }
}

class DashboardData {
  final int dogId;
  final String dogName;
  final PetStatus finalStatus;
  final String headline;
  final String message;
  final int? hrBpm;
  final int? rrBpm;
  final double? tempEstC;
  final double? sqiPpg;
  final double? sqiRr;
  final double? sqiTemp;
  final String? invalidReason;
  final DateTime? measuredAt;
  final bool alertRequired;
  final String disclaimer;

  const DashboardData({
    required this.dogId,
    required this.dogName,
    required this.finalStatus,
    required this.headline,
    required this.message,
    required this.hrBpm,
    required this.rrBpm,
    required this.tempEstC,
    required this.sqiPpg,
    required this.sqiRr,
    required this.sqiTemp,
    required this.invalidReason,
    required this.measuredAt,
    required this.alertRequired,
    required this.disclaimer,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      dogId: json['dog_id'] as int,
      dogName: json['dog_name'] as String,
      finalStatus: petStatusFromApi(json['final_status'] as String),
      headline: json['headline'] as String,
      message: json['message'] as String,
      hrBpm: json['hr_bpm'] as int?,
      rrBpm: json['rr_bpm'] as int?,
      tempEstC: (json['temp_est_c'] as num?)?.toDouble(),
      sqiPpg: (json['sqi_ppg'] as num?)?.toDouble(),
      sqiRr: (json['sqi_rr'] as num?)?.toDouble(),
      sqiTemp: (json['sqi_temp'] as num?)?.toDouble(),
      invalidReason: json['invalid_reason'] as String?,
      measuredAt: json['measured_at'] == null
          ? null
          : DateTime.parse(json['measured_at'] as String),
      alertRequired: json['alert_required'] as bool? ?? false,
      disclaimer: json['disclaimer'] as String? ??
          '본 결과는 웨어러블 생체신호 기반의 추정 안내이며 진단이 아닙니다.',
    );
  }
}
