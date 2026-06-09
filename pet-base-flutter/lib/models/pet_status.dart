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
      return '\uC815\uC0C1';
    case PetStatus.interest:
      return '\uAD00\uC2EC';
    case PetStatus.caution:
      return '\uC8FC\uC758';
    case PetStatus.danger:
      return '\uC704\uD5D8';
    case PetStatus.emergency:
      return '\uC751\uAE09';
    case PetStatus.invalid:
      return '\uCE21\uC815\uBD88\uAC00';
  }
}

String petStatusHeadline(PetStatus status) {
  switch (status) {
    case PetStatus.normal:
      return '\uC6B0\uB9AC \uC544\uC774\uB294 \uC9C0\uAE08 \uC548\uC815\uC801\uC774\uC5D0\uC694';
    case PetStatus.interest:
      return '\uAC00\uBCBC\uC6B4 \uBCC0\uD654\uAC00 \uBCF4\uC5EC\uC694';
    case PetStatus.caution:
      return '\uC870\uAE08 \uB354 \uC138\uC2EC\uD55C \uAD00\uCC30\uC774 \uD544\uC694\uD574\uC694';
    case PetStatus.danger:
      return '\uBE60\uB978 \uD655\uC778\uC774 \uD544\uC694\uD574\uC694';
    case PetStatus.emergency:
      return '\uC9C0\uAE08\uC740 \uC989\uC2DC \uB300\uC751\uC774 \uD544\uC694\uD574\uC694';
    case PetStatus.invalid:
      return '\uC9C0\uAE08\uC740 \uC815\uD655\uD788 \uCE21\uC815\uD558\uAE30 \uC5B4\uB824\uC6CC\uC694';
  }
}

String petStatusHelper(PetStatus status) {
  switch (status) {
    case PetStatus.normal:
      return '\uD3C9\uC18C \uAD00\uB9AC \uB8E8\uD2F4\uC744 \uC774\uC5B4\uAC00 \uC8FC\uC138\uC694.';
    case PetStatus.interest:
      return '\uD658\uACBD\uACFC \uC790\uC138\uB97C \uC815\uB3C8\uD55C \uB4A4 \uB2E4\uC74C \uAE30\uB85D\uC744 \uD655\uC778\uD574 \uC8FC\uC138\uC694.';
    case PetStatus.caution:
      return '\uC548\uC815 \uD6C4 \uB2E4\uC2DC \uD655\uC778\uD558\uACE0 \uBC18\uBCF5\uB418\uBA74 \uC0C1\uB2F4\uC744 \uAD8C\uC7A5\uD569\uB2C8\uB2E4.';
    case PetStatus.danger:
      return '\uC989\uC2DC \uC548\uC815\uC2DC\uD0A4\uACE0 \uAC00\uAE4C\uC6B4 \uBCD1\uC6D0 \uBC29\uBB38 \uC5EC\uBD80\uB97C \uD655\uC778\uD574 \uC8FC\uC138\uC694.';
    case PetStatus.emergency:
      return '\uD638\uD761\uACE4\uB780, \uC2E4\uC2E0, \uC758\uC2DD\uC800\uD558\uAC00 \uC788\uC73C\uBA74 \uC9C0\uCCB4\uD558\uC9C0 \uB9D0\uACE0 \uC774\uB3D9\uD558\uC138\uC694.';
    case PetStatus.invalid:
      return '\uC6C0\uC9C1\uC784, \uBC00\uCC29, \uC2E0\uD638 \uD488\uC9C8 \uBB38\uC81C\uC77C \uC218 \uC788\uC5B4 \uCC29\uC6A9 \uC0C1\uD0DC\uB97C \uC810\uAC80\uD574 \uC8FC\uC138\uC694.';
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
