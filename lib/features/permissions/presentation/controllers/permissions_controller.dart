import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reels_count/features/permissions/data/datasources/permission_datasource.dart';
import 'package:reels_count/features/permissions/domain/entities/system_permission_state.dart';
import 'package:reels_count/features/reel_tracker/presentation/controllers/reel_tracker_controller.dart';

final permissionDataSourceProvider = Provider<PermissionDataSource>((ref) {
  final native = ref.watch(nativePlatformDataSourceProvider);
  return PermissionDataSource(native);
});

final permissionsControllerProvider =
    StateNotifierProvider<PermissionsController, SystemPermissionState>((ref) {
  final dataSource = ref.watch(permissionDataSourceProvider);
  final trackerController = ref.watch(reelTrackerControllerProvider.notifier);
  return PermissionsController(dataSource, trackerController);
});

class PermissionsController extends StateNotifier<SystemPermissionState> {
  final PermissionDataSource _dataSource;
  final ReelTrackerController _trackerController;

  PermissionsController(this._dataSource, this._trackerController)
      : super(SystemPermissionState.initial()) {
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    final status = await _dataSource.checkAllPermissions();
    if (!mounted) return;
    state = status;
    await _trackerController.refreshStats();
  }

  Future<void> openAccessibility() async {
    await _dataSource.requestAccessibility();
  }

  Future<void> openUsageStats() async {
    await _dataSource.requestUsageStats();
  }

  Future<void> openOverlay() async {
    await _dataSource.requestOverlay();
  }

  Future<void> openNotification() async {
    await _dataSource.requestNotification();
  }

  Future<void> openAppSettings() async {
    await _dataSource.openAppSettings();
  }
}
