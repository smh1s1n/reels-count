import 'package:flutter/material.dart';

enum PermissionType {
  accessibility,
  usageStats,
  overlay,
  notifications;

  String get title {
    switch (this) {
      case PermissionType.accessibility:
        return 'Accessibility Service';
      case PermissionType.usageStats:
        return 'Usage Access (UsageStats)';
      case PermissionType.overlay:
        return 'Display Over Other Apps';
      case PermissionType.notifications:
        return 'Live Progress Notifications';
    }
  }

  String get shortDescription {
    switch (this) {
      case PermissionType.accessibility:
        return 'Detects vertical scroll gestures and video transitions across short-form video apps to measure dwell time and reel counts.';
      case PermissionType.usageStats:
        return 'Measures continuous foreground time spent inside social media apps to calculate your daily Doomscroll Index without draining battery.';
      case PermissionType.overlay:
        return 'Presents the mindful breathing pause and break intervention directly over video feeds when your daily limit is exceeded.';
      case PermissionType.notifications:
        return 'Maintains an ambient foreground status bar counter showing your current reel count and daily limit progress in real time.';
    }
  }

  String get category {
    switch (this) {
      case PermissionType.accessibility:
        return 'Core Reel Counter & Wellness';
      case PermissionType.usageStats:
        return 'Screen Time & Analytics';
      case PermissionType.overlay:
        return 'Mindful Interventions & Breaks';
      case PermissionType.notifications:
        return 'Foreground Transparency & Service';
    }
  }

  String get badgeLabel {
    switch (this) {
      case PermissionType.accessibility:
        return 'ACCESSIBILITY_SERVICE API';
      case PermissionType.usageStats:
        return 'PACKAGE_USAGE_STATS';
      case PermissionType.overlay:
        return 'SYSTEM_ALERT_WINDOW';
      case PermissionType.notifications:
        return 'POST_NOTIFICATIONS';
    }
  }

  IconData get icon {
    switch (this) {
      case PermissionType.accessibility:
        return Icons.accessibility_new_rounded;
      case PermissionType.usageStats:
        return Icons.data_usage_rounded;
      case PermissionType.overlay:
        return Icons.layers_outlined;
      case PermissionType.notifications:
        return Icons.notifications_active_outlined;
    }
  }

  String get whyWeNeedThis {
    switch (this) {
      case PermissionType.accessibility:
        return 'ReelsGuard uses the Android AccessibilityService API solely to detect when you are actively viewing short-form video feeds (Instagram Reels, TikTok, YouTube Shorts, Facebook Reels) by analyzing vertical scrolling events and video container transitions. This enables accurate real-time counting of reels watched, measuring dwell time, and triggering mindful breathing pauses when your self-imposed limits are reached.';
      case PermissionType.usageStats:
        return 'Usage Access allows ReelsGuard to query system-level screen time for installed social video apps. This guarantees accurate tracking of total minutes spent watching reels throughout the day, providing an uncheatable Doomscroll Index and hourly usage distribution without excessive battery consumption.';
      case PermissionType.overlay:
        return 'When you exceed your self-set daily reel quota (e.g., 30 reels) or continuous watch limit, ReelsGuard presents a full-screen mindful pause over the active video app. This gentle friction helps interrupt hypnotic doomscrolling loops and encourages intentional digital awareness.';
      case PermissionType.notifications:
        return 'Under modern Android platform policies, background digital wellbeing monitors must remain fully transparent to the user via a persistent foreground notification. This notification shows your live reel counter in the status bar and prevents Android from killing the tracking process.';
    }
  }

  List<String> get dataAccessed {
    switch (this) {
      case PermissionType.accessibility:
        return const [
          'Foreground app package name to detect when a supported video feed is open (Instagram, TikTok, YouTube Shorts, Facebook).',
          'Vertical swipe and scroll gestures within video player containers to increment your reel counter.',
          'Active dwell duration per reel to compute average attention span and doomscroll severity.',
        ];
      case PermissionType.usageStats:
        return const [
          'Daily foreground timestamps and session duration for targeted social video applications.',
          'App launch frequency used to compute digital habit patterns.',
        ];
      case PermissionType.overlay:
        return const [
          'System authorization to draw a mindful breathing pause or limit reminder above other applications.',
        ];
      case PermissionType.notifications:
        return const [
          'Permission to post notifications and display real-time reel count updates in the system tray.',
        ];
    }
  }

  List<String> get dataNeverAccessed {
    switch (this) {
      case PermissionType.accessibility:
        return const [
          'We NEVER read, inspect, or store private messages, chats, DMs, or comments.',
          'We NEVER capture keystrokes, passwords, usernames, phone numbers, or credentials.',
          'We NEVER access photos, videos, microphone, audio, camera, or personal files.',
          '100% on-device processing: ZERO data is transmitted to external servers or third parties.',
        ];
      case PermissionType.usageStats:
        return const [
          'We NEVER inspect usage of personal apps, banking, health, email, or messaging services.',
          'We NEVER collect content or activity within any application.',
          'All screen time analytics remain strictly private on your local device.',
        ];
      case PermissionType.overlay:
        return const [
          'The overlay NEVER blocks system emergency calls, critical alerts, or password prompts.',
          'The overlay is completely free of ads, tracking pixels, or third-party SDKs.',
        ];
      case PermissionType.notifications:
        return const [
          'We NEVER send marketing notifications, promotional ads, or unnecessary spam.',
          'Notifications are generated locally and reflect your real-time reel counter only.',
        ];
    }
  }

  List<String> get settingsSteps {
    switch (this) {
      case PermissionType.accessibility:
        return const [
          'Tap "Agree & Open Settings" below to open Android Accessibility settings.',
          'Locate and tap "ReelsGuard" under "Downloaded apps" or "Installed services".',
          'Toggle the switch to ON and confirm the Android system prompt.',
        ];
      case PermissionType.usageStats:
        return const [
          'Tap "Agree & Open Settings" below to open Android Usage Access settings.',
          'Find and tap "ReelsGuard" in the list of applications.',
          'Toggle "Permit usage access" to ON.',
        ];
      case PermissionType.overlay:
        return const [
          'Tap "Agree & Open Settings" below to open "Display over other apps".',
          'Find and tap "ReelsGuard" in the application list.',
          'Toggle "Allow display over other apps" to ON.',
        ];
      case PermissionType.notifications:
        return const [
          'Tap "Agree & Open Settings" below to open App Notification settings.',
          'Ensure the master switch "All ReelsGuard notifications" is toggled ON.',
        ];
    }
  }

  bool get hasRestrictedSettingsHelp => this == PermissionType.accessibility;

  String? get restrictedSettingsNotice {
    if (!hasRestrictedSettingsHelp) return null;
    return 'On Android 13+ (API 33+), debug or sideloaded apps have accessibility restricted by default ("Restricted setting: For your security, this setting is currently unavailable").\n\nIf the toggle is greyed out: tap "Open App Info" below, tap the top-right three dots (⋮), select "Allow restricted settings", confirm with your device PIN/fingerprint, then return here.';
  }
}
