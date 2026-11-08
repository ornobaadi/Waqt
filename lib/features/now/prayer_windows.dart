import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../data/user/deeds_store.dart';
import '../../domain/deeds/deeds.dart';
import '../../domain/prayer/prayer_times_service.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';
import 'prayer_tick.dart';

/// The five prayers in a plain row, and beneath it one quiet line: the
/// prayer in progress, the time it has left, draining toward the next.
/// Under each prayer, once its time has come, a ring to tick it prayed.
class PrayerWindows extends ConsumerWidget {
  const PrayerWindows({super.key, required this.status, required this.now});
  final PrayerStatus status;
  final DateTime now;

  static const prayers = [Waqt.fajr, Waqt.dhuhr, Waqt.asr, Waqt.maghrib, Waqt.isha];

  /// Where the running prayer's time ends, and what ends it. Fajr ends at
  /// sunrise; the others at the next prayer.
  (DateTime, String) _end(AppLocalizations l) {
    if (status.current == Waqt.fajr) return (status.today[Waqt.sunrise], l.waqt(Waqt.sunrise));
    return (status.nextAt, l.waqt(status.next));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final n = LocaleDigits(locale);
    final fmt = MediaQuery.alwaysUse24HourFormatOf(context) ? DateFormat.Hm(locale) : DateFormat('h:mm', locale);
    // Between sunrise and Dhuhr no prayer is running: the line counts to Dhuhr.
    final running = status.current != Waqt.sunrise;
    final (end, endName) = _end(l);
    final total = end.difference(status.currentStart).inSeconds;
    final left = end.difference(now);
    final remaining = total <= 0 ? 0.0 : (left.inSeconds / total).clamp(0.0, 1.0);
    final rows = MediaQuery.textScalerOf(context).scale(10) > 13 ? 2 : 1;
    final per = (prayers.length / rows).ceil();

    // Before Fajr the night still belongs to yesterday's prayer day.
    final prevDay = now.isBefore(status.today[Waqt.fajr]);
    final dayKey = DeedStats.dayKey(prevDay ? status.today[Waqt.fajr].subtract(const Duration(days: 1)) : now);
    final log = ref.watch(deedsProvider.select((d) => d[dayKey] ?? DayLog.empty));

    Widget cell(Waqt w) {
      final current = running && w == status.current && !status.today[w].isAfter(now);
      final past = !current && !status.today[w].isAfter(now);
      final started = prevDay || !status.today[w].isAfter(now);
      final ended = prevDay ? w != Waqt.isha : _endOf(w).isAfter(now) == false;
      return Column(
        children: [
          Semantics(
            selected: current,
            label: '${l.waqt(w)} ${fmt.format(status.today[w])}',
            excludeSemantics: true,
            child: Opacity(
              opacity: past ? 0.42 : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: WaqtSpace.x1),
                child: Column(
                  children: [
                    Text(
                      l.waqt(w),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: WaqtText.caption.copyWith(
                        color: current ? t.ink : t.inkMuted,
                        fontWeight: current ? FontWeight.w700 : null,
                      ),
                    ),
                    const SizedBox(height: WaqtSpace.x1),
                    Text(fmt.format(status.today[w]), style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: WaqtSpace.x1),
          PrayerTick(prayer: w, day: dayKey, mark: log.salah[w], started: started, ended: ended),
        ],
      );
    }

    return Material(
      color: t.surface,
      borderRadius: BorderRadius.circular(WaqtRadii.strip),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/today'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(WaqtSpace.x2, WaqtSpace.x3, WaqtSpace.x2, WaqtSpace.x4),
          child: Column(
            children: [
              for (var r = 0; r < rows; r++)
                Row(
                  children: [
                    for (final w in prayers.skip(r * per).take(per)) Expanded(child: cell(w)),
                    for (var i = prayers.skip(r * per).take(per).length; i < per; i++)
                      const Expanded(child: SizedBox()),
                  ],
                ),
              const SizedBox(height: WaqtSpace.x3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x2),
                child: Semantics(
                  label: l.stripLeft(_dur(l, n, left), endName),
                  excludeSemantics: true,
                  child: Row(
                    children: [
                      if (running) ...[
                        Flexible(
                          child: Text(
                            l.waqt(status.current),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: WaqtText.caption.copyWith(color: t.inkMuted),
                          ),
                        ),
                        const SizedBox(width: WaqtSpace.x3),
                      ],
                      // What is left of the window, sitting at the end it
                      // runs toward, shrinking as the time passes.
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: t.ink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          alignment: AlignmentDirectional.centerEnd,
                          child: FractionallySizedBox(
                            widthFactor: remaining,
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: t.ink, borderRadius: BorderRadius.circular(2)),
                              child: const SizedBox(height: 3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: WaqtSpace.x3),
                      // Large text: the label may wrap, never overflow.
                      Flexible(
                        flex: 3,
                        child: Text(
                          l.stripLeft(_dur(l, n, left), endName),
                          style: WaqtText.caption.copyWith(color: t.ink, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// When a prayer's own time runs out: Fajr at sunrise, the rest at the next.
  DateTime _endOf(Waqt w) => switch (w) {
    Waqt.fajr => status.today[Waqt.sunrise],
    Waqt.isha => status.today[Waqt.isha].add(const Duration(days: 1)),
    _ => status.today[Waqt.values[w.index + 1]],
  };

  static String _dur(AppLocalizations l, LocaleDigits n, Duration d) {
    final h = d.inHours, m = d.inMinutes % 60;
    return h > 0 ? l.durHm(n(h), n(m)) : l.durM(n(m < 1 ? 1 : m));
  }
}
