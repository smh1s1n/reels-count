import 'package:flutter/material.dart';

enum SocialAppType {
  instagram,
  tiktok,
  youtube,
  facebook,
  unknown,
}

class SocialAppConfig {
  final SocialAppType type;
  final String key;
  final String displayName;
  final String packageName;
  final Color brandColor;
  final IconData icon;

  const SocialAppConfig({
    required this.type,
    required this.key,
    required this.displayName,
    required this.packageName,
    required this.brandColor,
    required this.icon,
  });

  static const List<SocialAppConfig> supportedApps = [
    SocialAppConfig(
      type: SocialAppType.instagram,
      key: 'instagram',
      displayName: 'Instagram Reels',
      packageName: 'com.instagram.android',
      brandColor: Color(0xFFE1306C),
      icon: Icons.camera_alt_outlined,
    ),
    SocialAppConfig(
      type: SocialAppType.tiktok,
      key: 'tiktok',
      displayName: 'TikTok Videos',
      packageName: 'com.zhiliaoapp.musically',
      brandColor: Color(0xFF00F2FE),
      icon: Icons.music_note_outlined,
    ),
    SocialAppConfig(
      type: SocialAppType.youtube,
      key: 'youtube',
      displayName: 'YouTube Shorts',
      packageName: 'com.google.android.youtube',
      brandColor: Color(0xFFFF0000),
      icon: Icons.play_arrow_outlined,
    ),
    SocialAppConfig(
      type: SocialAppType.facebook,
      key: 'facebook',
      displayName: 'Facebook Reels',
      packageName: 'com.facebook.katana',
      brandColor: Color(0xFF1877F2),
      icon: Icons.facebook_outlined,
    ),
  ];

  static SocialAppConfig fromKey(String key) {
    return supportedApps.firstWhere(
      (app) => app.key.toLowerCase() == key.toLowerCase(),
      orElse: () => SocialAppConfig(
        type: SocialAppType.unknown,
        key: key,
        displayName: key.toUpperCase(),
        packageName: '',
        brandColor: Colors.grey,
        icon: Icons.video_collection_outlined,
      ),
    );
  }
}
