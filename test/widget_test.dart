import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reels_count/core/constants/app_constants.dart';
import 'package:reels_count/features/reel_tracker/presentation/controllers/reel_tracker_controller.dart';
import 'package:reels_count/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('ReelsGuardApp smoke test and navigation verify', (WidgetTester tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(AppConstants.methodChannelName),
      (MethodCall methodCall) async {
        if (methodCall.method == 'isAccessibilityGranted') return false;
        if (methodCall.method == 'isUsageStatsGranted') return false;
        if (methodCall.method == 'isOverlayGranted') return false;
        if (methodCall.method == 'isNotificationGranted') return false;
        if (methodCall.method == 'getDailyStats') return <dynamic, dynamic>{};
        if (methodCall.method == 'getReelLimit') return 30;
        if (methodCall.method == 'getInstalledSocialApps') return <dynamic>['youtube'];
        return null;
      },
    );

    SharedPreferences.setMockInitialValues({
      'pref_daily_reel_limit': 30,
      'pref_simulation_mode': true,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const ReelsGuardApp(),
      ),
    );

    // Initial pump & settle
    await tester.pumpAndSettle();

    // Verify Title & Tagline are visible
    expect(find.text('ReelsGuard'), findsOneWidget);
    expect(find.text('Anti-Doomscroll Shield'), findsOneWidget);

    // Verify REELS TODAY counter exists
    expect(find.text('REELS TODAY'), findsOneWidget);

    // Verify Navigation bar destinations exist
    expect(find.text('Tracker'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Limits'), findsOneWidget);
    expect(find.text('Setup'), findsOneWidget);

    // Tap Analytics
    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();
    expect(find.text('DOOMSCROLL INDEX'), findsOneWidget);

    // Tap Limits
    await tester.tap(find.text('Limits'));
    await tester.pumpAndSettle();
    expect(find.text('Daily Reel Limit'), findsOneWidget);

    // Tap Setup
    await tester.tap(find.text('Setup'));
    await tester.pumpAndSettle();
    expect(find.text('System Permissions'), findsOneWidget);
  });
}
