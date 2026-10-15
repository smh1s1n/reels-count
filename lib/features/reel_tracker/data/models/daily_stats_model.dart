import '../../../../core/constants/social_apps.dart';
import '../../domain/entities/daily_stats.dart';
import '../../domain/entities/tracked_app.dart';
import '../../domain/value_objects/doomscroll_score.dart';

class DailyStatsModel {
  final DateTime date;
  final int totalReels;
  final int totalDurationSeconds;
  final int dailyLimit;
  final Map<String, TrackedApp> appStats;

  DailyStatsModel({
    required this.date,
    required this.totalReels,
    required this.totalDurationSeconds,
    required this.dailyLimit,
    required this.appStats,
  });

  factory DailyStatsModel.fromNativeMap(Map<dynamic, dynamic> map) {
    final totalReels = (map['totalReels'] as num?)?.toInt() ?? 0;
    final totalDuration = (map['totalDurationSeconds'] as num?)?.toInt() ?? 0;
    final limit = (map['dailyLimit'] as num?)?.toInt() ?? 30;

    final appsRaw = map['apps'] as Map<dynamic, dynamic>? ?? {};
    final Map<String, TrackedApp> appStats = {};

    for (final config in SocialAppConfig.supportedApps) {
      final appData = appsRaw[config.key] as Map<dynamic, dynamic>?;
      final reels = (appData?['reels'] as num?)?.toInt() ?? 0;
      final duration = (appData?['duration'] as num?)?.toInt() ?? 0;

      appStats[config.key] = TrackedApp.fromConfig(
        config,
        reels: reels,
        duration: duration,
      );
    }

    return DailyStatsModel(
      date: DateTime.now(),
      totalReels: totalReels,
      totalDurationSeconds: totalDuration,
      dailyLimit: limit,
      appStats: appStats,
    );
  }

  DailyStats toDomain() {
    final calculatedScore = DoomscrollScore.calculate(
      reelsCount: totalReels,
      durationSeconds: totalDurationSeconds,
      reelLimit: dailyLimit,
    );

    return DailyStats(
      date: date,
      totalReels: totalReels,
      totalDurationSeconds: totalDurationSeconds,
      dailyLimit: dailyLimit,
      appStats: appStats,
      score: calculatedScore,
    );
  }
}
