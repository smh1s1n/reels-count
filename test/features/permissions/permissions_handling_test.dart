import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reels_count/core/constants/app_constants.dart';
import 'package:reels_count/core/theme/app_theme.dart';
import 'package:reels_count/features/permissions/domain/entities/permission_type.dart';
import 'package:reels_count/features/permissions/domain/entities/system_permission_state.dart';
import 'package:reels_count/features/permissions/presentation/screens/permissions_screen.dart';
import 'package:reels_count/features/permissions/presentation/widgets/permission_disclosure_bottom_sheet.dart';
import 'package:reels_count/features/permissions/presentation/widgets/permission_step_tile.dart';
import 'package:reels_count/features/reel_tracker/presentation/controllers/reel_tracker_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SystemPermissionState & PermissionType Entities', () {
    test('SystemPermissionState calculations and progress', () {
      const state0 = SystemPermissionState(
        isAccessibilityGranted: false,
        isUsageStatsGranted: false,
        isOverlayGranted: false,
        isNotificationGranted: false,
      );
      expect(state0.grantedCount, 0);
      expect(state0.totalCount, 4);
      expect(state0.progress, 0.0);
      expect(state0.isFullyConfigured, isFalse);

      final state2 = state0.copyWith(
        isAccessibilityGranted: true,
        isUsageStatsGranted: true,
      );
      expect(state2.grantedCount, 2);
      expect(state2.progress, 0.5);
      expect(state2.isFullyConfigured, isFalse);

      final state4 = state2.copyWith(
        isOverlayGranted: true,
        isNotificationGranted: true,
      );
      expect(state4.grantedCount, 4);
      expect(state4.progress, 1.0);
      expect(state4.isFullyConfigured, isTrue);
    });

    test('PermissionType metadata complies with Google Play policies', () {
      for (final type in PermissionType.values) {
        expect(type.title.isNotEmpty, isTrue);
        expect(type.whyWeNeedThis.isNotEmpty, isTrue);
        expect(type.dataAccessed.isNotEmpty, isTrue);
        expect(type.dataNeverAccessed.isNotEmpty, isTrue);
        expect(type.settingsSteps.isNotEmpty, isTrue);
        expect(type.badgeLabel.isNotEmpty, isTrue);
      }

      // Accessibility specific checks
      expect(PermissionType.accessibility.hasRestrictedSettingsHelp, isTrue);
      expect(PermissionType.accessibility.restrictedSettingsNotice, isNotNull);
      expect(
        PermissionType.accessibility.whyWeNeedThis,
        contains('AccessibilityService API'),
      );
    });
  });

  group('PermissionDisclosureBottomSheet Widget Tests', () {
    testWidgets('Renders Google Play disclosure, data accessed, and affirmative action',
        (WidgetTester tester) async {
      bool agreed = false;
      bool openSettingsCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  PermissionDisclosureBottomSheet.show(
                    context: context,
                    permissionType: PermissionType.accessibility,
                    isGranted: false,
                    onAgree: () => agreed = true,
                    onOpenAppSettings: () => openSettingsCalled = true,
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      // Open bottom sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Verify Google Play Prominent In-App Disclosure elements
      expect(find.text('Prominent In-App Disclosure'), findsOneWidget);
      expect(find.text('WHY REELSGUARD NEEDS THIS'), findsOneWidget);
      expect(find.text('DATA ACCESSED (FUNCTIONAL USE ONLY)'), findsOneWidget);
      expect(find.text('DATA NEVER ACCESSED (PRIVACY SAFEGUARD)'), findsOneWidget);
      expect(find.text('HOW TO ENABLE IN ANDROID SETTINGS'), findsOneWidget);
      expect(find.textContaining('Restricted Setting'), findsAtLeastNWidgets(1));

      // Verify affirmative consent buttons
      expect(find.text('Agree & Open Settings'), findsOneWidget);
      expect(find.text('Not Now'), findsOneWidget);

      // Tap Agree & Open Settings
      await tester.tap(find.text('Agree & Open Settings'));
      await tester.pumpAndSettle();

      expect(agreed, isTrue);
      expect(openSettingsCalled, isFalse);
    });

    testWidgets('Tapping Not Now dismisses the bottom sheet without callback trigger',
        (WidgetTester tester) async {
      bool agreed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  PermissionDisclosureBottomSheet.show(
                    context: context,
                    permissionType: PermissionType.usageStats,
                    isGranted: false,
                    onAgree: () => agreed = true,
                    onOpenAppSettings: () {},
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Prominent In-App Disclosure'), findsOneWidget);

      await tester.tap(find.text('Not Now'));
      await tester.pumpAndSettle();

      expect(agreed, isFalse);
      expect(find.text('Prominent In-App Disclosure'), findsNothing);
    });
  });

  group('PermissionStepTile Widget Tests', () {
    testWidgets('Tapping tile opens disclosure bottom sheet', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: PermissionStepTile(
              permissionType: PermissionType.overlay,
              isGranted: false,
              onRequest: () {},
              onOpenAppSettings: () {},
            ),
          ),
        ),
      );

      expect(find.text('Display Over Other Apps'), findsOneWidget);
      expect(find.text('Review & Enable'), findsOneWidget);

      // Tap the "Review & Enable" button
      await tester.tap(find.text('Review & Enable'));
      await tester.pumpAndSettle();

      // Bottom sheet is displayed
      expect(find.text('Prominent In-App Disclosure'), findsOneWidget);
      expect(find.text('SYSTEM_ALERT_WINDOW'), findsNWidgets(2));
    });

    testWidgets('When permission is granted, tile shows Active chip',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: PermissionStepTile(
              permissionType: PermissionType.notifications,
              isGranted: true,
              onRequest: () {},
              onOpenAppSettings: () {},
            ),
          ),
        ),
      );

      expect(find.text('Live Progress Notifications'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Review & Enable'), findsNothing);
    });
  });

  group('PermissionsScreen Integration & Lifecycle Tests', () {
    testWidgets('Displays Setup Progress and all 4 permissions',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(AppConstants.methodChannelName),
        (MethodCall methodCall) async {
          if (methodCall.method == 'isAccessibilityGranted') return true;
          if (methodCall.method == 'isUsageStatsGranted') return false;
          if (methodCall.method == 'isOverlayGranted') return false;
          if (methodCall.method == 'isNotificationGranted') return true;
          if (methodCall.method == 'getDailyStats') return <dynamic, dynamic>{};
          if (methodCall.method == 'getReelLimit') return 30;
          return null;
        },
      );

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const PermissionsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Setup Progress displays 2 / 4 Active
      expect(find.text('2 / 4 Active'), findsOneWidget);
      expect(find.text('Enable Next: Usage Access (UsageStats)'), findsOneWidget);

      // Check all 4 permission tiles are rendered
      expect(find.text('Accessibility Service'), findsOneWidget);
      expect(find.text('Usage Access (UsageStats)'), findsOneWidget);
      expect(find.text('Display Over Other Apps'), findsOneWidget);
      expect(find.text('Live Progress Notifications'), findsOneWidget);

      // Check Google Play Policy Guarantee
      expect(find.text('GOOGLE PLAY POLICY & PRIVACY GUARANTEE'), findsOneWidget);

      // Check Restricted Settings Info Card
      expect(find.text('SETTINGS GREYED OUT ON ANDROID 13+?'), findsOneWidget);
    });
  });
}
