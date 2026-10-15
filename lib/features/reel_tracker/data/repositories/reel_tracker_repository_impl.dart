import 'dart:async';
import 'package:intl/intl.dart';
import '../../../../core/constants/social_apps.dart';
import '../../domain/entities/daily_stats.dart';
import '../../domain/entities/tracked_app.dart';
import '../../domain/repositories/i_reel_tracker_repository.dart';
import '../../domain/value_objects/doomscroll_score.dart';
import '../datasources/local_storage_datasource.dart';
import '../datasources/native_platform_datasource.dart';
import '../datasources/simulated_reel_datasource.dart';
import '../models/daily_stats_model.dart';

class ReelTrackerRepositoryImpl implements IReelTrackerRepository {
  final NativePlatformDataSource _nativeDataSource;
  final LocalStorageDataSource _localStorage;
  final SimulatedReelDataSource _simulatedDataSource;

  bool _simulationMode = false;

  ReelTrackerRepositoryImpl({
    required this._nativeDataSource,
    required this._localStorage,
    required this._simulatedDataSource,
  }) {
    _simulationMode = _localStorage.isSimulationEnabled();
  }

  @override
  Stream<Map<String, dynamic>> watchTrackerEvents() {
    if (_simulationMode) {
      return _simulatedDataSource.eventStream;
    }
    try {
      return _nativeDataSource.getEventStream();
    } catch (_) {
      return _simulatedDataSource.eventStream;
    }
  }

  @override
  Future<DailyStats> getTodayStats() async {
    final limit = await getDailyReelLimit();
    final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (_simulationMode) {
      final totalReels = _localStorage.getSimulatedReelCount(dateKey);
      final totalDuration = _localStorage.getSimulatedDuration(dateKey);

      final Map<String, TrackedApp> appStats = {};
      for (final config in SocialAppConfig.supportedApps) {
        final reels = _localStorage.getSimulatedAppReels(config.key, dateKey);
        final duration = _localStorage.getSimulatedAppDuration(config.key, dateKey);
        appStats[config.key] = TrackedApp.fromConfig(
          config,
          reels: reels,
          duration: duration,
        );
      }

      final score = DoomscrollScore.calculate(
        reelsCount: totalReels,
        durationSeconds: totalDuration,
        reelLimit: limit,
      );

      return DailyStats(
        date: DateTime.now(),
        totalReels: totalReels,
        totalDurationSeconds: totalDuration,
        dailyLimit: limit,
        appStats: appStats,
        score: score,
      );
    }

    try {
      final nativeMap = await _nativeDataSource.getDailyStats();
      if (nativeMap.isNotEmpty) {
        return DailyStatsModel.fromNativeMap(nativeMap).toDomain();
      }
    } catch (_) {}

    // Fallback: If native returned empty or error, use local simulated/cached values
    final totalReels = _localStorage.getSimulatedReelCount(dateKey);
    final totalDuration = _localStorage.getSimulatedDuration(dateKey);

    final Map<String, TrackedApp> appStats = {};
    for (final config in SocialAppConfig.supportedApps) {
      final reels = _localStorage.getSimulatedAppReels(config.key, dateKey);
      final duration = _localStorage.getSimulatedAppDuration(config.key, dateKey);
      appStats[config.key] = TrackedApp.fromConfig(config, reels: reels, duration: duration);
    }

    final score = DoomscrollScore.calculate(
      reelsCount: totalReels,
      durationSeconds: totalDuration,
      reelLimit: limit,
    );

    return DailyStats(
      date: DateTime.now(),
      totalReels: totalReels,
      totalDurationSeconds: totalDuration,
      dailyLimit: limit,
      appStats: appStats,
      score: score,
    );
  }

  @override
  Future<void> setDailyReelLimit(int limit) async {
    await _localStorage.setDailyLimit(limit);
    try {
      await _nativeDataSource.setReelLimit(limit);
    } catch (_) {}
  }

  @override
  Future<int> getDailyReelLimit() async {
    return _localStorage.getDailyLimit();
  }

  @override
  Future<void> resetTodayStats() async {
    final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _localStorage.resetSimulatedStats(dateKey);
    try {
      await _nativeDataSource.resetDailyStats();
    } catch (_) {}
  }

  @override
  Future<bool> isAccessibilityServiceActive() async {
    return _nativeDataSource.isAccessibilityGranted();
  }

  @override
  void setSimulationMode(bool enabled) {
    _simulationMode = enabled;
    _localStorage.setSimulationEnabled(enabled);
    if (!enabled) {
      _simulatedDataSource.stopAutoSimulation();
    }
  }

  @override
  bool isSimulationMode() => _simulationMode;

  @override
  void simulateReelScroll({required String appName, required int dwellSeconds}) {
    _simulatedDataSource.triggerSingleScroll(appName: appName, dwellSeconds: dwellSeconds);
  }

  @override
  Future<List<String>> getInstalledSocialApps() async {
    try {
      return await _nativeDataSource.getInstalledSocialApps();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> checkPendingIntervention() async {
    try {
      final res = await _nativeDataSource.checkPendingIntervention();
      return res['shouldOpen'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  SimulatedReelDataSource get simulatedDataSource => _simulatedDataSource;
}
