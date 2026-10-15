import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:reels_count/core/constants/app_constants.dart';
import 'package:reels_count/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:reels_count/features/reel_tracker/data/datasources/local_storage_datasource.dart';
import 'package:reels_count/features/reel_tracker/data/datasources/native_platform_datasource.dart';
import 'package:reels_count/features/reel_tracker/data/datasources/simulated_reel_datasource.dart';
import 'package:reels_count/features/reel_tracker/data/repositories/reel_tracker_repository_impl.dart';
import 'package:reels_count/features/reel_tracker/domain/entities/daily_stats.dart';
import 'package:reels_count/features/reel_tracker/presentation/controllers/reel_tracker_controller.dart';
import 'package:reels_count/features/reel_tracker/presentation/widgets/tracked_apps_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;
  late LocalStorageDataSource localStorage;
  late SimulatedReelDataSource simDataSource;
  late NativePlatformDataSource nativeDataSource;
  late ReelTrackerRepositoryImpl repository;
  final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(AppConstants.methodChannelName),
      (MethodCall methodCall) async {
        if (methodCall.method == 'isAccessibilityGranted') return true;
        if (methodCall.method == 'isUsageStatsGranted') return true;
        if (methodCall.method == 'isOverlayGranted') return true;
        if (methodCall.method == 'isNotificationGranted') return true;
        if (methodCall.method == 'getDailyStats') return <dynamic, dynamic>{};
        if (methodCall.method == 'getReelLimit') return 10;
        if (methodCall.method == 'getInstalledSocialApps') return <dynamic>['youtube'];
        return null;
      },
    );

    SharedPreferences.setMockInitialValues({
      'pref_daily_reel_limit': 10,
      'pref_simulation_mode': true,
    });
    prefs = await SharedPreferences.getInstance();
    localStorage = LocalStorageDataSource(prefs);
    simDataSource = SimulatedReelDataSource(localStorage);
    nativeDataSource = NativePlatformDataSource();
    repository = ReelTrackerRepositoryImpl(
      nativeDataSource: nativeDataSource,
      localStorage: localStorage,
      simulatedDataSource: simDataSource,
    );
  });

  group('Reel Number & Watch Time Calculations', () {
    test('Simulated reel scroll updates reel count and watch duration in storage', () {
      expect(localStorage.getSimulatedReelCount(dateKey), 0);
      expect(localStorage.getSimulatedDuration(dateKey), 0);

      // Simulate 1 reel watch on Instagram with 15s dwell time
      simDataSource.triggerSingleScroll(appName: 'instagram', dwellSeconds: 15);

      expect(localStorage.getSimulatedReelCount(dateKey), 1);
      expect(localStorage.getSimulatedDuration(dateKey), 15);
      expect(localStorage.getSimulatedAppReels('instagram', dateKey), 1);
      expect(localStorage.getSimulatedAppDuration('instagram', dateKey), 15);

      // Simulate another reel on TikTok with 20s dwell time
      simDataSource.triggerSingleScroll(appName: 'tiktok', dwellSeconds: 20);

      expect(localStorage.getSimulatedReelCount(dateKey), 2);
      expect(localStorage.getSimulatedDuration(dateKey), 35);
      expect(localStorage.getSimulatedAppReels('tiktok', dateKey), 1);
      expect(localStorage.getSimulatedAppDuration('tiktok', dateKey), 20);
    });

    test('Repository calculates aggregated daily stats, progress, and per-app stats', () async {
      // Simulate multiple reels across different apps
      simDataSource.triggerSingleScroll(appName: 'instagram', dwellSeconds: 10);
      simDataSource.triggerSingleScroll(appName: 'instagram', dwellSeconds: 12);
      simDataSource.triggerSingleScroll(appName: 'youtube', dwellSeconds: 25);

      final stats = await repository.getTodayStats();

      // Verify total reels & total time
      expect(stats.totalReels, 3);
      expect(stats.totalDurationSeconds, 47);
      expect(stats.dailyLimit, 10);
      expect(stats.progressToLimit, closeTo(0.3, 0.01));
      expect(stats.isLimitExceeded, isFalse);

      // Verify app-specific breakdown
      expect(stats.appStats['instagram']?.reelsCount, 2);
      expect(stats.appStats['instagram']?.durationSeconds, 22);
      expect(stats.appStats['youtube']?.reelsCount, 1);
      expect(stats.appStats['youtube']?.durationSeconds, 25);
      expect(stats.appStats['tiktok']?.reelsCount, 0);
      expect(stats.appStats['tiktok']?.durationSeconds, 0);
    });

    test('Reel limit exceed calculation triggers limit dialog flag', () async {
      final controller = ReelTrackerController(repository, simDataSource);
      // Wait for _init
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.state.stats.totalReels, 0);
      expect(controller.state.stats.isLimitExceeded, isFalse);
      expect(controller.state.showLimitExceededDialog, isFalse);

      // Simulate scrolling up to limit (10 reels)
      for (int i = 0; i < 10; i++) {
        controller.triggerSimulatedScroll(appName: 'instagram');
      }
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.state.stats.totalReels, 10);
      expect(controller.state.stats.isLimitExceeded, isTrue);
      expect(controller.state.showLimitExceededDialog, isTrue);

      controller.dispose();
    });

    test('Analytics repository calculates average dwell time and hourly distribution', () async {
      // 4 reels watched in total 80 seconds => 20 seconds average dwell
      simDataSource.triggerSingleScroll(appName: 'instagram', dwellSeconds: 20);
      simDataSource.triggerSingleScroll(appName: 'instagram', dwellSeconds: 20);
      simDataSource.triggerSingleScroll(appName: 'youtube', dwellSeconds: 20);
      simDataSource.triggerSingleScroll(appName: 'tiktok', dwellSeconds: 20);

      final analyticsRepo = AnalyticsRepositoryImpl(repository);
      final avgDwell = await analyticsRepo.getAverageDwellTimeSeconds();
      expect(avgDwell, 20.0);

      final hourly = await analyticsRepo.getTodayHourlyUsage();
      expect(hourly.length, 24);

      final currentHour = DateTime.now().hour;
      final futureHours = hourly.where((h) => h.hour > currentHour);
      for (final h in futureHours) {
        expect(h.reelsCount, 0);
        expect(h.durationSeconds, 0);
      }
    });

    test('Repository and controller fetch installed social apps from native platform', () async {
      final installed = await repository.getInstalledSocialApps();
      expect(installed, ['youtube']);

      final controller = ReelTrackerController(repository, simDataSource);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.state.installedApps, ['youtube']);
      controller.dispose();
    });
  });

  group('TrackedAppsGrid Platform Breakdown Dynamic Filtering', () {
    testWidgets('Renders single-app rich card when only 1 app is installed', (tester) async {
      final stats = DailyStats.initial(limit: 10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrackedAppsGrid(
              stats: stats,
              installedApps: const ['youtube'],
              isSimulationActive: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // YouTube Shorts should be displayed with Installed & Monitored badge
      expect(find.text('YouTube Shorts'), findsOneWidget);
      expect(find.text('Installed & Monitored'), findsOneWidget);

      // Instagram, TikTok, and Facebook Reels should NOT be displayed
      expect(find.text('Instagram Reels'), findsNothing);
      expect(find.text('TikTok'), findsNothing);
      expect(find.text('Facebook Reels'), findsNothing);
    });

    testWidgets('Renders multiple cards in grid when multiple apps are installed', (tester) async {
      final stats = DailyStats.initial(limit: 10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrackedAppsGrid(
              stats: stats,
              installedApps: const ['instagram', 'youtube'],
              isSimulationActive: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Instagram Reels'), findsOneWidget);
      expect(find.text('YouTube Shorts'), findsOneWidget);
      expect(find.text('TikTok'), findsNothing);
      expect(find.text('Facebook Reels'), findsNothing);
    });

    testWidgets('Renders informative empty state when 0 apps are installed and simulation is inactive', (tester) async {
      final stats = DailyStats.initial(limit: 10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrackedAppsGrid(
              stats: stats,
              installedApps: const [],
              isSimulationActive: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Target Apps Installed'), findsOneWidget);
      expect(find.textContaining('Install Instagram, TikTok, YouTube, or Facebook'), findsOneWidget);
    });
  });
}
