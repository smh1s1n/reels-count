import 'package:reels_count/features/permissions/domain/entities/system_permission_state.dart';
import 'package:reels_count/features/reel_tracker/data/datasources/native_platform_datasource.dart';

class PermissionDataSource {
  final NativePlatformDataSource _native;

  PermissionDataSource(this._native);

  Future<SystemPermissionState> checkAllPermissions() async {
    final access = await _native.isAccessibilityGranted();
    final usage = await _native.isUsageStatsGranted();
    final overlay = await _native.isOverlayGranted();
    final notification = await _native.isNotificationGranted();

    return SystemPermissionState(
      isAccessibilityGranted: access,
      isUsageStatsGranted: usage,
      isOverlayGranted: overlay,
      isNotificationGranted: notification,
    );
  }

  Future<void> requestAccessibility() => _native.openAccessibilitySettings();
  Future<void> requestUsageStats() => _native.openUsageStatsSettings();
  Future<void> requestOverlay() => _native.openOverlaySettings();
  Future<void> requestNotification() => _native.openNotificationSettings();
  Future<void> openAppSettings() => _native.openAppSettings();
}
