import 'package:flutter_test/flutter_test.dart';

import 'package:addmissioncompass_mobile/data/riasec_questions.dart';
import 'package:addmissioncompass_mobile/screens/riasec_test_screen.dart';

void main() {
  test('calculateScores groups answers by RIASEC type', () {
    final answers = {
      riasecQuestions
              .firstWhere((question) => question.type == RIASECType.R)
              .id:
          4,
      riasecQuestions
              .firstWhere((question) => question.type == RIASECType.I)
              .id:
          3,
      riasecQuestions
              .firstWhere((question) => question.type == RIASECType.A)
              .id:
          2,
    };

    final scores = calculateScores(answers);

    expect(scores[RIASECType.R], 4);
    expect(scores[RIASECType.I], 3);
    expect(scores[RIASECType.A], 2);
    expect(scores[RIASECType.S], 0);
  });

  test('getTopTypes returns the three highest scores', () {
    final topTypes = getTopTypes({
      RIASECType.R: 5,
      RIASECType.I: 20,
      RIASECType.A: 10,
      RIASECType.S: 15,
      RIASECType.E: 1,
      RIASECType.C: 3,
    });

    expect(topTypes, [RIASECType.I, RIASECType.S, RIASECType.A]);
  });
}
