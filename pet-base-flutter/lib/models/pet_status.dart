enum PetStatus {
  normal,
  interest,
  caution,
  danger,
  emergency,
  invalid,
}

PetStatus petStatusFromApi(String? value) {
  switch ((value ?? '').toUpperCase()) {
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

String petStatusHeadline(PetStatus status) {
  switch (status) {
    case PetStatus.normal:
      return '우리 아이는 지금 안정적이에요';
    case PetStatus.interest:
      return '가벼운 변화가 보여요';
    case PetStatus.caution:
      return '조금 더 세심한 관찰이 필요해요';
    case PetStatus.danger:
      return '빠른 확인이 필요해요';
    case PetStatus.emergency:
      return '지금은 즉시 대응이 필요해요';
    case PetStatus.invalid:
      return '지금은 정확히 측정하기 어려워요';
  }
}

String petStatusHelper(PetStatus status) {
  switch (status) {
    case PetStatus.normal:
      return '평소 관리 루틴을 유지해 주세요.';
    case PetStatus.interest:
      return '환경과 자세를 정돈한 뒤 다음 기록을 확인해 주세요.';
    case PetStatus.caution:
      return '안정 후 다시 확인하고 반복되면 상담을 권장합니다.';
    case PetStatus.danger:
      return '즉시 안정시키고 가까운 병원 방문 여부를 확인해 주세요.';
    case PetStatus.emergency:
      return '호흡곤란, 실신, 의식저하가 있으면 지체하지 말고 이동하세요.';
    case PetStatus.invalid:
      return '움직임, 밀착, 품질 문제일 수 있으니 착용을 점검한 뒤 다시 측정해 주세요.';
  }
}

bool petStatusIsCritical(PetStatus status) {
  return status == PetStatus.danger || status == PetStatus.emergency;
}

bool petStatusIsInvalid(PetStatus status) => status == PetStatus.invalid;

extension PetStatusCompat on PetStatus {
  String get apiCode => petStatusApiCode(this);
  String get title => petStatusTitle(this);
  String get headline => petStatusHeadline(this);
  String get helperText => petStatusHelper(this);
  bool get isCritical => petStatusIsCritical(this);
  bool get isInvalid => petStatusIsInvalid(this);
}

extension PetStatusX on PetStatus {
  static PetStatus fromApi(String? value) => petStatusFromApi(value);
}
