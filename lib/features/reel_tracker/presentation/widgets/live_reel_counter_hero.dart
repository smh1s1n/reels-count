import 'package:flutter/material.dart';
import '../../../../core/theme/neumorphic.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/daily_stats.dart';

class LiveReelCounterHero extends StatelessWidget {
  final DailyStats stats;
  final VoidCallback? onLimitTap;

  const LiveReelCounterHero({
    super.key,
    required this.stats,
    this.onLimitTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = stats.progressToLimit;
    final risk = stats.riskLevel;

    return NeuContainer(
      borderRadius: 28,
      padding: const EdgeInsets.all(22),
      glowColor: stats.isLimitExceeded ? NeuTheme.accentRed : null,
      border: Border.all(
        color: stats.isLimitExceeded
            ? NeuTheme.accentRed.withValues(alpha: 0.6)
            : NeuTheme.shadowDark.withValues(alpha: 0.4),
        width: 1.2,
      ),
      child: Column(
        children: [
          // Top bar: Risk badge + Daily limit pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Neumorphic stamped risk badge
              NeuContainer(
                borderRadius: 20,
                isPressed: true,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: risk.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: risk.color.withValues(alpha: 0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      risk.displayName.toUpperCase(),
                      style: TextStyle(
                        color: risk.color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

              // Neumorphic tactile limit button
              NeuButton(
                onPressed: onLimitTap,
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tune_rounded, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      'Limit: ${stats.dailyLimit}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Central Neumorphic Concentric Dial
          Center(
            child: SizedBox(
              width: 204,
              height: 204,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Stamped Inset Circular Groove for the progress track
                  NeuContainer(
                    width: 204,
                    height: 204,
                    isCircle: true,
                    isPressed: true,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background Circular Track
                          SizedBox(
                            width: 178,
                            height: 178,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 10,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                NeuTheme.shadowDark.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          // Active Progress Arc with glowing tip
                          SizedBox(
                            width: 178,
                            height: 178,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 10,
                              strokeCap: StrokeCap.round,
                              valueColor: AlwaysStoppedAnimation<Color>(risk.color),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Embossed / Extruded Center Floating Island
                  NeuContainer(
                    width: 140,
                    height: 140,
                    isCircle: true,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${stats.totalReels}',
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.5,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'REELS TODAY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Stamped time badge
                          NeuContainer(
                            borderRadius: 10,
                            isPressed: true,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            child: Text(
                              TimeFormatters.formatSeconds(stats.totalDurationSeconds),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: NeuTheme.accentTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Stamped Advice Well
          NeuContainer(
            borderRadius: 16,
            isPressed: true,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            child: Text(
              risk.advice,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.75),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
