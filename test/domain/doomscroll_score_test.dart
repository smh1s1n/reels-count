import 'package:flutter_test/flutter_test.dart';
import 'package:reels_count/features/reel_tracker/domain/value_objects/doomscroll_score.dart';
import 'package:reels_count/features/reel_tracker/domain/value_objects/risk_level.dart';

void main() {
  group('DoomscrollScore calculations', () {
    test('returns 0 score when 0 reels watched', () {
      final score = DoomscrollScore.calculate(
        reelsCount: 0,
        durationSeconds: 0,
        reelLimit: 30,
      );

      expect(score.value, 0);
      expect(score.riskLevel, RiskLevel.low);
    });

    test('calculates mindful low risk when well below limit and healthy dwell time', () {
      final score = DoomscrollScore.calculate(
        reelsCount: 5,
        durationSeconds: 150, // 30s per reel
        reelLimit: 30,
      );

      expect(score.value, lessThan(30));
      expect(score.riskLevel, RiskLevel.low);
    });

    test('penalizes rapid mindless doomscrolling when dwell time is very fast (< 6s per reel)', () {
      final normalScore = DoomscrollScore.calculate(
        reelsCount: 15,
        durationSeconds: 300, // 20s per reel
        reelLimit: 30,
      );

      final fastScore = DoomscrollScore.calculate(
        reelsCount: 15,
        durationSeconds: 45, // 3s per reel (rapid mindless flipping)
        reelLimit: 30,
      );

      expect(fastScore.value, greaterThan(normalScore.value));
    });

    test('flags extreme risk when daily limit is exceeded', () {
      final score = DoomscrollScore.calculate(
        reelsCount: 45,
        durationSeconds: 1200,
        reelLimit: 30,
      );

      expect(score.value, greaterThanOrEqualTo(85));
      expect(score.riskLevel, RiskLevel.extreme);
    });
  });
}
