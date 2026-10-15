class AppConstants {
  static const String appName = 'ReelsGuard';
  static const String appTagline = 'Break the Doomscroll Loop';

  // Platform Channels
  static const String methodChannelName = 'com.antidoomscroll.reels/tracker';
  static const String eventChannelName = 'com.antidoomscroll.reels/events';

  // Defaults
  static const int defaultDailyReelLimit = 30;
  static const int defaultSessionReelLimit = 15;
  static const int defaultDailyDurationMinutes = 30;

  // Dwell threshold in seconds to consider a reel actually watched vs skipped
  static const double minimumDwellSeconds = 1.2;

  // Storage keys
  static const String keyDailyLimit = 'pref_daily_reel_limit';
  static const String keySessionLimit = 'pref_session_reel_limit';
  static const String keyIsSimulationActive = 'pref_simulation_mode';
  static const String keyTargetAppsPrefix = 'pref_target_app_';
}
