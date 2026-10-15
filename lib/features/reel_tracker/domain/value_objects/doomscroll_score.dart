import 'risk_level.dart';

class DoomscrollScore {
  final int value; // 0 to 100

  const DoomscrollScore(this.value);

  RiskLevel get riskLevel {
    if (value < 30) return RiskLevel.low;
    if (value < 60) return RiskLevel.moderate;
    if (value < 85) return RiskLevel.high;
    return RiskLevel.extreme;
  }

  static DoomscrollScore calculate({
    required int reelsCount,
    required int durationSeconds,
    required int reelLimit,
  }) {
    if (reelLimit <= 0) return const DoomscrollScore(0);

    // Factors:
    // 1. Ratio of reels consumed vs limit (up to 70 pts)
    final reelRatio = (reelsCount / reelLimit).clamp(0.0, 1.5);
    final reelPoints = reelRatio * 60;

    // 2. Velocity: Average time spent per reel. Fast scrolling (< 5s per reel) indicates mindless scrolling
    double velocityPoints = 0;
    if (reelsCount > 3) {
      final avgSecondsPerReel = durationSeconds / reelsCount;
      if (avgSecondsPerReel < 6.0) {
        // High rapid doomscrolling penalty
        velocityPoints = 30.0;
      } else if (avgSecondsPerReel < 12.0) {
        velocityPoints = 15.0;
      } else {
        velocityPoints = 5.0;
      }
    }

    // 3. Raw duration points (up to 10 pts)
    final durationMinutes = durationSeconds / 60;
    final durationPoints = (durationMinutes / 10).clamp(0.0, 10.0);

    final total = (reelPoints + velocityPoints + durationPoints).round().clamp(0, 100);
    return DoomscrollScore(total);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DoomscrollScore && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'DoomscrollScore($value)';
}
