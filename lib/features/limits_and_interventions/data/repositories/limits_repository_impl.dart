import 'package:shared_preferences/shared_preferences.dart';
import 'package:reels_count/core/constants/app_constants.dart';
import 'package:reels_count/features/limits_and_interventions/domain/entities/doomscroll_limit.dart';
import 'package:reels_count/features/limits_and_interventions/domain/repositories/i_limits_repository.dart';

class LimitsRepositoryImpl implements ILimitsRepository {
  final SharedPreferences _prefs;

  LimitsRepositoryImpl(this._prefs);

  @override
  Future<DoomscrollLimit> getLimits() async {
    final dailyReels = _prefs.getInt(AppConstants.keyDailyLimit) ?? AppConstants.defaultDailyReelLimit;
    final sessionReels = _prefs.getInt(AppConstants.keySessionLimit) ?? AppConstants.defaultSessionReelLimit;
    final dailyMinutes = _prefs.getInt('pref_daily_minutes') ?? AppConstants.defaultDailyDurationMinutes;
    final vibration = _prefs.getBool('pref_vibration_alert') ?? true;
    final overlay = _prefs.getBool('pref_mindful_overlay') ?? true;

    return DoomscrollLimit(
      dailyReelCount: dailyReels,
      sessionReelCount: sessionReels,
      dailyMinutes: dailyMinutes,
      isVibrationAlertEnabled: vibration,
      isMindfulOverlayEnabled: overlay,
    );
  }

  @override
  Future<void> saveLimits(DoomscrollLimit limits) async {
    await _prefs.setInt(AppConstants.keyDailyLimit, limits.dailyReelCount);
    await _prefs.setInt(AppConstants.keySessionLimit, limits.sessionReelCount);
    await _prefs.setInt('pref_daily_minutes', limits.dailyMinutes);
    await _prefs.setBool('pref_vibration_alert', limits.isVibrationAlertEnabled);
    await _prefs.setBool('pref_mindful_overlay', limits.isMindfulOverlayEnabled);
  }
}
