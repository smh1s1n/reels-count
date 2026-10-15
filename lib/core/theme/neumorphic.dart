import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Neumorphic Design System Tokens & Decoration Generators
class NeuTheme {
  // Base unified canvas & plastic surface color
  static const Color baseColor = Color(0xFF1E222B);
  static const Color baseLight = Color(0xFF262C38);
  static const Color baseDark = Color(0xFF15181F);

  // Dual Shadows for Extruded / Pushed-Out shapes
  static const Color shadowLight = Color(0xFF2D3442);
  static const Color shadowDark = Color(0xFF0F1116);

  // Inset / Stamped Shadows
  static const Color insetDark = Color(0xFF12141A);
  static const Color insetLight = Color(0xFF2B313E);

  // Accent Colors with vibrant soft-glow capability
  static const Color accentTeal = Color(0xFF00E5FF);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFFBBF24);
  static const Color accentRed = Color(0xFFF43F5E);
  static const Color accentPurple = Color(0xFF8B5CF6);

  /// Extruded (Pushed Out) Dual Shadows
  static List<BoxShadow> extrudedShadows({
    double distance = 6.0,
    double blur = 12.0,
    double lightIntensity = 0.85,
    double darkIntensity = 0.95,
  }) {
    return [
      BoxShadow(
        color: shadowLight.withValues(alpha: lightIntensity),
        offset: Offset(-distance, -distance),
        blurRadius: blur,
        spreadRadius: 0.5,
      ),
      BoxShadow(
        color: shadowDark.withValues(alpha: darkIntensity),
        offset: Offset(distance, distance),
        blurRadius: blur,
        spreadRadius: 0.5,
      ),
    ];
  }

  /// Subtle Extruded Shadows (for smaller elements or inner pills)
  static List<BoxShadow> subtleExtrudedShadows({double distance = 3.0, double blur = 6.0}) {
    return [
      BoxShadow(
        color: shadowLight.withValues(alpha: 0.7),
        offset: Offset(-distance, -distance),
        blurRadius: blur,
      ),
      BoxShadow(
        color: shadowDark.withValues(alpha: 0.8),
        offset: Offset(distance, distance),
        blurRadius: blur,
      ),
    ];
  }

  /// Inset / Stamped-In Shadows Effect (Simulated via gradient & dark inner perimeter)
  static BoxDecoration stampedDecoration({
    double borderRadius = 20,
    Color? base,
    Border? border,
    bool isCircle = false,
  }) {
    final bColor = base ?? baseColor;
    return BoxDecoration(
      color: bColor,
      shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          insetDark.withValues(alpha: 0.8),
          bColor,
          insetLight.withValues(alpha: 0.35),
        ],
        stops: const [0.0, 0.45, 1.0],
      ),
      border: border ??
          Border.all(
            color: insetDark.withValues(alpha: 0.6),
            width: 1.2,
          ),
    );
  }

  /// Extruded Plastic-like Container Decoration
  static BoxDecoration extrudedDecoration({
    double borderRadius = 24,
    Color? base,
    bool isCircle = false,
    Border? border,
    double distance = 6.0,
    double blur = 12.0,
    Color? glowColor,
  }) {
    final bColor = base ?? baseColor;
    final shadows = extrudedShadows(distance: distance, blur: blur);
    if (glowColor != null) {
      shadows.add(
        BoxShadow(
          color: glowColor.withValues(alpha: 0.18),
          blurRadius: 20,
          spreadRadius: 1,
        ),
      );
    }

    return BoxDecoration(
      color: bColor,
      shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseLight,
          bColor,
          baseDark,
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
      border: border,
      boxShadow: shadows,
    );
  }
}

/// A tactile Neumorphic Card / Container
class NeuContainer extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool isPressed;
  final bool isCircle;
  final Color? baseColor;
  final Color? glowColor;
  final Border? border;
  final VoidCallback? onTap;

  const NeuContainer({
    super.key,
    this.child,
    this.borderRadius = 24,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.isPressed = false,
    this.isCircle = false,
    this.baseColor,
    this.glowColor,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = isPressed
        ? NeuTheme.stampedDecoration(
            borderRadius: borderRadius,
            base: baseColor,
            border: border,
            isCircle: isCircle,
          )
        : NeuTheme.extrudedDecoration(
            borderRadius: borderRadius,
            base: baseColor,
            isCircle: isCircle,
            border: border,
            glowColor: glowColor,
          );

    final widgetChild = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        child: widgetChild,
      );
    }

    return widgetChild;
  }
}

/// An interactive Neumorphic Button that physically depresses on tap
class NeuButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? glowColor;
  final Color? baseColor;
  final bool isEnabled;
  final double? width;
  final double? height;

  const NeuButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.borderRadius = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.glowColor,
    this.baseColor,
    this.isEnabled = true,
    this.width,
    this.height,
  });

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _isDown = false;

  void _onTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    HapticFeedback.lightImpact();
    setState(() => _isDown = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isDown = false);
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    if (_isDown) {
      setState(() => _isDown = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBase = widget.baseColor ??
        (widget.isEnabled ? NeuTheme.baseColor : NeuTheme.baseDark);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: _isDown || !widget.isEnabled
            ? NeuTheme.stampedDecoration(
                borderRadius: widget.borderRadius,
                base: effectiveBase,
              )
            : NeuTheme.extrudedDecoration(
                borderRadius: widget.borderRadius,
                base: effectiveBase,
                glowColor: widget.glowColor,
              ),
        child: Opacity(
          opacity: widget.isEnabled ? 1.0 : 0.45,
          child: Center(
            widthFactor: widget.width != null ? 1.0 : null,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// An interactive Neumorphic Switch stamped into the background
class NeuSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const NeuSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = NeuTheme.accentTeal,
  });

  @override
  Widget build(BuildContext context) {
    const width = 54.0;
    const height = 30.0;
    const thumbSize = 22.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: width,
        height: height,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: NeuTheme.baseColor,
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              NeuTheme.shadowDark.withValues(alpha: 0.9),
              NeuTheme.baseColor,
              NeuTheme.shadowLight.withValues(alpha: 0.3),
            ],
          ),
          border: Border.all(
            color: value ? activeColor.withValues(alpha: 0.5) : NeuTheme.shadowDark,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: NeuTheme.shadowDark.withValues(alpha: 0.8),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: thumbSize,
            height: thumbSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? activeColor : NeuTheme.baseLight,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: value
                    ? [activeColor, activeColor.withValues(alpha: 0.8)]
                    : [const Color(0xFF323B4A), NeuTheme.baseLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: value
                      ? activeColor.withValues(alpha: 0.45)
                      : NeuTheme.shadowDark.withValues(alpha: 0.6),
                  offset: const Offset(1, 1),
                  blurRadius: 3,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  offset: const Offset(-1, -1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
