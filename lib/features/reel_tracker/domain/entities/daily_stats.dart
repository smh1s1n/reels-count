import '../value_objects/doomscroll_score.dart';
import '../value_objects/risk_level.dart';
import 'tracked_app.dart';

class DailyStats {
  final DateTime date;
  final int totalReels;
  final int totalDurationSeconds;
  final int dailyLimit;
  final Map<String, TrackedApp> appStats;
  final DoomscrollScore score;

  const DailyStats({
    required this.date,
    required this.totalReels,
    required this.totalDurationSeconds,
    required this.dailyLimit,
    required this.appStats,
    required this.score,
  });

  bool get isLimitExceeded => totalReels >= dailyLimit;

  double get progressToLimit {
    if (dailyLimit <= 0) return 0.0;
    return (totalReels / dailyLimit).clamp(0.0, 1.0);
  }

  RiskLevel get riskLevel => score.riskLevel;

  DailyStats copyWith({
    DateTime? date,
    int? totalReels,
    int? totalDurationSeconds,
    int? dailyLimit,
    Map<String, TrackedApp>? appStats,
    DoomscrollScore? score,
  }) {
    return DailyStats(
      date: date ?? this.date,
      totalReels: totalReels ?? this.totalReels,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      appStats: appStats ?? this.appStats,
      score: score ?? this.score,
    );
  }

  factory DailyStats.initial({int limit = 30}) {
    return DailyStats(
      date: DateTime.now(),
      totalReels: 0,
      totalDurationSeconds: 0,
      dailyLimit: limit,
      appStats: const {},
      score: const DoomscrollScore(0),
    );
  }
}
