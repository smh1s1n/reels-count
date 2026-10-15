class ReelSession {
  final String id;
  final String activeApp;
  final DateTime startTime;
  final DateTime? endTime;
  final int reelsCount;
  final int durationSeconds;
  final bool isActive;

  const ReelSession({
    required this.id,
    required this.activeApp,
    required this.startTime,
    this.endTime,
    required this.reelsCount,
    required this.durationSeconds,
    required this.isActive,
  });

  ReelSession copyWith({
    String? activeApp,
    DateTime? endTime,
    int? reelsCount,
    int? durationSeconds,
    bool? isActive,
  }) {
    return ReelSession(
      id: id,
      activeApp: activeApp ?? this.activeApp,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      reelsCount: reelsCount ?? this.reelsCount,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isActive: isActive ?? this.isActive,
    );
  }
}
