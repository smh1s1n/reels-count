import 'package:flutter/material.dart';
import '../../../../core/constants/social_apps.dart';
import '../../../../core/theme/neumorphic.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/daily_stats.dart';
import '../../domain/entities/tracked_app.dart';

class TrackedAppsGrid extends StatelessWidget {
  final DailyStats stats;
  final List<String> installedApps;
  final bool isSimulationActive;

  const TrackedAppsGrid({
    super.key,
    required this.stats,
    this.installedApps = const [],
    this.isSimulationActive = false,
  });

  List<SocialAppConfig> _getAppsToDisplay() {
    // If simulation mode is active and no apps are installed, show all so user can test
    if (isSimulationActive && installedApps.isEmpty) {
      return SocialAppConfig.supportedApps;
    }

    // Filter apps that are installed on the device OR have active tracked reels > 0
    final filtered = SocialAppConfig.supportedApps.where((config) {
      final isInstalled = installedApps.contains(config.key);
      final hasActivity = (stats.appStats[config.key]?.reelsCount ?? 0) > 0;
      return isInstalled || hasActivity;
    }).toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final appsToDisplay = _getAppsToDisplay();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PLATFORM BREAKDOWN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: Colors.white60,
              ),
            ),
            if (installedApps.isNotEmpty)
              NeuContainer(
                borderRadius: 12,
                isPressed: true,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  '${installedApps.length} Installed',
                  style: const TextStyle(
                    fontSize: 11,
                    color: NeuTheme.accentGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Case 1: No supported social media apps installed and no activity
        if (appsToDisplay.isEmpty)
          NeuContainer(
            borderRadius: 22,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                NeuContainer(
                  borderRadius: 14,
                  isPressed: true,
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    Icons.install_mobile_rounded,
                    color: Colors.white54,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No Target Apps Installed',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Install Instagram, TikTok, YouTube, or Facebook to track video scrolling, or turn on Simulation Mode above.',
                        style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )

        // Case 2: Exactly 1 app installed -> Full width rich card
        else if (appsToDisplay.length == 1)
          _buildSingleAppCard(appsToDisplay.first)

        // Case 3: Multiple apps installed -> 2-Column Grid
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemCount: appsToDisplay.length,
            itemBuilder: (context, index) {
              final config = appsToDisplay[index];
              return _buildGridCard(config);
            },
          ),
      ],
    );
  }

  Widget _buildSingleAppCard(SocialAppConfig config) {
    final TrackedApp app =
        stats.appStats[config.key] ?? TrackedApp.fromConfig(config);
    final percentage = stats.totalReels > 0
        ? (app.reelsCount / stats.totalReels * 100).round()
        : 0;

    return NeuContainer(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      glowColor: config.brandColor.withValues(alpha: 0.15),
      border: Border.all(
        color: config.brandColor.withValues(alpha: 0.35),
        width: 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  NeuContainer(
                    borderRadius: 12,
                    isPressed: true,
                    padding: const EdgeInsets.all(10),
                    child: Icon(config.icon, size: 22, color: config.brandColor),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: NeuTheme.accentGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Installed & Monitored',
                            style: TextStyle(
                              color: NeuTheme.accentGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              NeuContainer(
                borderRadius: 10,
                isPressed: true,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  '$percentage% of total',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reels Watched Today',
                    style: TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${app.reelsCount}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: NeuTheme.accentTeal,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Total Dwell Time',
                    style: TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    TimeFormatters.formatSeconds(app.durationSeconds),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(SocialAppConfig config) {
    final TrackedApp app =
        stats.appStats[config.key] ?? TrackedApp.fromConfig(config);
    final percentage = stats.totalReels > 0
        ? (app.reelsCount / stats.totalReels * 100).round()
        : 0;

    return NeuContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      border: Border.all(
        color: NeuTheme.shadowDark.withValues(alpha: 0.5),
        width: 1.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NeuContainer(
                borderRadius: 8,
                isPressed: true,
                padding: const EdgeInsets.all(6),
                child: Icon(config.icon, size: 18, color: config.brandColor),
              ),
              NeuContainer(
                borderRadius: 8,
                isPressed: true,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${app.reelsCount} reels',
                    style: const TextStyle(
                      color: NeuTheme.accentTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '• ${TimeFormatters.formatSeconds(app.durationSeconds)}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
