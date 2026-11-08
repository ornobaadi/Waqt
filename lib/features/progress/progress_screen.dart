import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_state.dart';
import '../../core/clock/clock.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../../data/user/deeds_store.dart';
import '../../domain/deeds/deeds.dart';
import '../../domain/prayer/prayer_times_service.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/haptics/haptics.dart';
import '../common/labels.dart';
import '../now/prayer_tick.dart';

const _gap = 3.0;

/// Your salah, honestly and calmly: this month in three numbers, the week
/// as columns of beads you can fill in, how each prayer is going, and the
/// last twelve weeks. Colour means the same as on the strip.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final n = LocaleDigits(Localizations.localeOf(context).toLanguageTag());
    final stats = ref.watch(deedStatsProvider);
    final snap = ref.watch(momentSnapshotProvider);
    final today = _date(snap?.timeline.first.window.start ?? ref.watch(nowProvider).value ?? DateTime.now());
    final monthStart = DateTime(today.year, today.month);
    final monthDays = stats.trackedDays(monthStart, today).length;
    final onTime = stats.onTimeShare(monthStart, today);
    final from30 = today.subtract(const Duration(days: 29));
    final empty = stats.firstDay == null;

    Widget surface(Widget child, {EdgeInsets padding = const EdgeInsets.all(WaqtSpace.x4)}) => Container(
      padding: padding,
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.strip)),
      child: child,
    );

    // The prayer kept least often lately, said kindly, once there is enough to say it.
    Waqt? hardest;
    if (stats.trackedDays(from30, today).length >= 5) {
      double low = 2;
      for (final p in fivePrayers) {
        final s = stats.keptShare(p, from30, today)!;
        if (s < low) (low, hardest) = (s, p);
      }
      if (low >= 0.95) hardest = null;
    }

    return Scaffold(
      backgroundColor: t.ground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        title: Text(l.progressTitle, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          WaqtSpace.screen,
          WaqtSpace.x2,
          WaqtSpace.screen,
          WaqtSpace.x8 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          if (empty)
            Padding(
              padding: const EdgeInsets.only(bottom: WaqtSpace.x5),
              child: Text(l.progressEmpty, style: WaqtText.body.copyWith(color: t.inkMuted, height: 1.5)),
            )
          else
            surface(
              Row(
                children: [
                  _Figure(value: n(stats.prayedIn(monthStart, today)), label: l.progressOfPrayers(n(monthDays * 5))),
                  _Figure(value: onTime == null ? '–' : '${n((onTime * 100).round())}%', label: l.progressOnTimeShort),
                  _Figure(value: n(stats.streak(today)), label: l.progressCurrentRun),
                ],
              ),
            ),
          const SizedBox(height: WaqtSpace.x6),
          SectionLabel(l.progressThisWeek),
          surface(
            Row(
              children: [
                for (var i = 6; i >= 0; i--) ...[
                  Expanded(
                    child: _WeekColumn(
                      day: today.subtract(Duration(days: i)),
                      isToday: i == 0,
                    ),
                  ),
                  if (i > 0) const SizedBox(width: WaqtSpace.x2),
                ],
              ],
            ),
            padding: const EdgeInsets.fromLTRB(WaqtSpace.x3, WaqtSpace.x4, WaqtSpace.x3, WaqtSpace.x4),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(WaqtSpace.x2, WaqtSpace.x2, WaqtSpace.x2, 0),
            child: Text(l.progressEditHint, style: WaqtText.caption.copyWith(color: t.inkMuted)),
          ),
          if (!empty) ...[
            const SizedBox(height: WaqtSpace.x6),
            SectionLabel(l.progressByPrayer),
            surface(
              Column(
                children: [
                  for (final p in fivePrayers) _PrayerBar(prayer: p, stats: stats, from: from30, to: today, numbers: n),
                  if (hardest != null)
                    Padding(
                      padding: const EdgeInsets.only(top: WaqtSpace.x2),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          l.progressHardest(l.waqt(hardest)),
                          style: WaqtText.label.copyWith(color: t.inkMuted),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: WaqtSpace.x6),
            SectionLabel(l.progressWeeks),
            surface(_Weeks(stats: stats, today: today)),
            const SizedBox(height: WaqtSpace.x6),
            surface(
              Column(
                children: [
                  _Row(label: l.progressBestRun, value: l.progressDays(n(stats.longestStreak()))),
                  Divider(color: t.hairline, height: WaqtSpace.x6),
                  _Row(label: l.progressQada, value: n(stats.qadaOwed(from30, today))),
                ],
              ),
            ),
          ],
          const SizedBox(height: WaqtSpace.x8),
          Text(
            l.progressReflection,
            textAlign: TextAlign.center,
            style: WaqtText.label.copyWith(color: t.inkMuted, height: 1.5),
          ),
        ],
      ),
    );
  }

  static DateTime _date(DateTime d) => DateTime(d.year, d.month, d.day);
}

class _Figure extends StatelessWidget {
  const _Figure({required this.value, required this.label});
  final String value, label;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: WaqtText.title.copyWith(color: t.ink, height: 1.1)),
          const SizedBox(height: 2),
          Text(label, style: WaqtText.caption.copyWith(color: t.inkMuted)),
        ],
      ),
    );
  }
}

/// One day: its five prayers as stacked beads. Tap to fill the day in.
class _WeekColumn extends ConsumerWidget {
  const _WeekColumn({required this.day, required this.isToday});
  final DateTime day;
  final bool isToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final key = DeedStats.dayKey(day);
    final log = ref.watch(deedsProvider.select((d) => d[key] ?? DayLog.empty));

    return Semantics(
      button: true,
      label: '${DateFormat.MMMMEEEEd(locale).format(day)}, ${l.deedPrayedCount(LocaleDigits(locale)(log.prayed))}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _editDay(context, day),
        child: Column(
          children: [
            Text(
              DateFormat.E(locale).format(day),
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: WaqtText.caption.copyWith(
                color: isToday ? t.ink : t.inkMuted,
                fontWeight: isToday ? FontWeight.w700 : null,
              ),
            ),
            const SizedBox(height: WaqtSpace.x2),
            for (final p in fivePrayers)
              Padding(
                padding: const EdgeInsets.only(bottom: _gap),
                child: _Cell(mark: log.salah[p], height: 12),
              ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.mark, required this.height});
  final SalahMark? mark;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    final m = mark;
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: m == null ? t.ink.withValues(alpha: 0.07) : MarkColors.of(t, m),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

/// How often one prayer was kept over the last 30 days, split by colour.
class _PrayerBar extends StatelessWidget {
  const _PrayerBar({
    required this.prayer,
    required this.stats,
    required this.from,
    required this.to,
    required this.numbers,
  });
  final Waqt prayer;
  final DeedStats stats;
  final DateTime from, to;
  final LocaleDigits numbers;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final days = stats.trackedDays(from, to);
    final counts = {for (final m in SalahMark.values) m: 0};
    for (final d in days) {
      final m = stats.of(d).salah[prayer];
      if (m != null) counts[m] = counts[m]! + 1;
    }
    final total = days.length;
    final kept = counts.values.fold(0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: WaqtSpace.x2),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              l.waqt(prayer),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WaqtText.label.copyWith(color: t.ink),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 10,
                child: ColoredBox(
                  color: t.ink.withValues(alpha: 0.07),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final m in [SalahMark.jamaah, SalahMark.onTime, SalahMark.qada])
                        if (counts[m]! > 0)
                          Expanded(
                            flex: counts[m]!,
                            child: ColoredBox(color: MarkColors.of(t, m)),
                          ),
                      if (total - kept > 0) Expanded(flex: total - kept, child: const SizedBox()),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              total == 0 ? '–' : '${numbers((kept / total * 100).round())}%',
              textAlign: TextAlign.end,
              style: WaqtText.label.copyWith(color: t.ink, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// The last twelve weeks, one cell per day, darker the more prayers kept.
class _Weeks extends StatelessWidget {
  const _Weeks({required this.stats, required this.today});
  final DeedStats stats;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    final green = MarkColors.of(t, SalahMark.onTime);
    final start = today.subtract(const Duration(days: 12 * 7 - 1));
    final first = stats.firstDay;
    return Row(
      children: [
        for (var w = 0; w < 12; w++) ...[
          if (w > 0) const SizedBox(width: _gap),
          Expanded(
            child: Column(
              children: [
                for (var d = 0; d < 7; d++)
                  Padding(
                    padding: EdgeInsets.only(top: d == 0 ? 0 : _gap),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Builder(
                        builder: (context) {
                          final day = start.add(Duration(days: w * 7 + d));
                          final future = day.isAfter(today);
                          final before = first == null || day.isBefore(first);
                          final kept = stats.of(day).prayed;
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: future
                                  ? Colors.transparent
                                  : kept == 0
                                  ? t.ink.withValues(alpha: before ? 0.03 : 0.07)
                                  : Color.lerp(green.withValues(alpha: 0.22), green, kept / 5),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(label, style: WaqtText.body.copyWith(color: t.ink)),
        ),
        Text(value, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
      ],
    );
  }
}

/// Fill in one day after the fact: each prayer, and how it was kept.
Future<void> _editDay(BuildContext context, DateTime day) {
  final t = WaqtTokens.of(context);
  final locale = Localizations.localeOf(context).toLanguageTag();
  final key = DeedStats.dayKey(day);
  Haptics.tick();
  return showModalBottomSheet<void>(
    useRootNavigator: true,
    context: context,
    backgroundColor: t.ground,
    showDragHandle: true,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final l = AppLocalizations.of(context);
        final log = ref.watch(deedsProvider.select((d) => d[key] ?? DayLog.empty));
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(DateFormat.MMMMEEEEd(locale).format(day), style: WaqtText.titleSmall.copyWith(color: t.ink)),
                const SizedBox(height: WaqtSpace.x3),
                for (final p in fivePrayers)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: SalahSwatch(mark: log.salah[p], size: 26),
                    title: Text(l.waqt(p), style: WaqtText.body.copyWith(color: t.ink)),
                    trailing: Text(markLabel(l, log.salah[p]), style: WaqtText.label.copyWith(color: t.inkMuted)),
                    onTap: () async {
                      final picked = await showSalahSheet(context, p, log.salah[p]);
                      if (picked == null) return;
                      if (picked.$1 == null) {
                        Haptics.tick();
                      } else {
                        Haptics.click();
                      }
                      ref.read(deedsProvider.notifier).markSalah(key, p, picked.$1);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
