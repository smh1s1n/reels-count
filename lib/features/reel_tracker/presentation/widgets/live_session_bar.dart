import 'package:flutter/material.dart';
import '../../../../core/constants/social_apps.dart';
import '../../../../core/theme/neumorphic.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/reel_session.dart';

class LiveSessionBar extends StatelessWidget {
  final ReelSession? session;

  const LiveSessionBar({super.key, this.session});

  @override
  Widget build(BuildContext context) {
    if (session == null || !session!.isActive) {
      return const SizedBox.shrink();
    }

    final appConfig = SocialAppConfig.fromKey(session!.activeApp);

    return NeuContainer(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 18,
      glowColor: appConfig.brandColor,
      border: Border.all(
        color: appConfig.brandColor.withValues(alpha: 0.5),
        width: 1.2,
      ),
      child: Row(
        children: [
          // Pulsing Dot Indicator
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: appConfig.brandColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: appConfig.brandColor.withValues(alpha: 0.8),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ACTIVE: ${appConfig.displayName.toUpperCase()}',
                  style: TextStyle(
                    color: appConfig.brandColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${session!.reelsCount} reels watched this session',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          NeuContainer(
            borderRadius: 10,
            isPressed: true,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              TimeFormatters.formatDigitalTimer(session!.durationSeconds),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
