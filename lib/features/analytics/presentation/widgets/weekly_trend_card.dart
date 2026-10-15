import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neumorphic.dart';
import '../../../../core/utils/formatters.dart';
import 'package:reels_count/features/analytics/domain/entities/weekly_summary.dart';

class WeeklyTrendCard extends StatelessWidget {
  final WeeklySummary? summary;

  const WeeklyTrendCard({super.key, this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary == null) return const SizedBox.shrink();

    return NeuContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_month_outlined, color: AppTheme.primaryPurple, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '7-DAY REELS TREND',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Text(
                'Avg ${summary!.averageReelsPerDay.toInt()} / day',
                style: const TextStyle(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: summary!.days.map((day) {
              final isToday = day.dayName == 'Today';
              final maxInWeek = summary!.days.map((d) => d.reelsCount).reduce((a, b) => a > b ? a : b);
              final heightFactor = maxInWeek > 0 ? (day.reelsCount / maxInWeek).clamp(0.15, 1.0) : 0.15;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${day.reelsCount}',
                    style: TextStyle(
                      color: isToday ? AppTheme.primaryTeal : Colors.white60,
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 24,
                    height: (80 * heightFactor).toDouble(),
                    decoration: BoxDecoration(
                      color: isToday ? AppTheme.primaryTeal : Colors.white12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    day.dayName,
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.white38,
                      fontSize: 10,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          const Divider(color: AppTheme.darkBorder),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total weekly watch time:', style: TextStyle(color: Colors.white60, fontSize: 13)),
              Text(
                TimeFormatters.formatSeconds(summary!.totalDurationSeconds),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
