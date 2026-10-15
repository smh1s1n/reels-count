import '../entities/hourly_usage.dart';
import '../entities/weekly_summary.dart';

abstract class IAnalyticsRepository {
  Future<List<HourlyUsage>> getTodayHourlyUsage();
  Future<WeeklySummary> getWeeklySummary();
  Future<double> getAverageDwellTimeSeconds();
}
