class DaySummary {
  final DateTime date;
  final String dayName;
  final int reelsCount;
  final int durationSeconds;

  const DaySummary({
    required this.date,
    required this.dayName,
    required this.reelsCount,
    required this.durationSeconds,
  });
}

class WeeklySummary {
  final List<DaySummary> days;
  final int totalReels;
  final int totalDurationSeconds;
  final double averageReelsPerDay;

  const WeeklySummary({
    required this.days,
    required this.totalReels,
    required this.totalDurationSeconds,
    required this.averageReelsPerDay,
  });
}
