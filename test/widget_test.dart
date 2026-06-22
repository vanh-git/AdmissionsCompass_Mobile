import 'package:flutter_test/flutter_test.dart';

import 'package:addmissioncompass_mobile/data/riasec_careers.dart';
import 'package:addmissioncompass_mobile/data/riasec_questions.dart';
import 'package:addmissioncompass_mobile/models/chat_message.dart';

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

  test('career suggestions include Holland code and combo mapping', () {
    final suggestions = getCareerSuggestions([
      RIASECType.I,
      RIASECType.A,
      RIASECType.S,
    ]);

    expect(suggestions.code, 'IAS');
    expect(suggestions.primary.majors, contains('Công nghệ thông tin'));
    expect(suggestions.combo, isNotNull);
    expect(suggestions.combo!.majors, contains('UX Research'));
  });

  test('all ordered two-type combinations have career suggestions', () {
    for (final first in RIASECType.values) {
      for (final second in RIASECType.values) {
        if (first == second) continue;
        expect(
          comboTypeCareers['${first.name}${second.name}'],
          isNotNull,
          reason: 'Missing ${first.name}${second.name}',
        );
      }
    }
  });

  test('chat initials use at most two words', () {
    expect(getInitials('Nguyễn Văn An'), 'NV');
    expect(getInitials('Minh'), 'M');
    expect(getInitials(''), '?');
  });

  test('chat time displays time today and date for older messages', () {
    final now = DateTime(2026, 6, 22, 15, 30);

    expect(formatChatTime(DateTime(2026, 6, 22, 9, 5), now: now), '09:05');
    expect(
      formatChatTime(DateTime(2026, 6, 21, 9, 5), now: now),
      '21/06 09:05',
    );
  });
}
