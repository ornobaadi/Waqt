import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../domain/prayer/prayer_times_service.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';
import 'moment_cards.dart';

/// The five prayers as windows: when each begins and when its time runs out.
/// The prayer in progress opens up to show how much of its time is left.
class PrayerWindows extends StatelessWidget {
  const PrayerWindows({super.key, required this.status, required this.now});
  final PrayerStatus status;
  final DateTime now;

  static const prayers = [Waqt.fajr, Waqt.dhuhr, Waqt.asr, Waqt.maghrib, Waqt.isha];

  /// When each window closes. Isha runs to Fajr; its preferred end, the
  /// middle of the night, is shown on the open row.
  DateTime endOf(Waqt w) => switch (w) {
    Waqt.fajr => status.today[Waqt.sunrise],
    Waqt.dhuhr => status.today[Waqt.asr],
    Waqt.asr => status.today[Waqt.maghrib],
    Waqt.maghrib => status.today[Waqt.isha],
    _ =>
      status.current == Waqt.isha && status.next == Waqt.fajr
          ? status.nextAt
          : status.today[Waqt.fajr].add(const Duration(days: 1)),
  };

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    // Before today's Fajr, last night's Isha is running: no row of today is.
    final open = status.today[status.current].isAfter(now) ? null : status.current;
    return Material(
      color: t.surface,
      borderRadius: BorderRadius.circular(WaqtRadii.strip),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final w in prayers)
            _Row(
              waqt: w,
              start: status.today[w],
              end: endOf(w),
              now: now,
              open: w == open,
              past: !endOf(w).isAfter(now),
              preferredEnd: w == Waqt.isha ? _midnight() : null,
            ),
        ],
      ),
    );
  }

  /// Middle of the night, Maghrib to Fajr.
  DateTime _midnight() {
    final m = status.today[Waqt.maghrib];
    return m.add(endOf(Waqt.isha).difference(m) ~/ 2);
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.waqt,
    required this.start,
    required this.end,
    required this.now,
    required this.open,
    required this.past,
    this.preferredEnd,
  });
  final Waqt waqt;
  final DateTime start, end, now;
  final bool open, past;
  final DateTime? preferredEnd;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final fmt = clockFormat(context);
    final range = '${fmt.format(start)} – ${fmt.format(end)}';
    final total = end.difference(start).inSeconds;
    final progress = total <= 0 ? 0.0 : (now.difference(start).inSeconds / total).clamp(0.0, 1.0);
    final fg = open ? t.heroInk : t.ink;

    return Semantics(
      button: true,
      selected: open,
      label: '${l.waqt(waqt)}, $range',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => context.go('/today'),
        child: AnimatedContainer(
          duration: WaqtMotion.ui,
          curve: WaqtMotion.ease,
          margin: open ? const EdgeInsets.all(WaqtSpace.x1) : EdgeInsets.zero,
          padding: EdgeInsets.symmetric(horizontal: WaqtSpace.x4, vertical: open ? WaqtSpace.x4 : WaqtSpace.x3),
          decoration: BoxDecoration(
            color: open ? t.heroSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(WaqtRadii.row),
          ),
          child: Opacity(
            opacity: past ? 0.45 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: WaqtSpace.x3,
                  children: [
                    Text(l.waqt(waqt), style: (open ? WaqtText.titleSmall : WaqtText.bodyStrong).copyWith(color: fg)),
                    Text(range, style: WaqtText.body.copyWith(color: open ? fg : t.inkMuted)),
                  ],
                ),
                if (open) ...[
                  const SizedBox(height: WaqtSpace.x3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: fg.withValues(alpha: 0.14),
                      color: t.accent,
                    ),
                  ),
                  // The hero already counts down; only Isha's earlier,
                  // preferred end adds something.
                  if (preferredEnd != null && preferredEnd!.isAfter(now)) ...[
                    const SizedBox(height: WaqtSpace.x2),
                    Text(
                      l.windowPreferred(fmt.format(preferredEnd!)),
                      style: WaqtText.label.copyWith(color: fg.withValues(alpha: 0.75)),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
