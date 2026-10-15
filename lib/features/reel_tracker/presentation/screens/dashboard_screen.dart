import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../limits_and_interventions/presentation/controllers/limits_controller.dart';
import '../../../limits_and_interventions/presentation/screens/limits_screen.dart';
import '../../../limits_and_interventions/presentation/widgets/mindful_break_dialog.dart';
import '../../../permissions/presentation/screens/permissions_screen.dart';
import '../controllers/reel_tracker_controller.dart';
import '../widgets/live_reel_counter_hero.dart';
import '../widgets/live_session_bar.dart';
import '../widgets/simulation_toggle_widget.dart';
import '../widgets/tracked_apps_grid.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      // Auto-refresh stats and installed social apps when user returns to app
      ref.read(reelTrackerControllerProvider.notifier).refreshStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reelTrackerControllerProvider);
    final controller = ref.read(reelTrackerControllerProvider.notifier);

    // Show intervention modal when limit is exceeded
    ref.listen(reelTrackerControllerProvider, (previous, next) {
      if (next.showLimitExceededDialog && !(previous?.showLimitExceededDialog ?? false)) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => MindfulBreakDialog(
            reelsCount: next.stats.totalReels,
            onDismiss: () {
              Navigator.pop(ctx);
              controller.dismissLimitExceededDialog();
            },
            onExtendLimit: () {
              ref.read(limitsControllerProvider.notifier).updateDailyLimit(next.stats.dailyLimit + 5);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mindful Grace Period: Added +5 reels to today\'s limit.'),
                  backgroundColor: AppTheme.primaryTeal,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            onActivitySelected: (activity) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Awesome choice! Step away to $activity now.'),
                  backgroundColor: AppTheme.accentGreen,
                  duration: const Duration(seconds: 4),
                ),
              );
            },
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield_outlined, color: AppTheme.primaryTeal, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ReelsGuard',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                Text(
                  'Anti-Doomscroll Shield',
                  style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.shield,
              color: state.isAccessibilityEnabled ? AppTheme.accentGreen : AppTheme.accentAmber,
            ),
            tooltip: 'System Permissions',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PermissionsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset Today Stats',
            onPressed: () {
              _showResetConfirmDialog(context, controller);
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
                await controller.refreshStats();
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Active reels session notification bar (if watching right now)
                  LiveSessionBar(session: state.activeSession),

                  // Circular Hero Reel Counter
                  LiveReelCounterHero(
                    stats: state.stats,
                    onLimitTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LimitsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Simulation Engine Card (for instant test without switching apps)
                  SimulationControlCard(
                    state: state,
                    controller: controller,
                  ),
                  const SizedBox(height: 24),

                  // Tracked Apps Grid (filtered to installed apps or apps with activity)
                  TrackedAppsGrid(
                    stats: state.stats,
                    installedApps: state.installedApps,
                    isSimulationActive: state.isSimulationActive,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  void _showResetConfirmDialog(BuildContext context, ReelTrackerController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Today\'s Stats?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will clear today\'s reel counter and time spent across all platforms.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () {
              Navigator.pop(ctx);
              controller.resetStats();
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
