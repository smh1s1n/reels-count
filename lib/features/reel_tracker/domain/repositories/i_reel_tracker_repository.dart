import '../entities/daily_stats.dart';

abstract class IReelTrackerRepository {
  /// Stream of live reel tracking events (reel detected, session ticks, app changes)
  Stream<Map<String, dynamic>> watchTrackerEvents();

  /// Fetch today's aggregated statistics
  Future<DailyStats> getTodayStats();

  /// Save or update daily reel limit
  Future<void> setDailyReelLimit(int limit);

  /// Get configured daily reel limit
  Future<int> getDailyReelLimit();

  /// Reset stats for today
  Future<void> resetTodayStats();

  /// Check if the native accessibility service is active
  Future<bool> isAccessibilityServiceActive();

  /// Start or stop simulation mode (useful for demo/testing or iOS fallback)
  void setSimulationMode(bool enabled);
  bool isSimulationMode();

  /// Manually trigger a simulated reel watch (e.g. for testing)
  void simulateReelScroll({required String appName, required int dwellSeconds});

  /// Check which supported social media apps are installed on the device
  Future<List<String>> getInstalledSocialApps();

  /// Check if the system launched the app with a pending mindful break intervention
  Future<bool> checkPendingIntervention();
}
