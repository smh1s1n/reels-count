import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

class LocalStorageDataSource {
  final SharedPreferences _prefs;

  LocalStorageDataSource(this._prefs);

  static Future<LocalStorageDataSource> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageDataSource(prefs);
  }

  int getDailyLimit() {
    return _prefs.getInt(AppConstants.keyDailyLimit) ?? AppConstants.defaultDailyReelLimit;
  }

  Future<void> setDailyLimit(int limit) async {
    await _prefs.setInt(AppConstants.keyDailyLimit, limit);
  }

  bool isSimulationEnabled() {
    return _prefs.getBool(AppConstants.keyIsSimulationActive) ?? false;
  }

  Future<void> setSimulationEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.keyIsSimulationActive, enabled);
  }

  int getSimulatedReelCount(String dateKey) {
    return _prefs.getInt('sim_reels_$dateKey') ?? 0;
  }

  Future<void> saveSimulatedReelCount(String dateKey, int count) async {
    await _prefs.setInt('sim_reels_$dateKey', count);
  }

  int getSimulatedDuration(String dateKey) {
    return _prefs.getInt('sim_duration_$dateKey') ?? 0;
  }

  Future<void> saveSimulatedDuration(String dateKey, int seconds) async {
    await _prefs.setInt('sim_duration_$dateKey', seconds);
  }

  int getSimulatedAppReels(String appKey, String dateKey) {
    return _prefs.getInt('sim_app_${appKey}_reels_$dateKey') ?? 0;
  }

  Future<void> saveSimulatedAppReels(String appKey, String dateKey, int count) async {
    await _prefs.setInt('sim_app_${appKey}_reels_$dateKey', count);
  }

  int getSimulatedAppDuration(String appKey, String dateKey) {
    return _prefs.getInt('sim_app_${appKey}_duration_$dateKey') ?? 0;
  }

  Future<void> saveSimulatedAppDuration(String appKey, String dateKey, int duration) async {
    await _prefs.setInt('sim_app_${appKey}_duration_$dateKey', duration);
  }

  Future<void> resetSimulatedStats(String dateKey) async {
    await _prefs.remove('sim_reels_$dateKey');
    await _prefs.remove('sim_duration_$dateKey');
    for (final app in ['instagram', 'tiktok', 'youtube', 'facebook']) {
      await _prefs.remove('sim_app_${app}_reels_$dateKey');
      await _prefs.remove('sim_app_${app}_duration_$dateKey');
    }
  }
}
