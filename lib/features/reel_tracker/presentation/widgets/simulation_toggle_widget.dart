import 'package:flutter/material.dart';
import '../../../../core/constants/social_apps.dart';
import '../../../../core/theme/neumorphic.dart';
import '../controllers/reel_tracker_controller.dart';
import '../controllers/reel_tracker_state.dart';

class SimulationControlCard extends StatefulWidget {
  final ReelTrackerState state;
  final ReelTrackerController controller;

  const SimulationControlCard({
    super.key,
    required this.state,
    required this.controller,
  });

  @override
  State<SimulationControlCard> createState() => _SimulationControlCardState();
}

class _SimulationControlCardState extends State<SimulationControlCard> {
  String _selectedApp = 'instagram';

  @override
  Widget build(BuildContext context) {
    final isSimActive = widget.state.isSimulationActive;
    final isAuto = widget.state.isAutoScrolling;

    return NeuContainer(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      glowColor: isSimActive ? NeuTheme.accentPurple : null,
      border: Border.all(
        color: isSimActive
            ? NeuTheme.accentPurple.withValues(alpha: 0.5)
            : NeuTheme.shadowDark.withValues(alpha: 0.4),
        width: 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NeuContainer(
                isPressed: true,
                borderRadius: 10,
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.science_outlined,
                  size: 18,
                  color: NeuTheme.accentPurple,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simulation & Testing Engine',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Simulate scrolls & test alerts without leaving app',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              NeuSwitch(
                value: isSimActive,
                activeColor: NeuTheme.accentPurple,
                onChanged: (val) {
                  widget.controller.setSimulationMode(val);
                },
              ),
            ],
          ),
          if (isSimActive) ...[
            const SizedBox(height: 16),
            NeuContainer(
              isPressed: true,
              borderRadius: 2,
              height: 1.5,
              width: double.infinity,
            ),
            const SizedBox(height: 16),
            const Text(
              'SELECT TARGET PLATFORM',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.9,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: SocialAppConfig.supportedApps.map((app) {
                  final isSelected = _selectedApp == app.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedApp = app.key);
                        if (isAuto) {
                          widget.controller.startAutoScrollingSimulation(appName: app.key);
                        }
                      },
                      child: isSelected
                          ? NeuContainer(
                              borderRadius: 14,
                              isPressed: false,
                              glowColor: app.brandColor,
                              border: Border.all(
                                color: app.brandColor.withValues(alpha: 0.6),
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(app.icon, size: 14, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    app.displayName.split(' ')[0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : NeuContainer(
                              borderRadius: 14,
                              isPressed: true,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(app.icon, size: 14, color: app.brandColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    app.displayName.split(' ')[0],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: NeuButton(
                    borderRadius: 14,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    onPressed: () {
                      widget.controller.triggerSimulatedScroll(appName: _selectedApp);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swipe_vertical_rounded, size: 16, color: Colors.white70),
                        SizedBox(width: 6),
                        Text(
                          'Simulate 1 Reel',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeuButton(
                    borderRadius: 14,
                    glowColor: isAuto ? NeuTheme.accentRed : NeuTheme.accentPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    onPressed: () {
                      if (isAuto) {
                        widget.controller.stopAutoScrollingSimulation();
                      } else {
                        widget.controller.startAutoScrollingSimulation(appName: _selectedApp);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isAuto ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                          size: 16,
                          color: isAuto ? NeuTheme.accentRed : NeuTheme.accentPurple,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAuto ? 'Stop Auto' : 'Auto Scroll',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isAuto ? NeuTheme.accentRed : NeuTheme.accentPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
