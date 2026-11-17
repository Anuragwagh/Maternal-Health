import 'package:flutter_test/flutter_test.dart';
import 'package:maternalhealth_app/core/services/risk_engine.dart';

void main() {
  group('RiskEngine v2 Clinical Tests', () {
    test('1. Normal healthy mother -> Low Risk (Score 0)', () {
      final res = RiskEngine.evaluate(
        age: 24,
        systolic: 110,
        diastolic: 70,
        hemoglobin: 12.0,
      );

      expect(res.level, RiskLevel.low);
      expect(res.score, 0);
      expect(res.isImmediateDanger, false);
      expect(res.reasonsEn, isEmpty);
    });

    test('2. Danger sign override: Severe Anemia (Hb < 7.0) -> Immediate High Risk', () {
      final res = RiskEngine.evaluate(
        age: 26,
        hemoglobin: 6.5,
      );

      expect(res.level, RiskLevel.high);
      expect(res.isImmediateDanger, true);
      expect(res.reasonsEn.any((r) => r.contains('Severe Anemia')), true);
      expect(res.reasonsMr.any((r) => r.contains('तीव्र रक्तक्षय')), true);
    });

    test('3. Danger sign override: Severe Hypertension (BP 165/110) -> Immediate High Risk', () {
      final res = RiskEngine.evaluate(
        age: 28,
        systolic: 165,
        diastolic: 110,
      );

      expect(res.level, RiskLevel.high);
      expect(res.isImmediateDanger, true);
      expect(res.reasonsEn.any((r) => r.contains('Severe Hypertension')), true);
    });

    test('4. Danger sign override: Vaginal Bleeding reported -> Immediate High Risk', () {
      final res = RiskEngine.evaluate(
        age: 25,
        dangerSigns: ['vaginal_bleeding'],
      );

      expect(res.level, RiskLevel.high);
      expect(res.isImmediateDanger, true);
      expect(res.reasonsEn.any((r) => r.contains('Vaginal Bleeding')), true);
    });

    test('5. Weighted score: Teenage pregnancy (age 17) + Stage 1 BP (145/95) -> High Risk (Score 5)', () {
      final res = RiskEngine.evaluate(
        age: 17, // +2
        systolic: 145, // +3
        diastolic: 95,
        hemoglobin: 11.5,
      );

      expect(res.level, RiskLevel.high);
      expect(res.score, 5);
      expect(res.reasonsEn.length, 2);
    });

    test('6. Weighted score: Moderate Anemia (Hb 8.5) + Missed Medicines (4 days) -> Moderate Risk (Score 4)', () {
      final res = RiskEngine.evaluate(
        age: 26,
        hemoglobin: 8.5, // +2
        consecutiveMissedMedsDays: 4, // +2
      );

      expect(res.level, RiskLevel.moderate);
      expect(res.score, 4);
      expect(res.reasonsEn.any((r) => r.contains('Moderate Anemia')), true);
      expect(res.reasonsEn.any((r) => r.contains('Missed Medicines 3-6 Days')), true);
    });

    test('7. Weighted score: Twin Pregnancy + Diabetes -> High Risk (Score 5)', () {
      final res = RiskEngine.evaluate(
        age: 26,
        isTwin: true, // +3
        hasDiabetes: true, // +2
      );

      expect(res.level, RiskLevel.high);
      expect(res.score, 5);
    });

    test('8. Trend detection: BP rising >= 20 mmHg across visits', () {
      final res = RiskEngine.evaluate(
        age: 26,
        systolic: 135,
        previousSystolic: 110, // +25 mmHg rise -> +2 pts
      );

      expect(res.score, 2);
      expect(res.reasonsEn.any((r) => r.contains('Systolic BP Rising')), true);
    });

    test('9. Obstetric complications capped at 4 points max', () {
      final res = RiskEngine.evaluate(
        age: 25,
        previousCSection: true, // +2
        stillbirthHistory: true, // +2
        pregnancyLossHistory: true, // +2, but capped at 4
      );

      expect(res.score, 4);
    });
  });
}
