import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../../data/user/user_prefs.dart';
import '../../domain/qibla/qibla.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/sensors/heading.dart';
import '../../platform/haptics/haptics.dart';

/// Within this many degrees the phone counts as facing the Qibla.
const _aligned = 4.0;

/// How quickly the arrow settles on a new reading (per second). High enough
/// to feel live, low enough not to shiver.
const _settle = 14.0;

const _onAccent = Color(0xFF14110C);
const _kaabaBand = Color(0xFFE6C66A);

/// Qibla finder in the manner of "precision finding": one big arrow that
/// points where to turn, the Kaaba on a ring of dots, and the whole screen
/// glowing once you face it. Drawn every frame from the latest reading, with
/// a short settle, so it follows the hand in real time.
class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  /// Heading as drawn (degrees, unwrapped so 359 → 1 turns the short way).
  final _shown = ValueNotifier<double?>(null);
  double? _target;
  Duration _last = Duration.zero;
  bool _wasAligned = false;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
  }

  /// A new reading: wake the ticker until the arrow has settled on it.
  void _aim(double heading) {
    _target = heading;
    if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _shown.dispose();
    super.dispose();
  }

  void _tick(Duration now) {
    final dt = ((now - _last).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _last = now;
    final target = _target;
    if (target == null) return;
    final cur = _shown.value;
    if (cur == null || MediaQuery.disableAnimationsOf(context)) {
      _shown.value = target;
      _ticker.stop();
      return;
    }
    final diff = (target - cur + 540) % 360 - 180;
    if (diff.abs() < 0.05) {
      _shown.value = cur + diff;
      _ticker.stop(); // settled: no frames until the next reading
      return;
    }
    _shown.value = cur + diff * (1 - math.exp(-_settle * dt));
  }

  /// Haptics: a light tick every 5° inside 30°, a firm one on arriving.
  void _feel(double turn) {
    final aligned = turn.abs() <= _aligned;
    if (aligned && !_wasAligned) Haptics.heavy();
    _wasAligned = aligned;
    final step = turn.abs() <= 30 ? (turn.abs() / 5).floor() : -1;
    if (step != _step && step >= 0 && !aligned) Haptics.tick();
    _step = step;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final n = LocaleDigits(Localizations.localeOf(context).toLanguageTag());
    final place = ref.watch(userPrefsProvider.select((p) => p.place));

    if (place == null) {
      return Scaffold(
        backgroundColor: t.ground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          foregroundColor: t.ink,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: EmptyState(title: l.qiblaTitle, body: l.qiblaNoPlace),
            ),
            Padding(
              padding: const EdgeInsets.all(WaqtSpace.screen),
              child: FilledButton(onPressed: () => context.push('/settings/city'), child: Text(l.locationChooseCity)),
            ),
          ],
        ),
      );
    }

    final bearing = qiblaBearing(place.latitude, place.longitude);
    final km = qiblaDistanceKm(place.latitude, place.longitude).round();
    final reading = ref.watch(headingProvider);
    ref.listen(headingProvider, (_, next) {
      final h = next.value;
      if (h == null) return;
      _aim(h.degrees);
      _feel(turnTo(bearing, h.degrees));
    });
    // Seed straight away (tests, and the first frame on device).
    if (_target == null && reading.value != null) {
      final first = reading.value!.degrees;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _aim(first);
      });
    }
    final noCompass = reading.hasError;
    final calibrate = reading.value?.needsCalibration ?? false;

    return ValueListenableBuilder<double?>(
      valueListenable: _shown,
      builder: (context, shown, _) {
        final live = shown != null;
        // Without a reading the dial is drawn north-up and the Kaaba sits at the bearing.
        final turn = live ? turnTo(bearing, shown) : bearing;
        final aligned = live && turn.abs() <= _aligned;
        final bg = aligned ? t.accent : t.ground;
        final ink = aligned ? _onAccent : t.ink;
        final muted = aligned ? _onAccent.withValues(alpha: 0.62) : t.inkMuted;

        return AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : WaqtMotion.ui,
          curve: WaqtMotion.ease,
          color: bg,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              foregroundColor: ink,
              title: Text(l.qiblaTitle, style: WaqtText.bodyStrong.copyWith(color: ink)),
            ),
            body: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.qiblaFromLabel.toUpperCase(), style: WaqtText.overline.copyWith(color: muted)),
                              const SizedBox(height: 2),
                              Text(
                                place.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: WaqtText.titleSmall.copyWith(color: ink),
                              ),
                            ],
                          ),
                        ),
                        Text(l.qiblaToMakkah(n(km)), style: WaqtText.label.copyWith(color: muted)),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, c) {
                            final size = math.min(c.maxWidth, c.maxHeight).clamp(200.0, 380.0);
                            return Semantics(
                              liveRegion: true,
                              label: aligned
                                  ? l.qiblaFacing
                                  : '${n(turn.abs().round())}°, ${turn > 0 ? l.qiblaToRight : l.qiblaToLeft}',
                              child: ExcludeSemantics(
                                child: CustomPaint(
                                  size: Size.square(size),
                                  painter: _FinderPainter(
                                    turn: turn,
                                    live: live,
                                    aligned: aligned,
                                    ink: ink,
                                    faint: ink.withValues(alpha: aligned ? 0.28 : 0.14),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // The readout, large, like a distance in precision finding.
                    if (aligned) ...[
                      Text(l.qiblaFacing, style: WaqtText.title.copyWith(color: ink, fontSize: 34)),
                    ] else if (live) ...[
                      Text(
                        '${n(turn.abs().round())}°',
                        style: WaqtText.clock.copyWith(color: ink, fontSize: 72, height: 1),
                      ),
                      Text(
                        turn > 0 ? l.qiblaToRight : l.qiblaToLeft,
                        style: WaqtText.title.copyWith(color: muted, fontSize: 30),
                      ),
                    ] else ...[
                      Text(
                        '${n(bearing.round())}°',
                        style: WaqtText.clock.copyWith(color: ink, fontSize: 72, height: 1),
                      ),
                      Text(l.qiblaBearing('').replaceAll('°', '').trim(), style: WaqtText.title.copyWith(color: muted)),
                    ],
                    const SizedBox(height: WaqtSpace.x3),
                    Text(
                      noCompass
                          ? l.qiblaNoCompass(n(bearing.round()))
                          : calibrate
                          ? l.qiblaCalibrate
                          : aligned
                          ? l.qiblaBearing(n(bearing.round()))
                          : l.qiblaHint,
                      style: WaqtText.label.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FinderPainter extends CustomPainter {
  _FinderPainter({
    required this.turn,
    required this.live,
    required this.aligned,
    required this.ink,
    required this.faint,
  });

  /// Degrees to turn to face the Qibla: positive = to the right.
  final double turn;
  final bool live, aligned;
  final Color ink, faint;

  static double _rad(double d) => d * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 18;

    // Ring of dots, fixed to the phone: the top dot is straight ahead. The
    // dots between straight ahead and the Kaaba light up: how far to turn.
    const count = 48;
    for (var i = 0; i < count; i++) {
      final deg = i * 360 / count;
      final rel = deg > 180 ? deg - 360 : deg;
      // Leave room for the Kaaba.
      if (((rel - turn + 540) % 360 - 180).abs() < 9) continue;
      final onPath = live && (turn >= 0 ? rel >= 0 && rel <= turn : rel <= 0 && rel >= turn);
      final p = c + Offset(math.sin(_rad(deg)), -math.cos(_rad(deg))) * r;
      canvas.drawCircle(p, onPath || aligned ? 3.6 : 2.4, Paint()..color = onPath || aligned ? ink : faint);
    }

    // The Kaaba, on the ring, where the Qibla is.
    final k = c + Offset(math.sin(_rad(turn)), -math.cos(_rad(turn))) * r;
    final s = aligned ? 34.0 : 26.0;
    canvas.drawCircle(k, s * 0.95, Paint()..color = ink.withValues(alpha: aligned ? 0.12 : 0.1));
    final cube = RRect.fromRectAndRadius(Rect.fromCenter(center: k, width: s, height: s), Radius.circular(s * 0.2));
    canvas.drawRRect(cube, Paint()..color = _onAccent);
    canvas.drawRect(Rect.fromLTWH(cube.left, cube.top + s * 0.26, s, s * 0.14), Paint()..color = _kaabaBand);

    // The arrow: points where to turn, straight up once facing the Qibla.
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(_rad(turn));
    final len = r * 0.52, w = r * 0.13;
    final stroke = Paint()
      ..color = ink
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, len * 0.62), Offset(0, -len * 0.62), stroke);
    canvas.drawPath(
      Path()
        ..moveTo(-len * 0.42, -len * 0.2)
        ..lineTo(0, -len * 0.64)
        ..lineTo(len * 0.42, -len * 0.2),
      stroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FinderPainter o) =>
      o.turn != turn || o.live != live || o.aligned != aligned || o.ink != ink || o.faint != faint;
}
