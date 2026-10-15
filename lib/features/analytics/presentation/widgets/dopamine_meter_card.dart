import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neumorphic.dart';
import 'package:reels_count/features/reel_tracker/domain/value_objects/doomscroll_score.dart';

class DopamineMeterCard extends StatelessWidget {
  final DoomscrollScore score;
  final double averageDwellSeconds;

  const DopamineMeterCard({
    super.key,
    required this.score,
    required this.averageDwellSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final risk = score.riskLevel;

    return NeuContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.psychology_outlined, color: NeuTheme.accentTeal, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'DOOMSCROLL INDEX',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              NeuContainer(
                borderRadius: 12,
                isPressed: true,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  risk.displayName.toUpperCase(),
                  style: TextStyle(
                    color: risk.color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${score.value}',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: risk.color,
                ),
              ),
              const Text(
                ' / 100',
                style: TextStyle(fontSize: 18, color: Colors.white54, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score.value / 100,
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(risk.color),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AVG DWELL / REEL',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${averageDwellSeconds.toStringAsFixed(1)}s',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SCROLL VELOCITY',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        averageDwellSeconds < 5.0 && averageDwellSeconds > 0
                            ? 'Mindless Fast'
                            : (averageDwellSeconds > 15 ? 'Engaged' : 'Moderate'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: averageDwellSeconds < 5.0 ? AppTheme.accentRed : AppTheme.accentGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
