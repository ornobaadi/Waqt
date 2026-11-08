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
import '../../l10n/app_localizations.dart';
import '../today/day_ring.dart';

/// One calm screen: this week as small rings, the year as a field of days,
/// and a few honest numbers. No red marks, nothing to manage.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final n = LocaleDigits(locale);
    final stats = ref.watch(deedStatsProvider);
    final snap = ref.watch(momentSnapshotProvider);
    final today = _date(snap?.timeline.first.window.start ?? ref.watch(nowProvider).value ?? DateTime.now());
    final weekStart = today.subtract(const Duration(days: 6));
    final monthStart = DateTime(today.year, today.month);
    final onTime = stats.onTimeShare(monthStart, today);

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
          SectionLabel(l.progressThisWeek),
          Container(
            padding: const EdgeInsets.symmetric(vertical: WaqtSpace.x4, horizontal: WaqtSpace.x2),
            decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.strip)),
            child: Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: _WeekDay(
                      day: weekStart.add(Duration(days: i)),
                      log: stats.of(weekStart.add(Duration(days: i))),
                      isToday: i == 6,
                      locale: locale,
                      numbers: n,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: WaqtSpace.x6),
          SectionLabel(l.progressYear),
          Container(
            padding: const EdgeInsets.all(WaqtSpace.x4),
            decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.strip)),
            child: _YearField(stats: stats, today: today),
          ),
          const SizedBox(height: WaqtSpace.x6),
          Container(
            decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.strip)),
            child: Column(
              children: [
                _Number(label: l.progressOnTime, value: onTime == null ? '–' : '${n((onTime * 100).round())}%'),
                _Number(label: l.progressBestRun, value: l.progressDays(n(stats.longestStreak()))),
                _Number(label: l.progressFasts, value: n(stats.fastsIn(today.year))),
                _Number(
                  label: l.progressQada,
                  value: n(stats.qadaOwed(today.subtract(const Duration(days: 30)), today)),
                  last: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: WaqtSpace.x6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x2),
            child: Text(
              l.progressReflection,
              textAlign: TextAlign.center,
              style: WaqtText.label.copyWith(color: t.inkMuted, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  static DateTime _date(DateTime d) => DateTime(d.year, d.month, d.day);
}

class _WeekDay extends StatelessWidget {
  const _WeekDay({
    required this.day,
    required this.log,
    required this.isToday,
    required this.locale,
    required this.numbers,
  });
  final DateTime day;
  final DayLog log;
  final bool isToday;
  final String locale;
  final LocaleDigits numbers;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Column(
      children: [
        Text(
          DateFormat.E(locale).format(day),
          maxLines: 1,
          style: WaqtText.caption.copyWith(
            color: isToday ? t.ink : t.inkMuted,
            fontWeight: isToday ? FontWeight.w700 : null,
          ),
        ),
        const SizedBox(height: WaqtSpace.x2),
        Stack(
          alignment: Alignment.center,
          children: [
            DayRing(log: log, size: 34, stroke: 4),
            Text(numbers(day.day), style: WaqtText.caption.copyWith(color: t.ink, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

/// The year so far, one cell per day, shaded by how many prayers were kept.
class _YearField extends StatelessWidget {
  const _YearField({required this.stats, required this.today});
  final DeedStats stats;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    final start = today.subtract(const Duration(days: 52 * 7 - 1));
    return LayoutBuilder(
      builder: (context, c) {
        const cols = 26, rows = 14; // half a year per row-block: fits a phone
        final cell = (c.maxWidth - (cols - 1) * 3) / cols;
        return Semantics(
          label: AppLocalizations.of(context).progressYear,
          child: CustomPaint(
            size: Size(c.maxWidth, rows * (cell + 3)),
            painter: _FieldPainter(
              counts: [for (var i = 0; i < cols * rows; i++) _count(start.add(Duration(days: i)))],
              cols: cols,
              cell: cell,
              accent: t.accent,
              ink: t.ink,
            ),
          ),
        );
      },
    );
  }

  /// -1 = in the future, else prayers kept (0..5).
  int _count(DateTime d) => d.isAfter(today) ? -1 : stats.of(d).prayed;
}

class _FieldPainter extends CustomPainter {
  _FieldPainter({
    required this.counts,
    required this.cols,
    required this.cell,
    required this.accent,
    required this.ink,
  });
  final List<int> counts;
  final int cols;
  final double cell;
  final Color accent, ink;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < counts.length; i++) {
      final c = counts[i];
      if (c < 0) continue;
      final x = (i % cols) * (cell + 3), y = (i ~/ cols) * (cell + 3);
      final color = c == 0 ? ink.withValues(alpha: 0.07) : Color.lerp(accent.withValues(alpha: 0.25), accent, c / 5)!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, cell, cell), Radius.circular(cell * 0.3)),
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_FieldPainter o) => o.counts != counts || o.accent != accent || o.ink != ink || o.cell != cell;
}

class _Number extends StatelessWidget {
  const _Number({required this.label, required this.value, this.last = false});
  final String label, value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x4, vertical: WaqtSpace.x4),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: t.hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: WaqtText.body.copyWith(color: t.ink)),
          ),
          Text(value, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
        ],
      ),
    );
  }
}
