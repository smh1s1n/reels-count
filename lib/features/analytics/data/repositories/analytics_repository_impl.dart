import 'package:intl/intl.dart';
import 'package:reels_count/features/analytics/domain/entities/hourly_usage.dart';
import 'package:reels_count/features/analytics/domain/entities/weekly_summary.dart';
import 'package:reels_count/features/analytics/domain/repositories/i_analytics_repository.dart';
import 'package:reels_count/features/reel_tracker/domain/repositories/i_reel_tracker_repository.dart';

class AnalyticsRepositoryImpl implements IAnalyticsRepository {
  final IReelTrackerRepository _trackerRepository;

  AnalyticsRepositoryImpl(this._trackerRepository);

  @override
  Future<List<HourlyUsage>> getTodayHourlyUsage() async {
    final todayStats = await _trackerRepository.getTodayStats();
    final currentHour = DateTime.now().hour;

    // Distribute reels across hours with peaks at typical doomscroll hours (e.g. 13:00, 21:00, 22:00)
    final List<HourlyUsage> hourly = [];
    final totalReels = todayStats.totalReels;
    final totalDuration = todayStats.totalDurationSeconds;

    for (int h = 0; h < 24; h++) {
      if (h > currentHour) {
        hourly.add(HourlyUsage(hour: h, reelsCount: 0, durationSeconds: 0));
        continue;
      }

      int reelsInHour = 0;
      int durationInHour = 0;

      if (totalReels > 0) {
        // Natural weighting
        double weight = 0.02;
        if (h >= 8 && h <= 10) weight = 0.08;
        if (h >= 12 && h <= 14) weight = 0.15;
        if (h >= 19 && h <= 23) weight = 0.30;

        reelsInHour = ((totalReels * weight)).round();
        durationInHour = ((totalDuration * weight)).round();
      }

      hourly.add(HourlyUsage(
        hour: h,
        reelsCount: reelsInHour,
        durationSeconds: durationInHour,
      ));
    }

    return hourly;
  }

  @override
  Future<WeeklySummary> getWeeklySummary() async {
    final todayStats = await _trackerRepository.getTodayStats();
    final now = DateTime.now();
    final List<DaySummary> days = [];

    final sampleReelCounts = [24, 42, 18, 35, 55, 30]; // Previous 6 days
    int totalReels = 0;
    int totalSecs = 0;

    for (int i = 6; i >= 1; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = DateFormat('E').format(date);
      final reels = sampleReelCounts[6 - i];
      final duration = reels * 35; // ~35s per reel avg

      totalReels += reels;
      totalSecs += duration;

      days.add(DaySummary(
        date: date,
        dayName: dayName,
        reelsCount: reels,
        durationSeconds: duration,
      ));
    }

    // Add Today
    days.add(DaySummary(
      date: now,
      dayName: 'Today',
      reelsCount: todayStats.totalReels,
      durationSeconds: todayStats.totalDurationSeconds,
    ));

    totalReels += todayStats.totalReels;
    totalSecs += todayStats.totalDurationSeconds;

    return WeeklySummary(
      days: days,
      totalReels: totalReels,
      totalDurationSeconds: totalSecs,
      averageReelsPerDay: (totalReels / 7).roundToDouble(),
    );
  }

  @override
  Future<double> getAverageDwellTimeSeconds() async {
    final todayStats = await _trackerRepository.getTodayStats();
    if (todayStats.totalReels == 0) return 0.0;
    return (todayStats.totalDurationSeconds / todayStats.totalReels);
  }
}
