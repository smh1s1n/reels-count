import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../reel_tracker/data/datasources/native_platform_datasource.dart';

// ==========================================
// 1. HYDRATION ACTIVITY SHEET
// ==========================================
class HydrationActivitySheet extends StatefulWidget {
  final VoidCallback onComplete;

  const HydrationActivitySheet({super.key, required this.onComplete});

  @override
  State<HydrationActivitySheet> createState() => _HydrationActivitySheetState();
}

class _HydrationActivitySheetState extends State<HydrationActivitySheet> with SingleTickerProviderStateMixin {
  int _waterGlasses = 0;
  static const int _targetGlasses = 8;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _justLogged = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _loadTodayHydration();
  }

  Future<void> _loadTodayHydration() async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() {
      _waterGlasses = prefs.getInt('water_intake_count_$dateKey') ?? 0;
    });
  }

  Future<void> _logGlass() async {
    HapticFeedback.heavyImpact();
    final prefs = await SharedPreferences.getInstance();
    final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final newCount = _waterGlasses + 1;
    await prefs.setInt('water_intake_count_$dateKey', newCount);

    setState(() {
      _waterGlasses = newCount;
      _justLogged = true;
    });

    _animController.forward(from: 0.0).then((_) {
      if (mounted) {
        _animController.reverse();
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _justLogged = false);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_waterGlasses / _targetGlasses).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: AppTheme.darkBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),

          // Header Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.water_drop_rounded, size: 16, color: Color(0xFF38BDF8)),
                SizedBox(width: 6),
                Text(
                  'BRAIN HYDRATION RESET',
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            'Hydrate Your Body',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your brain is ~75% water. Dehydration often triggers restlessness and dopamine-seeking scroll loops.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 24),

          // Animated Water Glass
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 140,
              height: 160,
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                  width: 2.5,
                ),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Animated water level
                  FractionallySizedBox(
                    heightFactor: progress == 0 ? 0.05 : progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _justLogged ? Icons.celebration_rounded : Icons.water_drop_outlined,
                        size: 38,
                        color: const Color(0xFF38BDF8),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$_waterGlasses / $_targetGlasses',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'glasses today',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Log button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _logGlass,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: const Text(
                '+ Log 1 Glass (250ml)',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Done button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: widget.onComplete,
              child: const Text(
                '✓ Done & Step Away',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. QUICK STRETCH ACTIVITY SHEET
// ==========================================
class QuickStretchActivitySheet extends StatefulWidget {
  final VoidCallback onComplete;

  const QuickStretchActivitySheet({super.key, required this.onComplete});

  @override
  State<QuickStretchActivitySheet> createState() => _QuickStretchActivitySheetState();
}

class _QuickStretchActivitySheetState extends State<QuickStretchActivitySheet> {
  int _secondsLeft = 60;
  Timer? _timer;
  bool _isRunning = true;

  final List<({String title, String guidance, IconData icon, int endSecond})> _stages = const [
    (
      title: 'Neck & Trapezius Rolls',
      guidance: 'Gently roll your head side-to-side. Release screen neck stiffness.',
      icon: Icons.accessibility_new_rounded,
      endSecond: 40,
    ),
    (
      title: 'Shoulder & Chest Openers',
      guidance: 'Roll shoulders back 5 times, then forwards. Clasp hands behind back.',
      icon: Icons.self_improvement_rounded,
      endSecond: 20,
    ),
    (
      title: 'Overhead Reach & Wrist Flex',
      guidance: 'Interlace fingers, reach high toward ceiling, flex both wrists.',
      icon: Icons.pan_tool_outlined,
      endSecond: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
          if (_secondsLeft == 40 || _secondsLeft == 20 || _secondsLeft == 0) {
            HapticFeedback.mediumImpact();
          }
        } else {
          timer.cancel();
          HapticFeedback.heavyImpact();
        }
      }
    });
  }

  void _togglePlayPause() {
    HapticFeedback.selectionClick();
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _skipNext() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_secondsLeft > 40) {
        _secondsLeft = 40;
      } else if (_secondsLeft > 20) {
        _secondsLeft = 20;
      } else {
        _secondsLeft = 0;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  ({String title, String guidance, IconData icon, int endSecond}) _getCurrentStage() {
    if (_secondsLeft > 40) return _stages[0];
    if (_secondsLeft > 20) return _stages[1];
    return _stages[2];
  }

  @override
  Widget build(BuildContext context) {
    final currentStage = _getCurrentStage();
    final isDone = _secondsLeft == 0;
    final progress = (60 - _secondsLeft) / 60.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: AppTheme.darkBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF34D399).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.self_improvement_rounded, size: 16, color: Color(0xFF34D399)),
                SizedBox(width: 6),
                Text(
                  '1-MINUTE GUIDED STRETCH',
                  style: TextStyle(
                    color: Color(0xFF34D399),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            isDone ? '✨ Stretch Complete!' : currentStage.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isDone
                ? 'Blood flow restored to your shoulders & brain. Notice how good it feels to step away.'
                : currentStage.guidance,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 24),

          // Circular Animated Timer
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF34D399)),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isDone ? Icons.check_circle_rounded : currentStage.icon,
                      color: const Color(0xFF34D399),
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_secondsLeft}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Play / Pause and Next controls
          if (!isDone) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.darkCard,
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  onPressed: _togglePlayPause,
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF34D399),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _skipNext,
                  icon: const Icon(Icons.skip_next_rounded, size: 18),
                  label: const Text('Next Stretch', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF34D399),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: widget.onComplete,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text(
                  'Complete & Step Away',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),

          TextButton(
            onPressed: widget.onComplete,
            child: const Text('Close', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. EYE REST ACTIVITY SHEET
// ==========================================
class EyeRestActivitySheet extends StatefulWidget {
  final VoidCallback onComplete;

  const EyeRestActivitySheet({super.key, required this.onComplete});

  @override
  State<EyeRestActivitySheet> createState() => _EyeRestActivitySheetState();
}

class _EyeRestActivitySheetState extends State<EyeRestActivitySheet> {
  int _secondsLeft = 20;
  Timer? _timer;

  final List<String> _cues = const [
    'Focus on an object 20ft away (tree, cloud, or distant wall)',
    'Blink gently 5 times to lubricate your corneas',
    'Soften your gaze and release tension around your temples',
    'Feel your eye focal muscles relax and reset',
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          timer.cancel();
          HapticFeedback.heavyImpact();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _secondsLeft == 0;
    final progress = (20 - _secondsLeft) / 20.0;
    final cueIndex = ((20 - _secondsLeft) ~/ 5).clamp(0, _cues.length - 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: AppTheme.darkBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFA78BFA).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA78BFA).withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.visibility_outlined, size: 16, color: Color(0xFFA78BFA)),
                SizedBox(width: 6),
                Text(
                  'THE 20-20-20 OPTOMETRIC RULE',
                  style: TextStyle(
                    color: Color(0xFFA78BFA),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            isDone ? '👁️ Eyes Refreshed!' : 'Look 20ft Away for 20s',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isDone
                ? 'Your ciliary eye muscles have completely relaxed from near-field screen fatigue.'
                : _cues[cueIndex],
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 24),

          // Calming Eye Timer Ring
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFA78BFA)),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isDone ? Icons.check_circle_rounded : Icons.remove_red_eye_rounded,
                      color: const Color(0xFFA78BFA),
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_secondsLeft}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA78BFA),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: widget.onComplete,
              icon: const Icon(Icons.check_rounded, size: 20),
              label: Text(
                isDone ? 'Complete & Step Away' : 'Skip & Finish',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. CONNECT REAL ACTIVITY SHEET
// ==========================================
class ConnectRealActivitySheet extends StatefulWidget {
  final VoidCallback onComplete;

  const ConnectRealActivitySheet({super.key, required this.onComplete});

  @override
  State<ConnectRealActivitySheet> createState() => _ConnectRealActivitySheetState();
}

class _ConnectRealActivitySheetState extends State<ConnectRealActivitySheet> {
  final NativePlatformDataSource _nativeSource = NativePlatformDataSource();
  late TextEditingController _messageController;

  final List<String> _templates = const [
    'Hey! Taking a quick break from screens and wanted to say hi. How are you doing?',
    'Hey! Was just thinking about you. Free to catch up sometime soon?',
    'Quick check-in! Hope you are having a wonderful day.',
  ];

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: _templates[0]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendSms() async {
    HapticFeedback.mediumImpact();
    await _nativeSource.launchSms(message: _messageController.text);
    widget.onComplete();
  }

  void _callFriend() async {
    HapticFeedback.mediumImpact();
    await _nativeSource.launchDialer();
    widget.onComplete();
  }

  void _share() async {
    HapticFeedback.mediumImpact();
    await _nativeSource.shareText(_messageController.text);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: AppTheme.darkBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.4)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFFFBBF24)),
                  SizedBox(width: 6),
                  Text(
                    'REAL HUMAN CONNECTION',
                    style: TextStyle(
                      color: Color(0xFFFBBF24),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          const Center(
            child: Text(
              'Connect With a Friend',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'A 1-minute real conversation releases 10x healthier oxytocin and dopamine than scrolling feeds.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(height: 20),

          // Message Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: TextField(
              controller: _messageController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Template chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _templates.map((tpl) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: AppTheme.darkCard,
                    label: Text(
                      tpl.length > 25 ? '${tpl.substring(0, 25)}...' : tpl,
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                    onPressed: () {
                      setState(() => _messageController.text = tpl);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBBF24),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _sendSms,
                  icon: const Icon(Icons.sms_rounded, size: 18),
                  label: const Text('Text Friend', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _callFriend,
                  icon: const Icon(Icons.phone_rounded, size: 18),
                  label: const Text('Call Friend', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: AppTheme.darkBorder),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _share,
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text('Share Note via Any App'),
            ),
          ),
          const SizedBox(height: 6),

          Center(
            child: TextButton(
              onPressed: widget.onComplete,
              child: const Text('Dismiss', style: TextStyle(color: Colors.white54)),
            ),
          ),
        ],
      ),
    );
  }
}
