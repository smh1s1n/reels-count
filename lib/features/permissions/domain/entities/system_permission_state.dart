class SystemPermissionState {
  final bool isAccessibilityGranted;
  final bool isUsageStatsGranted;
  final bool isOverlayGranted;
  final bool isNotificationGranted;

  const SystemPermissionState({
    required this.isAccessibilityGranted,
    required this.isUsageStatsGranted,
    required this.isOverlayGranted,
    this.isNotificationGranted = false,
  });

  bool get isFullyConfigured =>
      isAccessibilityGranted &&
      isUsageStatsGranted &&
      isOverlayGranted &&
      isNotificationGranted;

  int get grantedCount {
    int count = 0;
    if (isAccessibilityGranted) count++;
    if (isUsageStatsGranted) count++;
    if (isOverlayGranted) count++;
    if (isNotificationGranted) count++;
    return count;
  }

  int get totalCount => 4;

  double get progress => totalCount > 0 ? (grantedCount / totalCount).clamp(0.0, 1.0) : 0.0;

  SystemPermissionState copyWith({
    bool? isAccessibilityGranted,
    bool? isUsageStatsGranted,
    bool? isOverlayGranted,
    bool? isNotificationGranted,
  }) {
    return SystemPermissionState(
      isAccessibilityGranted: isAccessibilityGranted ?? this.isAccessibilityGranted,
      isUsageStatsGranted: isUsageStatsGranted ?? this.isUsageStatsGranted,
      isOverlayGranted: isOverlayGranted ?? this.isOverlayGranted,
      isNotificationGranted: isNotificationGranted ?? this.isNotificationGranted,
    );
  }

  factory SystemPermissionState.initial() {
    return const SystemPermissionState(
      isAccessibilityGranted: false,
      isUsageStatsGranted: false,
      isOverlayGranted: false,
      isNotificationGranted: false,
    );
  }
}
