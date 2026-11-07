import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/config/runtime.dart';
import '../../core/theme/tokens.dart';

/// Sky look per moment palette, derived from the palette so it can never
/// drift from the design tokens.
extension SkyLook on MomentPalette {
  Color get skyTop => isDark ? Color.lerp(ground, const Color(0xFF000000), 0.45)! : Color.lerp(ground, accent, 0.42)!;

  double get stars => switch (this) {
    MomentPalette.night => 1,
    MomentPalette.bedtime => 0.8,
    MomentPalette.maghrib => 0.3,
    MomentPalette.fajr => 0.12,
    _ => 0,
  };

  double get glow => switch (this) {
    MomentPalette.night || MomentPalette.bedtime => 0.10,
    MomentPalette.maghrib => 0.38,
    _ => 0.30,
  };

  /// Where the light sits, as a fraction of the sky box.
  Offset get glowAt => switch (this) {
    MomentPalette.maghrib => const Offset(0.5, 1.0), // sun just below the horizon
    MomentPalette.fajr => const Offset(0.2, 0.9),
    MomentPalette.night || MomentPalette.bedtime => const Offset(0.82, 0.18), // moonlight
    _ => const Offset(0.82, 0.12),
  };
}

final _skyProgram = FutureProvider<ui.FragmentProgram?>((ref) async {
  try {
    return await ui.FragmentProgram.fromAsset('shaders/sky.frag');
  } on Object {
    return null; // tests, or a device without shader support: gradient fallback
  }
});

/// Sensors and the twinkle ticker are off under `flutter test` (no plugins,
/// and a never-ending ticker would keep the test from settling).
final bool _live = !Runtime.isTest;

/// The sky behind the Now screen. Fades into the ground colour so content
/// sits on it without a seam. 30 fps cap; static with reduce-motion.
class SkyBackground extends ConsumerStatefulWidget {
  const SkyBackground({super.key, required this.palette});
  final MomentPalette palette;

  @override
  ConsumerState<SkyBackground> createState() => _SkyBackgroundState();
}

class _SkyBackgroundState extends ConsumerState<SkyBackground> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  final _time = ValueNotifier<double>(0);
  final _tilt = ValueNotifier<Offset>(Offset.zero);
  StreamSubscription<AccelerometerEvent>? _accel;
  Duration _lastFrame = Duration.zero;
  bool _reduce = false;

  void _tick(Duration elapsed) {
    // 30 fps is plenty for slow twinkling and halves the GPU cost.
    if (elapsed - _lastFrame < const Duration(milliseconds: 33)) return;
    _lastFrame = elapsed;
    _time.value = elapsed.inMilliseconds / 1000;
  }

  void _configure() {
    final animate = _live && !_reduce && widget.palette.stars > 0;
    if (animate && !_ticker.isActive) _ticker.start();
    if (!animate && _ticker.isActive) _ticker.stop();

    final parallax = !_reduce && _live;
    if (parallax && _accel == null) {
      try {
        _accel = accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
          (e) {
            // Low-pass so the sky drifts rather than jitters; ±14 px.
            final target = Offset((-e.x * 2.2).clamp(-14, 14), (e.y * 1.4 - 12).clamp(-14, 14));
            _tilt.value = Offset.lerp(_tilt.value, target, 0.08)!;
          },
          onError: (_) {},
          cancelOnError: true,
        );
      } on Object {
        _accel = null;
      }
    } else if (!parallax) {
      _accel?.cancel();
      _accel = null;
      _tilt.value = Offset.zero;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.disableAnimationsOf(context);
    _configure();
  }

  @override
  void didUpdateWidget(SkyBackground old) {
    super.didUpdateWidget(old);
    if (old.palette != widget.palette) _configure();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _accel?.cancel();
    _time.dispose();
    _tilt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final program = ref.watch(_skyProgram).value;
    // Crossfade between palettes like the rest of the theme.
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        key: ValueKey(widget.palette),
        tween: Tween(begin: _reduce ? 1 : 0, end: 1),
        duration: _reduce ? Duration.zero : WaqtMotion.palette,
        builder: (context, fade, _) => Opacity(
          opacity: fade,
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size.infinite,
              painter: program == null
                  ? _GradientSky(widget.palette)
                  : _ShaderSky(program.fragmentShader(), widget.palette, _time, _tilt),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShaderSky extends CustomPainter {
  _ShaderSky(this.shader, this.p, this.time, this.tilt) : super(repaint: Listenable.merge([time, tilt]));
  final ui.FragmentShader shader;
  final MomentPalette p;
  final ValueNotifier<double> time;
  final ValueNotifier<Offset> tilt;

  @override
  void paint(Canvas canvas, Size size) {
    var i = 0;
    void f(double v) => shader.setFloat(i++, v);
    void c(Color col, [double a = 1]) {
      f(col.r);
      f(col.g);
      f(col.b);
      f(a);
    }

    f(size.width);
    f(size.height);
    f(time.value);
    c(p.skyTop);
    c(p.ground);
    f(p.stars);
    f(size.width * p.glowAt.dx);
    f(size.height * p.glowAt.dy);
    c(p.accent, p.glow);
    f(tilt.value.dx);
    f(tilt.value.dy);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_ShaderSky old) => old.p != p;
}

/// Same look without the shader (no stars).
class _GradientSky extends CustomPainter {
  _GradientSky(this.p);
  final MomentPalette p;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.skyTop, p.ground],
        ).createShader(rect),
    );
    final c = Offset(size.width * p.glowAt.dx, size.height * p.glowAt.dy);
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            p.accent.withValues(alpha: p.glow),
            p.accent.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: size.width * 0.8)),
    );
    // Same edge fade as the shader: no seam where the sky ends.
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0x00FFFFFF)],
          stops: [0, 0.7, 1],
        ).createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GradientSky old) => old.p != p;
}
