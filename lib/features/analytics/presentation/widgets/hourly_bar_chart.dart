import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neumorphic.dart';
import 'package:reels_count/features/analytics/domain/entities/hourly_usage.dart';

class HourlyBarChart extends StatelessWidget {
  final List<HourlyUsage> hourlyUsage;

  const HourlyBarChart({super.key, required this.hourlyUsage});

  @override
  Widget build(BuildContext context) {
    if (hourlyUsage.isEmpty) {
      return const SizedBox.shrink();
    }

    int maxReels = 10;
    for (final h in hourlyUsage) {
      if (h.reelsCount > maxReels) {
        maxReels = h.reelsCount;
      }
    }

    return NeuContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: AppTheme.primaryTeal, size: 20),
              SizedBox(width: 8),
              Text(
                'HOURLY REEL DISTRIBUTION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxReels.toDouble() + 4,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.darkSurface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final h = hourlyUsage[group.x.toInt()];
                      return BarTooltipItem(
                        '${h.label}\n',
                        const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                        children: [
                          TextSpan(
                            text: '${rod.toY.toInt()} reels',
                            style: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w900),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == (maxReels ~/ 2) || value == maxReels) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(color: Colors.white38, fontSize: 10),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final val = value.toInt();
                        if (val % 4 == 0 && val < hourlyUsage.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              hourlyUsage[val].label,
                              style: const TextStyle(color: Colors.white38, fontSize: 10),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: hourlyUsage.map((h) {
                  final isPeak = h.reelsCount >= (maxReels * 0.7) && h.reelsCount > 3;
                  return BarChartGroupData(
                    x: h.hour,
                    barRods: [
                      BarChartRodData(
                        toY: h.reelsCount.toDouble(),
                        color: isPeak ? AppTheme.accentRed : AppTheme.primaryTeal,
                        width: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
