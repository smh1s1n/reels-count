import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neumorphic.dart';
import '../controllers/limits_controller.dart';
import '../widgets/limit_slider_card.dart';
import '../widgets/mindful_break_dialog.dart';

class LimitsScreen extends ConsumerWidget {
  const LimitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(limitsControllerProvider);
    final controller = ref.read(limitsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Limits & Interventions'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                LimitSliderCard(
                  title: 'Daily Reel Limit',
                  subtitle: 'Total reels allowed across all social apps',
                  value: state.limits.dailyReelCount,
                  min: 5,
                  max: 100,
                  unit: 'reels',
                  onChanged: (val) => controller.updateDailyLimit(val),
                ),
                const SizedBox(height: 16),
                LimitSliderCard(
                  title: 'Continuous Session Limit',
                  subtitle: 'Trigger mindful break after consecutive reels',
                  value: state.limits.sessionReelCount,
                  min: 5,
                  max: 40,
                  unit: 'reels',
                  onChanged: (val) => controller.updateSessionLimit(val),
                ),
                const SizedBox(height: 16),
                LimitSliderCard(
                  title: 'Max Daily Watch Time',
                  subtitle: 'Cumulative screen time in short-video containers',
                  value: state.limits.dailyMinutes,
                  min: 10,
                  max: 180,
                  unit: 'mins',
                  onChanged: (val) => controller.updateDailyMinutes(val),
                ),
                const SizedBox(height: 24),
                const Text(
                  'INTERVENTION METHODS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 12),
                NeuContainer(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mindful Screen Overlay',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Display breathing pause directly over Instagram/TikTok',
                                  style: TextStyle(color: Colors.white54, fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          NeuSwitch(
                            value: state.limits.isMindfulOverlayEnabled,
                            activeColor: NeuTheme.accentTeal,
                            onChanged: (val) => controller.toggleOverlay(val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      NeuContainer(
                        isPressed: true,
                        borderRadius: 2,
                        height: 1.5,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Haptic Nudge',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Subtle vibration pulse on every 10th reel scrolled',
                                  style: TextStyle(color: Colors.white54, fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          NeuSwitch(
                            value: state.limits.isVibrationAlertEnabled,
                            activeColor: NeuTheme.accentTeal,
                            onChanged: (val) => controller.toggleVibration(val),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                NeuButton(
                  borderRadius: 18,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => MindfulBreakDialog(
                        reelsCount: state.limits.dailyReelCount,
                        onDismiss: () => Navigator.pop(ctx),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.remove_red_eye_outlined, size: 20, color: NeuTheme.accentTeal),
                      SizedBox(width: 8),
                      Text(
                        'Preview Mindful Break Dialog',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}
