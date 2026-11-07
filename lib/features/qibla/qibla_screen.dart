import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Within this many degrees the phone counts as facing the Qibla.
const _aligned = 3.0;

/// Past this tilt the magnetometer reading is unreliable; ask to hold flat.
const _maxTilt = 35.0;

/// Qibla finder: a quiet dial, not a nautical compass. The top of the phone
/// is fixed at the top of the dial; the Kaaba mark moves, and an accent arc
/// shows how far to turn.
class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  bool _wasAligned = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final n = LocaleDigits(Localizations.localeOf(context).toLanguageTag());
    final place = ref.watch(userPrefsProvider.select((p) => p.place));

    final appBar = AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: t.ink,
      title: Text(l.qiblaTitle, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
    );

    if (place == null) {
      return Scaffold(
        backgroundColor: t.ground,
        appBar: appBar,
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
    final heading = reading.value;
    final noCompass = reading.hasError;
    final live = heading != null;

    // Without a reading the dial is drawn north-up: the mark sits at the bearing.
    final turn = live ? turnTo(bearing, heading.degrees) : bearing;
    final aligned = live && turn.abs() <= _aligned;
    final tilted = live && heading.tilt > _maxTilt;

    if (aligned && !_wasAligned) HapticFeedback.mediumImpact();
    _wasAligned = aligned;

    final deg = n(bearing.round());
    final String headline;
    final String? sub;
    if (!live) {
      headline = '$deg°';
      sub = l.qiblaBearing('').replaceAll('°', '').trim();
    } else if (aligned) {
      headline = l.qiblaFacing;
      sub = null;
    } else {
      headline = '${n(turn.abs().round())}°';
      sub = turn > 0 ? l.qiblaTurnRight : l.qiblaTurnLeft;
    }

    return Scaffold(
      backgroundColor: t.ground,
      appBar: appBar,
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x8),
          children: [
            Text(l.qiblaFrom(place.name), style: WaqtText.label.copyWith(color: t.inkMuted)),
            const SizedBox(height: WaqtSpace.x6),
            LayoutBuilder(
              builder: (context, c) {
                final size = math.min(c.maxWidth, 340.0);
                return Center(
                  child: Semantics(
                    liveRegion: true,
                    label: [headline, ?sub].join(', '),
                    child: ExcludeSemantics(
                      child: SizedBox.square(
                        dimension: size,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(end: aligned ? 1 : 0),
                              duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : WaqtMotion.ui,
                              curve: WaqtMotion.ease,
                              builder: (_, glow, _) => CustomPaint(
                                size: Size.square(size),
                                painter: _DialPainter(
                                  heading: live ? heading.degrees : 0,
                                  bearing: bearing,
                                  live: live,
                                  glow: glow,
                                  ink: t.ink,
                                  muted: t.inkMuted,
                                  hairline: t.hairline,
                                  accent: t.accent,
                                  surface: t.surface,
                                  north: l.qiblaNorthShort,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: size * 0.2),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    headline,
                                    textAlign: TextAlign.center,
                                    style: (aligned ? WaqtText.titleSmall : WaqtText.clock.copyWith(fontSize: 52))
                                        .copyWith(color: t.ink),
                                  ),
                                  if (sub != null) Text(sub, style: WaqtText.label.copyWith(color: t.inkMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: WaqtSpace.x6),
            AnimatedSwitcher(
              duration: WaqtMotion.fast,
              child: Text(
                key: ValueKey((tilted, noCompass)),
                noCompass
                    ? l.qiblaNoCompass(deg)
                    : tilted
                    ? l.qiblaHoldFlat
                    : l.qiblaCalibrate,
                textAlign: TextAlign.center,
                style: (tilted ? WaqtText.bodyStrong : WaqtText.caption).copyWith(color: tilted ? t.ink : t.inkMuted),
              ),
            ),
            const SizedBox(height: WaqtSpace.x6),
            RowGroup(
              children: [
                RowTile(title: l.qiblaDirection, value: l.qiblaBearing(deg)),
                RowTile(title: l.qiblaDistance, value: l.qiblaKm(n(km))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.heading,
    required this.bearing,
    required this.live,
    required this.glow,
    required this.ink,
    required this.muted,
    required this.hairline,
    required this.accent,
    required this.surface,
    required this.north,
  });

  final double heading, bearing, glow;
  final bool live;
  final Color ink, muted, hairline, accent, surface;
  final String north;

  static double _rad(double d) => d * math.pi / 180;

  /// Screen angle for a world bearing: 0° = up, clockwise.
  Offset _at(Offset c, double r, double worldDeg) {
    final a = _rad(worldDeg - heading - 90);
    return c + Offset(math.cos(a), math.sin(a)) * r;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final outer = size.width / 2 - 14;
    final ringR = outer - 18;

    // Face: a soft disc that warms with the accent when aligned.
    canvas.drawCircle(c, ringR - 10, Paint()..color = Color.lerp(surface, accent.withValues(alpha: 0.28), glow)!);

    // Degree ticks, fixed to the world.
    final tick = Paint()..strokeCap = StrokeCap.round;
    for (var d = 0; d < 360; d += 5) {
      final major = d % 30 == 0;
      tick
        ..color = (major ? muted : hairline).withValues(alpha: major ? 0.7 : 1)
        ..strokeWidth = major ? 1.6 : 1;
      canvas.drawLine(_at(c, outer, d.toDouble()), _at(c, outer - (major ? 9 : 5), d.toDouble()), tick);
    }

    // North letter, just inside the ticks.
    final tp = TextPainter(
      text: TextSpan(
        text: north,
        style: WaqtText.overline.copyWith(color: muted, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, _at(c, ringR - 24, 0) - Offset(tp.width / 2, tp.height / 2));

    // Ring track.
    canvas.drawCircle(
      c,
      ringR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = Color.lerp(ink.withValues(alpha: 0.08), accent, glow)!,
    );

    // Turn arc: from where the phone points (top) to the Qibla.
    if (live) {
      final turn = turnTo(bearing, heading);
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: ringR),
        -math.pi / 2,
        _rad(turn),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..color = accent,
      );
    }

    // Phone-forward notch at the top.
    final top = c.translate(0, -ringR - 12);
    canvas.drawPath(
      Path()
        ..moveTo(top.dx, top.dy + 8)
        ..lineTo(top.dx - 6, top.dy - 2)
        ..lineTo(top.dx + 6, top.dy - 2)
        ..close(),
      Paint()..color = ink.withValues(alpha: 1 - glow),
    );

    // The Kaaba mark: a small dark cube with a gold band, on the ring.
    final k = _at(c, ringR, bearing);
    final sq = Rect.fromCenter(center: k, width: 22, height: 22);
    canvas.drawCircle(k, 18, Paint()..color = accent.withValues(alpha: 0.25 + 0.25 * glow));
    canvas.drawRRect(RRect.fromRectAndRadius(sq, const Radius.circular(5)), Paint()..color = const Color(0xFF14110C));
    canvas.drawRect(Rect.fromLTWH(sq.left, sq.top + 6, sq.width, 3), Paint()..color = const Color(0xFFE6C66A));
  }

  @override
  bool shouldRepaint(_DialPainter o) =>
      o.heading != heading ||
      o.bearing != bearing ||
      o.glow != glow ||
      o.live != live ||
      o.ink != ink ||
      o.accent != accent ||
      o.surface != surface ||
      o.north != north;
}
