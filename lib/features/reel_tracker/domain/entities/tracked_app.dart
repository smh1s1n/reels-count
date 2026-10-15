import 'package:flutter/material.dart';
import '../../../../core/constants/social_apps.dart';

class TrackedApp {
  final String key;
  final String displayName;
  final Color brandColor;
  final IconData icon;
  final int reelsCount;
  final int durationSeconds;
  final bool isTrackingEnabled;

  const TrackedApp({
    required this.key,
    required this.displayName,
    required this.brandColor,
    required this.icon,
    required this.reelsCount,
    required this.durationSeconds,
    this.isTrackingEnabled = true,
  });

  TrackedApp copyWith({
    int? reelsCount,
    int? durationSeconds,
    bool? isTrackingEnabled,
  }) {
    return TrackedApp(
      key: key,
      displayName: displayName,
      brandColor: brandColor,
      icon: icon,
      reelsCount: reelsCount ?? this.reelsCount,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isTrackingEnabled: isTrackingEnabled ?? this.isTrackingEnabled,
    );
  }

  factory TrackedApp.fromConfig(SocialAppConfig config, {int reels = 0, int duration = 0, bool enabled = true}) {
    return TrackedApp(
      key: config.key,
      displayName: config.displayName,
      brandColor: config.brandColor,
      icon: config.icon,
      reelsCount: reels,
      durationSeconds: duration,
      isTrackingEnabled: enabled,
    );
  }
}
