import 'package:flutter/material.dart';

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
    );
  }
}
