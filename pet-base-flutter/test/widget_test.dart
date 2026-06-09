import 'package:flutter_test/flutter_test.dart';

import 'package:pet_base_flutter/models/pet_status.dart';

void main() {
  test('pet status labels are readable Korean copy', () {
    expect(petStatusTitle(PetStatus.normal), '\uC815\uC0C1');
    expect(petStatusTitle(PetStatus.caution), '\uC8FC\uC758');
    expect(petStatusTitle(PetStatus.invalid), '\uCE21\uC815\uBD88\uAC00');
    expect(petStatusHeadline(PetStatus.danger), '\uBE60\uB978 \uD655\uC778\uC774 \uD544\uC694\uD574\uC694');
  });
}
