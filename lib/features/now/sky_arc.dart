import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../domain/moments/moment.dart';
import '../../l10n/app_localizations.dart';
import 'moment_cards.dart' show clockFormat;

/// The signature element (design.md). Day: a semicircle from sunrise to
/// sunset with the sun at its real position. Night: Maghrib → Fajr as a bar
/// split into thirds, the last third lit.
class SkyArc extends StatelessWidget {
  const SkyArc({super.key, required this.snapshot});
  final MomentSnapshot snapshot;

  DateTime _start(MomentId id) => snapshot.timeline.firstWhere((m) => m.id == id).window.start;

  @override
  Widget build(BuildContext context) {
    final now = snapshot.now;
    final maghrib = _start(MomentId.maghrib);
    final night = !now.isBefore(maghrib);
    final reduce = MediaQuery.disableAnimationsOf(context);

    if (night) {
      final fajr = snapshot.timeline.firstWhere((m) => m.id == MomentId.isha).window.end;
      final third = snapshot.timeline.firstWhere((m) => m.id == MomentId.lastThird).window.start;
      return _NightBar(maghrib: maghrib, fajr: fajr, lastThird: third, now: now, reduceMotion: reduce);
    }
    return _DayArc(
      sunrise: _start(MomentId.sunrise),
      dhuhr: _start(MomentId.dhuhr),
      asr: _start(MomentId.asr),
      sunset: maghrib,
      now: now,
      reduceMotion: reduce,
    );
  }
}

double _frac(DateTime a, DateTime b, DateTime t) =>
    (t.difference(a).inSeconds / b.difference(a).inSeconds).clamp(0.0, 1.0).toDouble();

class _DayArc extends StatelessWidget {
  const _DayArc({
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.sunset,
    required this.now,
    required this.reduceMotion,
  });
  final DateTime sunrise, dhuhr, asr, sunset, now;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final fmt = clockFormat(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final p = _frac(sunrise, sunset, now);
    final risen = !now.isBefore(sunrise);

    return Semantics(
      label: '${l.prayerSunrise} ${fmt.format(sunrise)}, ${l.prayerMaghrib} ${fmt.format(sunset)}',
      excludeSemantics: true,
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(end: p),
            duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 900),
            curve: Curves.easeInOutCubic,
            builder: (context, v, _) => CustomPaint(
              size: const Size(double.infinity, 86),
              painter: _ArcPainter(
                progress: v,
                marks: [_frac(sunrise, sunset, dhuhr), _frac(sunrise, sunset, asr)],
                risen: risen,
                rtl: rtl,
                ink: t.ink,
                accent: t.accent,
                ground: t.ground,
              ),
            ),
          ),
          const SizedBox(height: WaqtSpace.x2),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: WaqtSpace.x1,
              children: [
                Text('${l.prayerSunrise} ${fmt.format(sunrise)}', style: WaqtText.caption.copyWith(color: t.inkMuted)),
                Text('${l.prayerMaghrib} ${fmt.format(sunset)}', style: WaqtText.caption.copyWith(color: t.inkMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.progress,
    required this.marks,
    required this.risen,
    required this.rtl,
    required this.ink,
    required this.accent,
    required this.ground,
  });

  final double progress;
  final List<double> marks;
  final bool risen, rtl;
  final Color ink, accent, ground;

  @override
  void paint(Canvas canvas, Size size) {
    // A flattened arc reads better than a full semicircle at phone widths.
    final w = size.width, h = size.height;
    final rx = w / 2 - 10, ry = h - 12;
    final c = Offset(w / 2, h - 2);

    Offset at(double f) {
      final a = math.pi * (rtl ? f : 1 - f); // f=0 → start edge
      return c + Offset(math.cos(a) * rx, -math.sin(a) * ry);
    }

    Path arc(double from, double to) {
      final path = Path()..moveTo(at(from).dx, at(from).dy);
      const steps = 72;
      for (var i = 1; i <= steps; i++) {
        final f = from + (to - from) * i / steps;
        path.lineTo(at(f).dx, at(f).dy);
      }
      return path;
    }

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Horizon.
    canvas.drawLine(
      Offset(0, c.dy),
      Offset(w, c.dy),
      Paint()
        ..color = ink.withValues(alpha: 0.12)
        ..strokeWidth = 1,
    );
    // Track, then the travelled part.
    canvas.drawPath(
      arc(0, 1),
      stroke
        ..color = ink.withValues(alpha: 0.13)
        ..strokeWidth = 2,
    );
    if (progress > 0) {
      canvas.drawPath(
        arc(0, progress),
        stroke
          ..color = accent
          ..strokeWidth = 3,
      );
    }

    // Dhuhr and Asr.
    for (final m in marks) {
      final passed = m <= progress;
      canvas.drawCircle(at(m), 4.5, Paint()..color = ground);
      canvas.drawCircle(at(m), 3.5, Paint()..color = passed ? accent : ink.withValues(alpha: 0.35));
    }

    // The sun.
    final sun = at(progress);
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: risen ? 0.55 : 0.25),
          accent.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: sun, radius: 26));
    canvas.drawCircle(sun, 26, glow);
    canvas.drawCircle(sun, 9, Paint()..color = ground);
    canvas.drawCircle(sun, 7.5, Paint()..color = risen ? accent : accent.withValues(alpha: 0.5));
  }

  @override
  bool shouldRepaint(_ArcPainter o) =>
      o.progress != progress || o.ink != ink || o.accent != accent || o.rtl != rtl || o.risen != risen;
}

class _NightBar extends StatelessWidget {
  const _NightBar({
    required this.maghrib,
    required this.fajr,
    required this.lastThird,
    required this.now,
    required this.reduceMotion,
  });
  final DateTime maghrib, fajr, lastThird, now;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final fmt = clockFormat(context);
    final p = _frac(maghrib, fajr, now);
    final thirdAt = _frac(maghrib, fajr, lastThird);

    return Semantics(
      label:
          '${l.prayerMaghrib} ${fmt.format(maghrib)}, ${l.momentLastThird} ${fmt.format(lastThird)}, '
          '${l.prayerFajr} ${fmt.format(fajr)}',
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, c) {
          final style = WaqtText.caption.copyWith(color: t.inkMuted);
          final strong = style.copyWith(color: t.ink, fontWeight: FontWeight.w600);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Above the lit segment, which always ends at Fajr (the bar's end).
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text('${l.momentLastThirdShort}  ${fmt.format(lastThird)}', style: strong, maxLines: 1),
              ),
              const SizedBox(height: WaqtSpace.x1),
              TweenAnimationBuilder<double>(
                tween: Tween(end: p),
                duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 900),
                curve: Curves.easeInOutCubic,
                builder: (context, v, _) => CustomPaint(
                  size: const Size(double.infinity, 28),
                  painter: _NightPainter(
                    progress: v,
                    thirdAt: thirdAt,
                    rtl: Directionality.of(context) == TextDirection.rtl,
                    ink: t.ink,
                    accent: t.accent,
                    ground: t.ground,
                  ),
                ),
              ),
              const SizedBox(height: WaqtSpace.x2),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: WaqtSpace.x1,
                children: [
                  Text('${l.prayerMaghrib} ${fmt.format(maghrib)}', style: style),
                  Text('${l.prayerFajr} ${fmt.format(fajr)}', style: style),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NightPainter extends CustomPainter {
  _NightPainter({
    required this.progress,
    required this.thirdAt,
    required this.rtl,
    required this.ink,
    required this.accent,
    required this.ground,
  });
  final double progress, thirdAt;
  final bool rtl;
  final Color ink, accent, ground;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, y = size.height / 2;
    double x(double f) => rtl ? w - f * w : f * w;
    const hBar = 8.0;
    RRect seg(double a, double b) {
      final l = math.min(x(a), x(b)), r = math.max(x(a), x(b));
      return RRect.fromLTRBR(l, y - hBar / 2, r, y + hBar / 2, const Radius.circular(hBar / 2));
    }

    canvas.drawRRect(seg(0, 1), Paint()..color = ink.withValues(alpha: 0.10));
    canvas.drawRRect(seg(thirdAt, 1), Paint()..color = accent.withValues(alpha: 0.45));
    if (progress > 0) canvas.drawRRect(seg(0, progress), Paint()..color = ink.withValues(alpha: 0.16));

    // Thirds.
    for (final f in [1 / 3, thirdAt]) {
      canvas.drawLine(
        Offset(x(f), y - 9),
        Offset(x(f), y + 9),
        Paint()
          ..color = ink.withValues(alpha: 0.35)
          ..strokeWidth = 1.5,
      );
    }

    // Now.
    final now = Offset(x(progress), y);
    canvas.drawCircle(now, 11, Paint()..color = ground);
    canvas.drawCircle(now, 8, Paint()..color = ink);
    canvas.drawCircle(
      now,
      11,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = accent.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(_NightPainter o) =>
      o.progress != progress || o.thirdAt != thirdAt || o.ink != ink || o.accent != accent || o.rtl != rtl;
}
