import '../../domain/entities/daily_stats.dart';
import '../../domain/entities/reel_session.dart';

class ReelTrackerState {
  final bool isLoading;
  final DailyStats stats;
  final ReelSession? activeSession;
  final bool isSimulationActive;
  final bool isAutoScrolling;
  final bool isAccessibilityEnabled;
  final bool showLimitExceededDialog;
  final List<String> installedApps;
  final String? errorMessage;

  const ReelTrackerState({
    required this.isLoading,
    required this.stats,
    this.activeSession,
    this.isSimulationActive = false,
    this.isAutoScrolling = false,
    this.isAccessibilityEnabled = false,
    this.showLimitExceededDialog = false,
    this.installedApps = const [],
    this.errorMessage,
  });

  ReelTrackerState copyWith({
    bool? isLoading,
    DailyStats? stats,
    ReelSession? activeSession,
    bool? clearActiveSession,
    bool? isSimulationActive,
    bool? isAutoScrolling,
    bool? isAccessibilityEnabled,
    bool? showLimitExceededDialog,
    List<String>? installedApps,
    String? errorMessage,
  }) {
    return ReelTrackerState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      activeSession: clearActiveSession == true ? null : (activeSession ?? this.activeSession),
      isSimulationActive: isSimulationActive ?? this.isSimulationActive,
      isAutoScrolling: isAutoScrolling ?? this.isAutoScrolling,
      isAccessibilityEnabled: isAccessibilityEnabled ?? this.isAccessibilityEnabled,
      showLimitExceededDialog: showLimitExceededDialog ?? this.showLimitExceededDialog,
      installedApps: installedApps ?? this.installedApps,
      errorMessage: errorMessage,
    );
  }

  factory ReelTrackerState.initial() {
    return ReelTrackerState(
      isLoading: true,
      stats: DailyStats.initial(),
      isSimulationActive: false,
      isAutoScrolling: false,
      isAccessibilityEnabled: false,
      showLimitExceededDialog: false,
      installedApps: const [],
    );
  }
}
