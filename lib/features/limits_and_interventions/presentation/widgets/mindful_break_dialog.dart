import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neumorphic.dart';
import 'mindful_activities_sheets.dart';

enum BreathPhase {
  inhale(title: 'INHALE', subtitle: 'Breathe in slowly through your nose...', durationSeconds: 4),
  hold(title: 'HOLD', subtitle: 'Pause gently & soften your shoulders...', durationSeconds: 2),
  exhale(title: 'EXHALE', subtitle: 'Release smoothly through your mouth...', durationSeconds: 4),
  rest(title: 'REST', subtitle: 'Feel your mind slowing down...', durationSeconds: 2);

  final String title;
  final String subtitle;
  final int durationSeconds;
  const BreathPhase({
    required this.title,
    required this.subtitle,
    required this.durationSeconds,
  });
}

class MindfulBreakDialog extends StatefulWidget {
  final int reelsCount;
  final VoidCallback onDismiss;
  final VoidCallback? onExtendLimit;
  final void Function(String activity)? onActivitySelected;

  const MindfulBreakDialog({
    super.key,
    required this.reelsCount,
    required this.onDismiss,
    this.onExtendLimit,
    this.onActivitySelected,
  });

  @override
  State<MindfulBreakDialog> createState() => _MindfulBreakDialogState();
}

class _MindfulBreakDialogState extends State<MindfulBreakDialog> with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0 = Guided Breath, 1 = Mindful Reset Swaps
  int _secondsLeft = 6;
  Timer? _cooldownTimer;

  // Breathwork State
  late AnimationController _breathAnimController;
  late Animation<double> _scaleAnimation;
  BreathPhase _currentPhase = BreathPhase.inhale;
  Timer? _phaseTimer;
  int _completedBreaths = 0;
  static const int _targetBreaths = 3;
  bool _isBreathworkActive = true;

  // Mindful Swap State
  int? _selectedActivityIndex;

  final List<({String title, String subtitle, IconData icon, Color color})> _activities = const [
    (
      title: 'Hydrate Body',
      subtitle: 'Drink a glass of cold water',
      icon: Icons.water_drop_outlined,
      color: Color(0xFF38BDF8),
    ),
    (
      title: 'Quick Stretch',
      subtitle: 'Roll shoulders & neck for 1 min',
      icon: Icons.self_improvement_rounded,
      color: Color(0xFF34D399),
    ),
    (
      title: 'Rest Your Eyes',
      subtitle: 'Look 20ft away into open space',
      icon: Icons.visibility_outlined,
      color: Color(0xFFA78BFA),
    ),
    (
      title: 'Connect Real',
      subtitle: 'Message or call a real friend',
      icon: Icons.chat_bubble_outline_rounded,
      color: Color(0xFFFBBF24),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _breathAnimController = AnimationController(
      vsync: this,
      duration: Duration(seconds: BreathPhase.inhale.durationSeconds),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.30).animate(
      CurvedAnimation(parent: _breathAnimController, curve: Curves.easeInOutCubic),
    );

    _startBreathCycle();

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          timer.cancel();
        }
      }
    });
  }

  void _startBreathCycle() {
    if (!mounted || !_isBreathworkActive) return;

    _phaseTimer?.cancel();
    HapticFeedback.lightImpact();

    if (_currentPhase == BreathPhase.inhale) {
      _breathAnimController.duration = Duration(seconds: BreathPhase.inhale.durationSeconds);
      _breathAnimController.forward(from: 0.0);
    } else if (_currentPhase == BreathPhase.exhale) {
      _breathAnimController.duration = Duration(seconds: BreathPhase.exhale.durationSeconds);
      _breathAnimController.reverse(from: 1.0);
    }

    _phaseTimer = Timer(Duration(seconds: _currentPhase.durationSeconds), () {
      if (!mounted) return;
      setState(() {
        switch (_currentPhase) {
          case BreathPhase.inhale:
            _currentPhase = BreathPhase.hold;
            break;
          case BreathPhase.hold:
            _currentPhase = BreathPhase.exhale;
            break;
          case BreathPhase.exhale:
            _currentPhase = BreathPhase.rest;
            break;
          case BreathPhase.rest:
            _completedBreaths++;
            if (_completedBreaths >= _targetBreaths) {
              _secondsLeft = 0;
            }
            _currentPhase = BreathPhase.inhale;
            break;
        }
      });
      _startBreathCycle();
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _phaseTimer?.cancel();
    _breathAnimController.dispose();
    super.dispose();
  }

  void _handlePrimaryAction() {
    HapticFeedback.mediumImpact();
    if (_activeTab == 1 && _selectedActivityIndex != null) {
      final actIndex = _selectedActivityIndex!;
      final act = _activities[actIndex].title;
      widget.onActivitySelected?.call(act);
      _openActivity(actIndex);
      return;
    }
    widget.onDismiss();
  }

  void _openActivity(int index) {
    HapticFeedback.selectionClick();
    final act = _activities[index].title;
    widget.onActivitySelected?.call(act);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        Widget content;
        switch (index) {
          case 0:
            content = HydrationActivitySheet(
              onComplete: () {
                Navigator.of(sheetContext).pop();
                widget.onDismiss();
              },
            );
            break;
          case 1:
            content = QuickStretchActivitySheet(
              onComplete: () {
                Navigator.of(sheetContext).pop();
                widget.onDismiss();
              },
            );
            break;
          case 2:
            content = EyeRestActivitySheet(
              onComplete: () {
                Navigator.of(sheetContext).pop();
                widget.onDismiss();
              },
            );
            break;
          case 3:
          default:
            content = ConnectRealActivitySheet(
              onComplete: () {
                Navigator.of(sheetContext).pop();
                widget.onDismiss();
              },
            );
            break;
        }
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: content,
        );
      },
    );
  }

  void _handleSnooze() {
    HapticFeedback.lightImpact();
    widget.onExtendLimit?.call();
    widget.onDismiss();
  }

  void _toggleBreathwork() {
    HapticFeedback.selectionClick();
    setState(() {
      _isBreathworkActive = !_isBreathworkActive;
      if (_isBreathworkActive) {
        _startBreathCycle();
      } else {
        _phaseTimer?.cancel();
        _breathAnimController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCooldownComplete = _secondsLeft == 0 || _completedBreaths >= _targetBreaths;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      elevation: 0,
      child: NeuContainer(
        borderRadius: 32,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
        glowColor: NeuTheme.accentTeal,
        border: Border.all(
          color: NeuTheme.accentTeal.withValues(alpha: 0.4),
          width: 1.5,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Drag Pill Indicator (Stamped Groove)
              NeuContainer(
                width: 44,
                height: 4,
                borderRadius: 2,
                isPressed: true,
              ),
              const SizedBox(height: 16),

              // Reel Limit Warning Badge (Stamped Well)
              NeuContainer(
                borderRadius: 20,
                isPressed: true,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.alarm_on_rounded, size: 14, color: NeuTheme.accentRed),
                    const SizedBox(width: 8),
                    Text(
                      'DAILY LIMIT: ${widget.reelsCount} REELS REACHED',
                      style: const TextStyle(
                        color: NeuTheme.accentRed,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Title & Subtitle
              const Text(
                'Pause the Autopilot Loop',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Continuous short videos drain cognitive energy. Take a mindful second to reconnect with yourself.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Interactive Neumorphic Segmented Tab Switcher
              NeuContainer(
                borderRadius: 18,
                isPressed: true,
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        title: 'Guided Breath',
                        icon: Icons.air_rounded,
                        index: 0,
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        title: 'Mindful Swap',
                        icon: Icons.bolt_rounded,
                        index: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Tab View Content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _activeTab == 0 ? _buildBreathworkTab() : _buildMindfulSwapTab(),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(isCooldownComplete),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required int index,
  }) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeTab = index);
      },
      child: isSelected
          ? NeuContainer(
              borderRadius: 14,
              isPressed: false,
              glowColor: NeuTheme.accentTeal,
              border: Border.all(
                color: NeuTheme.accentTeal.withValues(alpha: 0.5),
                width: 1.2,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: NeuTheme.accentTeal,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBreathworkTab() {
    return Column(
      key: const ValueKey('breath_tab'),
      children: [
        // Multi-Layer Glowing Breathing Orb
        GestureDetector(
          onTap: _toggleBreathwork,
          child: SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Halo
                AnimatedBuilder(
                  animation: _breathAnimController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value * 1.15,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryTeal.withValues(alpha: 0.08),
                        ),
                      ),
                    );
                  },
                ),

                // Animated Breathing Core
                AnimatedBuilder(
                  animation: _breathAnimController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.primaryTeal.withValues(alpha: 0.45),
                              AppTheme.primaryPurple.withValues(alpha: 0.20),
                              Colors.transparent,
                            ],
                            stops: const [0.3, 0.75, 1.0],
                          ),
                          border: Border.all(
                            color: _currentPhase == BreathPhase.hold
                                ? AppTheme.primaryPurple
                                : AppTheme.primaryTeal,
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_currentPhase == BreathPhase.hold
                                      ? AppTheme.primaryPurple
                                      : AppTheme.primaryTeal)
                                  .withValues(alpha: 0.28),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isBreathworkActive ? _currentPhase.title : 'PAUSED',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isBreathworkActive ? '${_currentPhase.durationSeconds}s' : 'Tap to play',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Subtitle guidance & Tap Hint
        Text(
          _isBreathworkActive ? _currentPhase.subtitle : 'Breathing guide paused. Tap circle to resume.',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),

        // Breath Completion Pills
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_targetBreaths, (idx) {
            final isCompleted = idx < _completedBreaths;
            final isCurrent = idx == _completedBreaths;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isCurrent ? 28 : 10,
              height: 8,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.accentGreen
                    : isCurrent
                        ? AppTheme.primaryTeal
                        : Colors.white12,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          'Breath ${_completedBreaths.clamp(1, _targetBreaths)} of $_targetBreaths',
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMindfulSwapTab() {
    return Column(
      key: const ValueKey('swap_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CHOOSE A QUICK DOPAMINE REPLACEMENT',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _activities.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (context, idx) {
            final item = _activities[idx];
            final isSelected = _selectedActivityIndex == idx;

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                if (_selectedActivityIndex == idx) {
                  _openActivity(idx);
                } else {
                  setState(() => _selectedActivityIndex = idx);
                }
              },
              child: NeuContainer(
                borderRadius: 18,
                isPressed: false,
                glowColor: isSelected ? item.color : null,
                border: Border.all(
                  color: isSelected
                      ? item.color
                      : NeuTheme.shadowDark.withValues(alpha: 0.5),
                  width: isSelected ? 1.6 : 1.0,
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(item.icon, color: item.color, size: 20),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: item.color, size: 16),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white54, fontSize: 9.5),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        if (_selectedActivityIndex != null) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _openActivity(_selectedActivityIndex!),
            child: NeuContainer(
              borderRadius: 16,
              isPressed: true,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: Border.all(color: NeuTheme.accentGreen.withValues(alpha: 0.35)),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: NeuTheme.accentGreen, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Step away to ${_activities[_selectedActivityIndex!].title.toLowerCase()} now.',
                      style: const TextStyle(
                        color: NeuTheme.accentGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  NeuContainer(
                    borderRadius: 8,
                    isPressed: true,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'START',
                          style: TextStyle(
                            color: NeuTheme.accentGreen,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.arrow_forward_rounded, size: 12, color: NeuTheme.accentGreen),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(bool isCooldownComplete) {
    final canCommitActivity = _activeTab == 1 && _selectedActivityIndex != null;
    final canProceed = isCooldownComplete || canCommitActivity;

    final primaryLabel = canCommitActivity
        ? 'Commit & Step Away'
        : isCooldownComplete
            ? '✓ Exit Feed Now'
            : 'Pause & Breathe (${_secondsLeft}s)';

    return Column(
      children: [
        // Primary Neumorphic Button
        NeuButton(
          borderRadius: 18,
          isEnabled: canProceed,
          glowColor: canProceed ? NeuTheme.accentGreen : null,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          onPressed: canProceed ? _handlePrimaryAction : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                canProceed ? Icons.power_settings_new_rounded : Icons.timer_outlined,
                size: 18,
                color: canProceed ? NeuTheme.accentGreen : Colors.white54,
              ),
              const SizedBox(width: 8),
              Text(
                primaryLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13.5,
                  color: canProceed ? Colors.white : Colors.white54,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Secondary Mindful Snooze & Later Options (Tactile Neumorphic Buttons)
        Row(
          children: [
            Expanded(
              child: NeuButton(
                borderRadius: 14,
                isEnabled: isCooldownComplete,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: isCooldownComplete ? widget.onDismiss : null,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_rounded, size: 15, color: Colors.white70),
                    SizedBox(width: 4),
                    Text(
                      'I Understand',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: NeuButton(
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: _handleSnooze,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.more_time_rounded, size: 15, color: NeuTheme.accentAmber),
                    SizedBox(width: 4),
                    Text(
                      '+5 Reels Snooze',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NeuTheme.accentAmber),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
