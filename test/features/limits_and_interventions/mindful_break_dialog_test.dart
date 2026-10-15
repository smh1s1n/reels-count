import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reels_count/features/limits_and_interventions/presentation/widgets/mindful_break_dialog.dart';
import 'package:reels_count/features/limits_and_interventions/presentation/widgets/mindful_activities_sheets.dart';

void main() {
  group('MindfulBreakDialog Interactive UX Tests', () {
    testWidgets('Renders reel count, breathing orb, and segmented tab switcher', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MindfulBreakDialog(
              reelsCount: 25,
              onDismiss: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Reel count warning
      expect(find.text('DAILY LIMIT: 25 REELS REACHED'), findsOneWidget);
      expect(find.text('Pause the Autopilot Loop'), findsOneWidget);

      // Segmented Tabs
      expect(find.text('Guided Breath'), findsOneWidget);
      expect(find.text('Mindful Swap'), findsOneWidget);

      // Guided breath initial phase
      expect(find.text('INHALE'), findsOneWidget);
      expect(find.text('4s'), findsOneWidget);
      expect(find.text('Breath 1 of 3'), findsOneWidget);

      // Snooze button exists
      expect(find.text('+5 Reels Snooze'), findsOneWidget);
    });

    testWidgets('Tapping breathing orb pauses and resumes guided breathwork', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MindfulBreakDialog(
              reelsCount: 30,
              onDismiss: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('INHALE'), findsOneWidget);

      // Tap the breathing orb
      await tester.tap(find.text('INHALE'));
      await tester.pump();

      // Should now be paused
      expect(find.text('PAUSED'), findsOneWidget);
      expect(find.text('Tap to play'), findsOneWidget);
      expect(find.text('Breathing guide paused. Tap circle to resume.'), findsOneWidget);

      // Tap again to resume
      await tester.tap(find.text('PAUSED'));
      await tester.pump();
      expect(find.text('PAUSED'), findsNothing);
    });

    testWidgets('Switching to Mindful Swap tab shows dopamine replacement activities', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      String? selectedActivity;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MindfulBreakDialog(
              reelsCount: 30,
              onDismiss: () {},
              onActivitySelected: (act) => selectedActivity = act,
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap Mindful Swap tab
      await tester.tap(find.text('Mindful Swap'));
      await tester.pumpAndSettle();

      // Activities should be visible
      expect(find.text('CHOOSE A QUICK DOPAMINE REPLACEMENT'), findsOneWidget);
      expect(find.text('Hydrate Body'), findsOneWidget);
      expect(find.text('Quick Stretch'), findsOneWidget);
      expect(find.text('Rest Your Eyes'), findsOneWidget);
      expect(find.text('Connect Real'), findsOneWidget);

      // Tap Hydrate Body
      await tester.tap(find.text('Hydrate Body'));
      await tester.pumpAndSettle();

      expect(find.text('Step away to hydrate body now.'), findsOneWidget);
      expect(find.text('Commit & Step Away'), findsOneWidget);

      // Tap primary action
      await tester.tap(find.text('Commit & Step Away'));
      await tester.pump();

      expect(selectedActivity, 'Hydrate Body');
    });

    testWidgets('Snooze button triggers onExtendLimit and dismisses dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool snoozeTriggered = false;
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MindfulBreakDialog(
              reelsCount: 30,
              onDismiss: () => dismissed = true,
              onExtendLimit: () => snoozeTriggered = true,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('+5 Reels Snooze'));
      await tester.pump();

      expect(snoozeTriggered, isTrue);
      expect(dismissed, isTrue);
    });

    testWidgets('Tapping START opens interactive Hydration sheet and logs glass', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MindfulBreakDialog(
              reelsCount: 20,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );
      await tester.pump();

      // Go to swap tab
      await tester.tap(find.text('Mindful Swap'));
      await tester.pumpAndSettle();

      // Tap Hydrate Body
      await tester.tap(find.text('Hydrate Body'));
      await tester.pumpAndSettle();

      // Tap START button
      expect(find.text('START'), findsOneWidget);
      await tester.tap(find.text('START'));
      await tester.pumpAndSettle();

      // Verify Hydration sheet opened
      expect(find.text('BRAIN HYDRATION RESET'), findsOneWidget);
      expect(find.text('+ Log 1 Glass (250ml)'), findsOneWidget);

      // Tap log 1 glass
      await tester.tap(find.text('+ Log 1 Glass (250ml)'));
      await tester.pump();

      // Tap Done & Step Away
      await tester.tap(find.text('✓ Done & Step Away'));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    testWidgets('Interactive Quick Stretch sheet displays stages and controls', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickStretchActivitySheet(
              onComplete: () => completed = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('1-MINUTE GUIDED STRETCH'), findsOneWidget);
      expect(find.text('Neck & Trapezius Rolls'), findsOneWidget);
      expect(find.text('Next Stretch'), findsOneWidget);

      // Tap next stretch
      await tester.tap(find.text('Next Stretch'));
      await tester.pump();
      expect(find.text('Shoulder & Chest Openers'), findsOneWidget);

      // Tap next stretch to stage 3
      await tester.tap(find.text('Next Stretch'));
      await tester.pump();
      expect(find.text('Overhead Reach & Wrist Flex'), findsOneWidget);

      // Skip to end
      await tester.tap(find.text('Next Stretch'));
      await tester.pump();
      expect(find.text('✨ Stretch Complete!'), findsOneWidget);

      await tester.tap(find.text('Complete & Step Away'));
      await tester.pump();
      expect(completed, isTrue);
    });

    testWidgets('Interactive Eye Rest sheet displays 20-20-20 optometric guidance', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EyeRestActivitySheet(
              onComplete: () => completed = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('THE 20-20-20 OPTOMETRIC RULE'), findsOneWidget);
      expect(find.text('Look 20ft Away for 20s'), findsOneWidget);

      await tester.tap(find.text('Skip & Finish'));
      await tester.pump();
      expect(completed, isTrue);
    });

    testWidgets('Interactive Connect Real sheet renders message templates and channels', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectRealActivitySheet(
              onComplete: () => dismissed = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('REAL HUMAN CONNECTION'), findsOneWidget);
      expect(find.text('Connect With a Friend'), findsOneWidget);
      expect(find.text('Text Friend'), findsOneWidget);
      expect(find.text('Call Friend'), findsOneWidget);
      expect(find.text('Share Note via Any App'), findsOneWidget);

      await tester.tap(find.text('Dismiss'));
      await tester.pump();
      expect(dismissed, isTrue);
    });
  });
}
