import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neumorphic.dart';
import '../../domain/entities/permission_type.dart';
import '../../domain/entities/system_permission_state.dart';
import '../controllers/permissions_controller.dart';
import '../widgets/permission_disclosure_bottom_sheet.dart';
import '../widgets/permission_step_tile.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(permissionsControllerProvider.notifier).checkPermissions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(permissionsControllerProvider.notifier).checkPermissions();
    }
  }

  PermissionType? _getFirstUngranted(SystemPermissionState status) {
    if (!status.isAccessibilityGranted) return PermissionType.accessibility;
    if (!status.isUsageStatsGranted) return PermissionType.usageStats;
    if (!status.isOverlayGranted) return PermissionType.overlay;
    if (!status.isNotificationGranted) return PermissionType.notifications;
    return null;
  }

  VoidCallback _getRequestCallback(
      PermissionType type, PermissionsController controller) {
    switch (type) {
      case PermissionType.accessibility:
        return controller.openAccessibility;
      case PermissionType.usageStats:
        return controller.openUsageStats;
      case PermissionType.overlay:
        return controller.openOverlay;
      case PermissionType.notifications:
        return controller.openNotification;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(permissionsControllerProvider);
    final controller = ref.read(permissionsControllerProvider.notifier);
    final firstUngranted = _getFirstUngranted(status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Permissions'),
        actions: [
          IconButton(
            tooltip: 'Refresh Status',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.checkPermissions(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Setup Progress Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: NeuTheme.extrudedDecoration(
              borderRadius: 20,
              glowColor: status.isFullyConfigured
                  ? AppTheme.accentGreen
                  : AppTheme.primaryTeal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          status.isFullyConfigured
                              ? Icons.verified_user_rounded
                              : Icons.security_rounded,
                          color: status.isFullyConfigured
                              ? AppTheme.accentGreen
                              : AppTheme.primaryTeal,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          status.isFullyConfigured
                              ? 'SHIELD FULLY ACTIVE'
                              : 'SETUP PROGRESS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: status.isFullyConfigured
                                ? AppTheme.accentGreen
                                : AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${status.grantedCount} / ${status.totalCount} Active',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 12,
                  padding: const EdgeInsets.all(2),
                  decoration: NeuTheme.stampedDecoration(
                    borderRadius: 8,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: status.progress,
                      minHeight: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        status.isFullyConfigured
                            ? AppTheme.accentGreen
                            : AppTheme.primaryTeal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  status.isFullyConfigured
                      ? 'All permissions active. ReelsGuard is continuously monitoring reels and safeguarding your attention.'
                      : 'Configure the essential permissions below to unlock automated reel counting and mindful break interventions.',
                  style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                ),
                if (firstUngranted != null) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: Text(
                        'Enable Next: ${firstUngranted.title}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: () {
                        PermissionDisclosureBottomSheet.show(
                          context: context,
                          permissionType: firstUngranted,
                          isGranted: false,
                          onAgree: _getRequestCallback(firstUngranted, controller),
                          onOpenAppSettings: controller.openAppSettings,
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 1. Accessibility Service
          PermissionStepTile(
            permissionType: PermissionType.accessibility,
            isGranted: status.isAccessibilityGranted,
            onRequest: () => controller.openAccessibility(),
            onOpenAppSettings: () => controller.openAppSettings(),
          ),

          const SizedBox(height: 14),

          // 2. Usage Access
          PermissionStepTile(
            permissionType: PermissionType.usageStats,
            isGranted: status.isUsageStatsGranted,
            onRequest: () => controller.openUsageStats(),
            onOpenAppSettings: () => controller.openAppSettings(),
          ),

          const SizedBox(height: 14),

          // 3. Display Over Other Apps
          PermissionStepTile(
            permissionType: PermissionType.overlay,
            isGranted: status.isOverlayGranted,
            onRequest: () => controller.openOverlay(),
            onOpenAppSettings: () => controller.openAppSettings(),
          ),

          const SizedBox(height: 14),

          // 4. Notifications
          PermissionStepTile(
            permissionType: PermissionType.notifications,
            isGranted: status.isNotificationGranted,
            onRequest: () => controller.openNotification(),
            onOpenAppSettings: () => controller.openAppSettings(),
          ),

          const SizedBox(height: 22),

          // Android 13+ Restricted Settings Quick Assistance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: NeuTheme.extrudedDecoration(
              borderRadius: 16,
              distance: 3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.help_outline_rounded,
                        color: AppTheme.accentAmber, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'SETTINGS GREYED OUT ON ANDROID 13+?',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppTheme.accentAmber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'If Accessibility is disabled with "Restricted setting":\n1. Tap "Open App Info" below.\n2. Tap the top-right 3 dots (⋮) and tap "Allow restricted settings".\n3. Authenticate with PIN/fingerprint, then return and enable Accessibility.',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppTheme.darkBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.settings_outlined, size: 16),
                  label: const Text(
                    'Open ReelsGuard App Info',
                    style: TextStyle(fontSize: 12),
                  ),
                  onPressed: () => controller.openAppSettings(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Google Play Policy & Data Safety Guarantee
          Container(
            padding: const EdgeInsets.all(16),
            decoration: NeuTheme.extrudedDecoration(
              borderRadius: 16,
              distance: 3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.privacy_tip_outlined,
                        color: AppTheme.primaryPurple, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'GOOGLE PLAY POLICY & PRIVACY GUARANTEE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'ReelsGuard strictly adheres to Google Play Console Accessibility API and User Data Policies:\n• Zero remote data transmission: all scroll event detection, timers, and metrics are computed 100% locally on your device.\n• No access to private messages, keystrokes, personal accounts, credentials, or media files.\n• The AccessibilityService API is used exclusively to detect vertical scroll transitions in supported video containers.',
                  style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.45),
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
