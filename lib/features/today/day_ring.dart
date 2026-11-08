import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../data/user/deeds_store.dart';
import '../../domain/deeds/deeds.dart';
import '../../l10n/app_localizations.dart';
import '../now/prayer_tick.dart';

/// Five arcs, one per prayer, filled as they are ticked. On time and in
/// congregation glow in the accent; made up later in a quieter ink.
class DayRing extends StatelessWidget {
  const DayRing({super.key, required this.log, this.size = 64, this.stroke});
  final DayLog log;
  final double size;
  final double? stroke;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return CustomPaint(
      size: Size.square(size),
      painter: _RingPainter(
        colors: [
          for (final p in fivePrayers)
            log.salah[p] == null ? t.ink.withValues(alpha: 0.1) : MarkColors.of(t, log.salah[p]!),
        ],
        stroke: stroke ?? size * 0.12,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.colors, required this.stroke});
  final List<Color> colors;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    const gap = 0.22; // radians between arcs
    const sweep = 2 * math.pi / 5;
    for (var i = 0; i < 5; i++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = colors[i];
      canvas.drawArc(r, -math.pi / 2 + i * sweep + gap / 2, sweep - gap, false, paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter o) {
    if (o.stroke != stroke) return true;
    for (var i = 0; i < colors.length; i++) {
      if (o.colors[i] != colors[i]) return true;
    }
    return false;
  }
}

/// Today's ring with its count, at the top of the Today tab.
class DayRingCard extends ConsumerWidget {
  const DayRingCard({super.key, required this.dayKey, this.onTap});
  final String dayKey;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final n = LocaleDigits(Localizations.localeOf(context).toLanguageTag());
    final log = ref.watch(deedsProvider.select((d) => d[dayKey] ?? DayLog.empty));
    final streak = ref.watch(deedStatsProvider).streak(DateTime.parse(dayKey));

    return Material(
      color: t.surface,
      borderRadius: BorderRadius.circular(WaqtRadii.strip),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(WaqtSpace.x4),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  DayRing(log: log),
                  Text(n(log.prayed), style: WaqtText.titleSmall.copyWith(color: t.ink)),
                ],
              ),
              const SizedBox(width: WaqtSpace.x4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.deedPrayedCount(n(log.prayed)), style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                    const SizedBox(height: 2),
                    Text(
                      streak > 1 ? l.deedStreak(n(streak)) : l.deedRingHint,
                      style: WaqtText.label.copyWith(color: t.inkMuted),
                    ),
                  ],
                ),
              ),
              if (onTap != null) Icon(Icons.chevron_right_rounded, color: t.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}
