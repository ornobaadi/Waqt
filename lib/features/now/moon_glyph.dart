import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/waqt_theme.dart';
import '../../domain/astronomy/moon.dart';

/// The real moon phase for [at]. Mirrored in the southern hemisphere,
/// where a waxing crescent is lit on the left.
class MoonGlyph extends StatelessWidget {
  const MoonGlyph({super.key, required this.at, this.southern = false, this.size = 34, this.lit});
  final DateTime at;

  /// Lit-side colour; defaults to the palette ink.
  final Color? lit;
  final bool southern;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _MoonPainter(
          age: moonAge(at),
          southern: southern,
          lit: lit ?? t.ink,
          shade: (lit ?? t.ink).withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

class _MoonPainter extends CustomPainter {
  _MoonPainter({required this.age, required this.southern, required this.lit, required this.shade});
  final double age;
  final bool southern;
  final Color lit, shade;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - 1;
    final c = size.center(Offset.zero);
    canvas.drawCircle(c, r, Paint()..color = shade);

    final waxing = age < 0.5;
    // Terminator: +r at new moon, −r at full.
    final k = math.cos(2 * math.pi * age);
    final disc = Rect.fromCircle(center: c, radius: r);
    final ellipse = Rect.fromCenter(center: c, width: (2 * r * k).abs(), height: 2 * r);

    // Built lit-on-the-right (waxing, northern), then mirrored if needed.
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..arcTo(disc, -math.pi / 2, math.pi, false)
      ..arcTo(ellipse, math.pi / 2, k > 0 ? -math.pi : math.pi, false)
      ..close();

    canvas.save();
    if (waxing == southern) {
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }
    // Shaded from the top left, so a large moon reads as a sphere.
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.35),
          radius: 1.1,
          colors: [Color.lerp(lit, Colors.white, 0.35)!, lit, Color.lerp(lit, Colors.black, 0.22)!],
          stops: const [0, 0.5, 1],
        ).createShader(disc),
    );
    canvas.restore();

    // Soft halo.
    canvas.drawCircle(
      c,
      r + 6,
      Paint()
        ..color = lit.withValues(alpha: 0.06 + 0.1 * moonIlluminationFromAge(age))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(_MoonPainter o) => o.age != age || o.lit != lit || o.southern != southern;
}

double moonIlluminationFromAge(double age) => (1 - math.cos(2 * math.pi * age)) / 2;
