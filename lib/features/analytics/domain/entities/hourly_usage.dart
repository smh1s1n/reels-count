class HourlyUsage {
  final int hour; // 0 - 23
  final int reelsCount;
  final int durationSeconds;

  const HourlyUsage({
    required this.hour,
    required this.reelsCount,
    required this.durationSeconds,
  });

  String get label {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final ampm = hour < 12 ? 'AM' : 'PM';
    return '$h$ampm';
  }
}
