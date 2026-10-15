import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/local_storage_datasource.dart';
import '../../data/datasources/native_platform_datasource.dart';
import '../../data/datasources/simulated_reel_datasource.dart';
import '../../data/repositories/reel_tracker_repository_impl.dart';
import '../../domain/entities/reel_session.dart';
import '../../domain/repositories/i_reel_tracker_repository.dart';
import 'reel_tracker_state.dart';

// Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize shared preferences before running app');
});

final localStorageDataSourceProvider = Provider<LocalStorageDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageDataSource(prefs);
});

final nativePlatformDataSourceProvider = Provider<NativePlatformDataSource>((ref) {
  return NativePlatformDataSource();
});

final simulatedReelDataSourceProvider = Provider<SimulatedReelDataSource>((ref) {
  final storage = ref.watch(localStorageDataSourceProvider);
  return SimulatedReelDataSource(storage);
});

final reelTrackerRepositoryProvider = Provider<IReelTrackerRepository>((ref) {
  final native = ref.watch(nativePlatformDataSourceProvider);
  final storage = ref.watch(localStorageDataSourceProvider);
  final sim = ref.watch(simulatedReelDataSourceProvider);

  return ReelTrackerRepositoryImpl(
    nativeDataSource: native,
    localStorage: storage,
    simulatedDataSource: sim,
  );
});

final reelTrackerControllerProvider =
    StateNotifierProvider<ReelTrackerController, ReelTrackerState>((ref) {
  final repository = ref.watch(reelTrackerRepositoryProvider);
  final simSource = ref.watch(simulatedReelDataSourceProvider);
  return ReelTrackerController(repository, simSource);
});

class ReelTrackerController extends StateNotifier<ReelTrackerState> {
  final IReelTrackerRepository _repository;
  final SimulatedReelDataSource _simulatedSource;
  StreamSubscription? _eventSubscription;

  ReelTrackerController(this._repository, this._simulatedSource)
      : super(ReelTrackerState.initial()) {
    _init();
  }

  Future<void> _init() async {
    final isAccessEnabled = await _repository.isAccessibilityServiceActive();
    final isSim = _repository.isSimulationMode();
    final stats = await _repository.getTodayStats();
    final installed = await _repository.getInstalledSocialApps();

    if (!mounted) return;
    state = state.copyWith(
      isLoading: false,
      isAccessibilityEnabled: isAccessEnabled,
      isSimulationActive: isSim,
      stats: stats,
      installedApps: installed,
    );

    _listenToEvents();
  }

  void _listenToEvents() {
    _eventSubscription?.cancel();
    _eventSubscription = _repository.watchTrackerEvents().listen(
      (event) {
        _handleIncomingEvent(event);
      },
      onError: (error) {
        state = state.copyWith(errorMessage: error.toString());
      },
    );
  }

  void _handleIncomingEvent(Map<String, dynamic> event) async {
    final eventType = event['eventType'] as String? ?? '';
    final appName = event['appName'] as String? ?? 'unknown';

    if (eventType == 'open_mindful_break') {
      final updatedStats = await _repository.getTodayStats();
      if (!mounted) return;
      state = state.copyWith(
        stats: updatedStats,
        showLimitExceededDialog: true,
      );
      return;
    }

    if (eventType == 'container_entered') {
      state = state.copyWith(
        activeSession: ReelSession(
          id: const Uuid().v4(),
          activeApp: appName,
          startTime: DateTime.now(),
          reelsCount: 0,
          durationSeconds: 0,
          isActive: true,
        ),
      );
    } else if (eventType == 'container_exited') {
      state = state.copyWith(clearActiveSession: true);
    } else if (eventType == 'reel_detected' || eventType == 'session_tick') {
      final updatedStats = await _repository.getTodayStats();

      // Check if session needs update
      ReelSession? currentSession = state.activeSession;
      if (currentSession != null) {
        currentSession = currentSession.copyWith(
          reelsCount: eventType == 'reel_detected'
              ? currentSession.reelsCount + 1
              : currentSession.reelsCount,
          durationSeconds: currentSession.durationSeconds + 1,
        );
      }

      final limitJustExceeded = updatedStats.isLimitExceeded && !state.stats.isLimitExceeded;

      if (!mounted) return;
      state = state.copyWith(
        stats: updatedStats,
        activeSession: currentSession,
        showLimitExceededDialog: limitJustExceeded ? true : state.showLimitExceededDialog,
      );
    }
  }

  Future<void> refreshStats() async {
    final stats = await _repository.getTodayStats();
    final isAccessEnabled = await _repository.isAccessibilityServiceActive();
    final installed = await _repository.getInstalledSocialApps();
    final shouldOpenIntervention = await _repository.checkPendingIntervention();
    if (!mounted) return;
    state = state.copyWith(
      stats: stats,
      isAccessibilityEnabled: isAccessEnabled,
      installedApps: installed,
      showLimitExceededDialog: shouldOpenIntervention ? true : state.showLimitExceededDialog,
    );
  }

  Future<void> setDailyLimit(int limit) async {
    await _repository.setDailyReelLimit(limit);
    await refreshStats();
  }

  Future<void> resetStats() async {
    await _repository.resetTodayStats();
    await refreshStats();
  }

  void setSimulationMode(bool enabled) {
    _repository.setSimulationMode(enabled);
    state = state.copyWith(
      isSimulationActive: enabled,
      isAutoScrolling: false,
    );
    _listenToEvents();
    refreshStats();
  }

  void startAutoScrollingSimulation({String appName = 'instagram'}) {
    _simulatedSource.startAutoSimulation(appName: appName, scrollIntervalSeconds: 4);
    state = state.copyWith(
      isAutoScrolling: true,
      activeSession: ReelSession(
        id: const Uuid().v4(),
        activeApp: appName,
        startTime: DateTime.now(),
        reelsCount: 0,
        durationSeconds: 0,
        isActive: true,
      ),
    );
  }

  void stopAutoScrollingSimulation() {
    _simulatedSource.stopAutoSimulation();
    state = state.copyWith(
      isAutoScrolling: false,
      clearActiveSession: true,
    );
  }

  void triggerSimulatedScroll({required String appName}) {
    _repository.simulateReelScroll(appName: appName, dwellSeconds: 5);
    refreshStats();
  }

  void dismissLimitExceededDialog() {
    state = state.copyWith(showLimitExceededDialog: false);
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
