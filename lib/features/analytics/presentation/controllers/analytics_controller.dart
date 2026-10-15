import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reels_count/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:reels_count/features/analytics/domain/entities/hourly_usage.dart';
import 'package:reels_count/features/analytics/domain/entities/weekly_summary.dart';
import 'package:reels_count/features/analytics/domain/repositories/i_analytics_repository.dart';
import 'package:reels_count/features/reel_tracker/domain/entities/daily_stats.dart';
import 'package:reels_count/features/reel_tracker/presentation/controllers/reel_tracker_controller.dart';

final analyticsRepositoryProvider = Provider<IAnalyticsRepository>((ref) {
  final trackerRepo = ref.watch(reelTrackerRepositoryProvider);
  return AnalyticsRepositoryImpl(trackerRepo);
});

class AnalyticsState {
  final bool isLoading;
  final List<HourlyUsage> hourlyUsage;
  final WeeklySummary? weeklySummary;
  final double averageDwellTime;
  final DailyStats todayStats;

  const AnalyticsState({
    required this.isLoading,
    required this.hourlyUsage,
    this.weeklySummary,
    required this.averageDwellTime,
    required this.todayStats,
  });

  factory AnalyticsState.initial() {
    return AnalyticsState(
      isLoading: true,
      hourlyUsage: const [],
      averageDwellTime: 0.0,
      todayStats: DailyStats.initial(),
    );
  }
}

final analyticsControllerProvider =
    StateNotifierProvider<AnalyticsController, AnalyticsState>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  final trackerState = ref.watch(reelTrackerControllerProvider);
  return AnalyticsController(repository, trackerState.stats);
});

class AnalyticsController extends StateNotifier<AnalyticsState> {
  final IAnalyticsRepository _repository;

  AnalyticsController(this._repository, DailyStats initialStats)
      : super(AnalyticsState.initial().copyWith(todayStats: initialStats)) {
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    final hourly = await _repository.getTodayHourlyUsage();
    final weekly = await _repository.getWeeklySummary();
    final avgDwell = await _repository.getAverageDwellTimeSeconds();

    if (!mounted) return;
    state = state.copyWith(
      isLoading: false,
      hourlyUsage: hourly,
      weeklySummary: weekly,
      averageDwellTime: avgDwell,
    );
  }
}

extension on AnalyticsState {
  AnalyticsState copyWith({
    bool? isLoading,
    List<HourlyUsage>? hourlyUsage,
    WeeklySummary? weeklySummary,
    double? averageDwellTime,
    DailyStats? todayStats,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      hourlyUsage: hourlyUsage ?? this.hourlyUsage,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      averageDwellTime: averageDwellTime ?? this.averageDwellTime,
      todayStats: todayStats ?? this.todayStats,
    );
  }
}
