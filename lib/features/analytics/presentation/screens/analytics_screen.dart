import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/analytics_controller.dart';
import '../widgets/dopamine_meter_card.dart';
import '../widgets/hourly_bar_chart.dart';
import '../widgets/weekly_trend_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights & Metrics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(analyticsControllerProvider.notifier).loadAnalytics();
            },
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
          : RefreshIndicator(
              color: AppTheme.primaryTeal,
              backgroundColor: AppTheme.darkCard,
              onRefresh: () async {
                await ref.read(analyticsControllerProvider.notifier).loadAnalytics();
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  DopamineMeterCard(
                    score: state.todayStats.score,
                    averageDwellSeconds: state.averageDwellTime,
                  ),
                  const SizedBox(height: 16),
                  HourlyBarChart(hourlyUsage: state.hourlyUsage),
                  const SizedBox(height: 16),
                  WeeklyTrendCard(summary: state.weeklySummary),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
