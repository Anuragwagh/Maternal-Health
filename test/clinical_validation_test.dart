import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:maternalhealth_app/core/services/risk_engine.dart';

void main() {
  group('Clinical Validation Suite (32 Synthetic Patient Cases)', () {
    late List<Map<String, dynamic>> testCases;

    setUpAll(() async {
      final file = File('test/test_cases/risk_cases.json');
      final jsonStr = await file.readAsString();
      final decoded = json.decode(jsonStr) as List;
      testCases = decoded.cast<Map<String, dynamic>>();
    });

    test('All 32 clinical cases match expected risk classification and rules', () {
      int passedCases = 0;

      for (final testCase in testCases) {
        final id = testCase['id'] as String;
        final description = testCase['description'] as String;
        final inputs = Map<String, dynamic>.from(testCase['inputs'] as Map);
        final expectedLevelStr = testCase['expected_level'] as String;
        final expectedScore = testCase['expected_score'] as int?;
        final expectedDanger = testCase['expected_immediate_danger'] as bool?;

        final result = RiskEngine.evaluate(
          age: inputs['age'] as int? ?? 25,
          systolic: inputs['systolic'] as int?,
          diastolic: inputs['diastolic'] as int?,
          hemoglobin: (inputs['hemoglobin'] as num?)?.toDouble(),
          previousSystolic: inputs['previousSystolic'] as int?,
          previousHemoglobin: (inputs['previousHemoglobin'] as num?)?.toDouble(),
          previousCSection: inputs['previousCSection'] as bool? ?? false,
          stillbirthHistory: inputs['stillbirthHistory'] as bool? ?? false,
          pregnancyLossHistory: inputs['pregnancyLossHistory'] as bool? ?? false,
          pphHistory: inputs['postpartumHemorrhageHistory'] as bool? ?? false,
          isTwin: inputs['isTwin'] as bool? ?? false,
          hasDiabetes: inputs['hasDiabetes'] as bool? ?? false,
          isRhNegative: inputs['isRhNegative'] as bool? ?? false,
          consecutiveMissedMedsDays: inputs['consecutiveMissedMedsDays'] as int? ?? 0,
          isOverdueAnc: inputs['isOverdueAnc'] as bool? ?? false,
          dangerSigns: (inputs['dangerSigns'] as List?)?.cast<String>() ?? const [],
        );

        // Verify Risk Level
        final expectedLevel = expectedLevelStr == 'high'
            ? RiskLevel.high
            : (expectedLevelStr == 'moderate' ? RiskLevel.moderate : RiskLevel.low);

        expect(
          result.level,
          expectedLevel,
          reason: '$id ($description): Expected level $expectedLevel but got ${result.level}',
        );

        // Verify score if specified
        if (expectedScore != null) {
          expect(
            result.score,
            expectedScore,
            reason: '$id ($description): Expected score $expectedScore but got ${result.score}',
          );
        }

        // Verify immediate danger flag if specified
        if (expectedDanger != null) {
          expect(
            result.isImmediateDanger,
            expectedDanger,
            reason: '$id ($description): Expected immediateDanger $expectedDanger but got ${result.isImmediateDanger}',
          );
        }

        // Verify trilingual explainability lists are non-empty for positive risk factors
        if (result.score > 0 || result.isImmediateDanger) {
          expect(result.reasonsEn.isNotEmpty, true);
          expect(result.reasonsHi.isNotEmpty, true);
          expect(result.reasonsMr.isNotEmpty, true);
        }

        passedCases++;
      }

      expect(passedCases, 32);
    });
  });
}
