import 'dart:async';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';

class NativePlatformDataSource {
  static const MethodChannel _methodChannel = MethodChannel(AppConstants.methodChannelName);
  static const EventChannel _eventChannel = EventChannel(AppConstants.eventChannelName);

  Stream<Map<String, dynamic>>? _eventStream;

  Stream<Map<String, dynamic>> getEventStream() {
    _eventStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => Map<String, dynamic>.from(event as Map));
    return _eventStream!;
  }

  Future<bool> isAccessibilityGranted() async {
    try {
      final bool? result = await _methodChannel.invokeMethod<bool>('isAccessibilityGranted');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openAccessibilitySettings() async {
    try {
      await _methodChannel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  Future<bool> isUsageStatsGranted() async {
    try {
      final bool? result = await _methodChannel.invokeMethod<bool>('isUsageStatsGranted');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openUsageStatsSettings() async {
    try {
      await _methodChannel.invokeMethod('openUsageStatsSettings');
    } catch (_) {}
  }

  Future<bool> isOverlayGranted() async {
    try {
      final bool? result = await _methodChannel.invokeMethod<bool>('isOverlayGranted');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openOverlaySettings() async {
    try {
      await _methodChannel.invokeMethod('openOverlaySettings');
    } catch (_) {}
  }

  Future<bool> isNotificationGranted() async {
    try {
      final bool? result = await _methodChannel.invokeMethod<bool>('isNotificationGranted');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openNotificationSettings() async {
    try {
      await _methodChannel.invokeMethod('openNotificationSettings');
    } catch (_) {}
  }

  Future<void> openAppSettings() async {
    try {
      await _methodChannel.invokeMethod('openAppSettings');
    } catch (_) {}
  }

  Future<List<String>> getInstalledSocialApps() async {
    try {
      final List<dynamic>? result =
          await _methodChannel.invokeMethod<List<dynamic>>('getInstalledSocialApps');
      return result?.map((e) => e.toString()).toList() ?? [];
    } on MissingPluginException {
      return const ['instagram', 'tiktok', 'youtube', 'facebook'];
    } catch (_) {
      return [];
    }
  }

  Future<Map<dynamic, dynamic>> getDailyStats() async {
    try {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getDailyStats');
      return result ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<void> resetDailyStats() async {
    try {
      await _methodChannel.invokeMethod('resetDailyStats');
    } catch (_) {}
  }

  Future<void> setReelLimit(int limit) async {
    try {
      await _methodChannel.invokeMethod('setReelLimit', {'limit': limit});
    } catch (_) {}
  }

  Future<int> getReelLimit() async {
    try {
      final int? limit = await _methodChannel.invokeMethod<int>('getReelLimit');
      return limit ?? AppConstants.defaultDailyReelLimit;
    } catch (_) {
      return AppConstants.defaultDailyReelLimit;
    }
  }

  Future<Map<String, dynamic>> checkPendingIntervention() async {
    try {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('checkPendingIntervention');
      if (result != null) {
        return Map<String, dynamic>.from(result);
      }
      return {'shouldOpen': false, 'reelsCount': 0};
    } catch (_) {
      return {'shouldOpen': false, 'reelsCount': 0};
    }
  }

  Future<void> resetInterventionTrigger() async {
    try {
      await _methodChannel.invokeMethod('resetInterventionTrigger');
    } catch (_) {}
  }

  Future<bool> launchSms({String? message}) async {
    try {
      final bool? res = await _methodChannel.invokeMethod<bool>('launchSms', {
        'message': message ?? 'Hey! Just taking a quick break from screens and wanted to say hi.',
      });
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> launchDialer() async {
    try {
      final bool? res = await _methodChannel.invokeMethod<bool>('launchDialer');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> shareText(String text) async {
    try {
      final bool? res = await _methodChannel.invokeMethod<bool>('shareText', {'text': text});
      return res ?? false;
    } catch (_) {
      return false;
    }
  }
}
