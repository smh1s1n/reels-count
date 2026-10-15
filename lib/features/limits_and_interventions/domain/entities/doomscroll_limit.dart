class DoomscrollLimit {
  final int dailyReelCount;
  final int sessionReelCount;
  final int dailyMinutes;
  final bool isVibrationAlertEnabled;
  final bool isMindfulOverlayEnabled;

  const DoomscrollLimit({
    required this.dailyReelCount,
    required this.sessionReelCount,
    required this.dailyMinutes,
    this.isVibrationAlertEnabled = true,
    this.isMindfulOverlayEnabled = true,
  });

  DoomscrollLimit copyWith({
    int? dailyReelCount,
    int? sessionReelCount,
    int? dailyMinutes,
    bool? isVibrationAlertEnabled,
    bool? isMindfulOverlayEnabled,
  }) {
    return DoomscrollLimit(
      dailyReelCount: dailyReelCount ?? this.dailyReelCount,
      sessionReelCount: sessionReelCount ?? this.sessionReelCount,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      isVibrationAlertEnabled: isVibrationAlertEnabled ?? this.isVibrationAlertEnabled,
      isMindfulOverlayEnabled: isMindfulOverlayEnabled ?? this.isMindfulOverlayEnabled,
    );
  }

  factory DoomscrollLimit.defaults() {
    return const DoomscrollLimit(
      dailyReelCount: 30,
      sessionReelCount: 15,
      dailyMinutes: 30,
      isVibrationAlertEnabled: true,
      isMindfulOverlayEnabled: true,
    );
  }
}
