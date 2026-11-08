import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/config/runtime.dart';

import '../../core/theme/waqt_theme.dart';
import 'moon_glyph.dart';

/// The body in the sky right now: a lit sphere by day, the real moon phase
/// by night. Shaded from the top left so it reads as an object, not an icon.
class Celestial extends StatelessWidget {
  const Celestial({super.key, required this.at, required this.night, this.southern = false, this.size = 92});
  final DateTime at;
  final bool night;
  final bool southern;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    final glow = night ? const Color(0xFFF3E6C4) : t.accent;
    return ExcludeSemantics(
      child: _Float(
        child: SizedBox.square(
          dimension: size * 1.5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Atmospheric halo.
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      glow.withValues(alpha: night ? 0.22 : 0.45),
                      glow.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: SizedBox.square(dimension: size * 1.5),
              ),
              if (night)
                MoonGlyph(at: at, southern: southern, size: size, lit: const Color(0xFFF1E4C2))
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.35, -0.4),
                      radius: 0.95,
                      colors: [
                        Color.lerp(glow, Colors.white, 0.7)!,
                        glow,
                        Color.lerp(glow, const Color(0xFFB0641E), 0.35)!,
                      ],
                      stops: const [0, 0.55, 1],
                    ),
                  ),
                  child: SizedBox.square(dimension: size),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A slow rise and fall, so the sky feels alive. Still with reduced motion.
class _Float extends StatefulWidget {
  const _Float({required this.child});
  final Widget child;

  @override
  State<_Float> createState() => _FloatState();
}

class _FloatState extends State<_Float> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(seconds: 9));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Runtime.isTest || MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (_, child) {
      final v = math.sin(_c.value * 2 * math.pi);
      return Transform.translate(offset: Offset(0, -4 + 4 * v), child: child);
    },
  );
}
