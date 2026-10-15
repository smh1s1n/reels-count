import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reels_count/features/limits_and_interventions/data/repositories/limits_repository_impl.dart';
import 'package:reels_count/features/limits_and_interventions/domain/entities/doomscroll_limit.dart';
import 'package:reels_count/features/limits_and_interventions/domain/repositories/i_limits_repository.dart';
import 'package:reels_count/features/reel_tracker/presentation/controllers/reel_tracker_controller.dart';

final limitsRepositoryProvider = Provider<ILimitsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LimitsRepositoryImpl(prefs);
});

class LimitsState {
  final bool isLoading;
  final DoomscrollLimit limits;

  const LimitsState({required this.isLoading, required this.limits});

  factory LimitsState.initial() {
    return LimitsState(
      isLoading: true,
      limits: DoomscrollLimit.defaults(),
    );
  }

  LimitsState copyWith({bool? isLoading, DoomscrollLimit? limits}) {
    return LimitsState(
      isLoading: isLoading ?? this.isLoading,
      limits: limits ?? this.limits,
    );
  }
}

final limitsControllerProvider =
    StateNotifierProvider<LimitsController, LimitsState>((ref) {
  final repository = ref.watch(limitsRepositoryProvider);
  final trackerController = ref.watch(reelTrackerControllerProvider.notifier);
  return LimitsController(repository, trackerController);
});

class LimitsController extends StateNotifier<LimitsState> {
  final ILimitsRepository _repository;
  final ReelTrackerController _trackerController;

  LimitsController(this._repository, this._trackerController)
      : super(LimitsState.initial()) {
    loadLimits();
  }

  Future<void> loadLimits() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    final loaded = await _repository.getLimits();
    if (!mounted) return;
    state = state.copyWith(isLoading: false, limits: loaded);
  }

  Future<void> updateDailyLimit(int count) async {
    final updated = state.limits.copyWith(dailyReelCount: count);
    state = state.copyWith(limits: updated);
    await _repository.saveLimits(updated);
    await _trackerController.setDailyLimit(count);
  }

  Future<void> updateSessionLimit(int count) async {
    final updated = state.limits.copyWith(sessionReelCount: count);
    state = state.copyWith(limits: updated);
    await _repository.saveLimits(updated);
  }

  Future<void> updateDailyMinutes(int minutes) async {
    final updated = state.limits.copyWith(dailyMinutes: minutes);
    state = state.copyWith(limits: updated);
    await _repository.saveLimits(updated);
  }

  Future<void> toggleVibration(bool enabled) async {
    final updated = state.limits.copyWith(isVibrationAlertEnabled: enabled);
    state = state.copyWith(limits: updated);
    await _repository.saveLimits(updated);
  }

  Future<void> toggleOverlay(bool enabled) async {
    final updated = state.limits.copyWith(isMindfulOverlayEnabled: enabled);
    state = state.copyWith(limits: updated);
    await _repository.saveLimits(updated);
  }
}
