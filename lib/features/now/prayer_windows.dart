import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../domain/prayer/prayer_times_service.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';
import 'moment_cards.dart';

/// The five prayers in one row. The prayer in progress is lit, says when its
/// time runs out ("→ 5:17"), and fills from the start edge as that time is
/// used, so the end of the waqt is visible without another line of text.
class PrayerWindows extends StatelessWidget {
  const PrayerWindows({super.key, required this.status, required this.now});
  final PrayerStatus status;
  final DateTime now;

  static const prayers = [Waqt.fajr, Waqt.dhuhr, Waqt.asr, Waqt.maghrib, Waqt.isha];

  /// When each window closes. Isha runs to Fajr.
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
    // Before today's Fajr, last night's Isha is running: no cell of today is.
    final open = status.today[status.current].isAfter(now) ? null : status.current;
    // Large text: two rows instead of one.
    final rows = MediaQuery.textScalerOf(context).scale(10) > 13 ? 2 : 1;
    final per = (prayers.length / rows).ceil();

    Widget cell(Waqt w) =>
        _Cell(waqt: w, start: status.today[w], end: endOf(w), now: now, open: w == open, past: !endOf(w).isAfter(now));

    return Material(
      color: t.surface,
      borderRadius: BorderRadius.circular(WaqtRadii.strip),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/today'),
        child: Padding(
          padding: const EdgeInsets.all(WaqtSpace.x1),
          child: Column(
            children: [
              for (var r = 0; r < rows; r++)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final w in prayers.skip(r * per).take(per)) Expanded(child: cell(w)),
                      // Keep cells the same width on a short last row.
                      for (var i = prayers.skip(r * per).take(per).length; i < per; i++)
                        const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.waqt,
    required this.start,
    required this.end,
    required this.now,
    required this.open,
    required this.past,
  });
  final Waqt waqt;
  final DateTime start, end, now;
  final bool open, past;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final fmt = clockFormat(context);
    final total = end.difference(start).inSeconds;
    final used = total <= 0 ? 0.0 : (now.difference(start).inSeconds / total).clamp(0.0, 1.0);
    final fg = open ? t.ground : t.ink;
    final time = _hm(context, start);

    return Semantics(
      selected: open,
      label: '${l.waqt(waqt)} ${fmt.format(start)} – ${fmt.format(end)}',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: WaqtMotion.ui,
        curve: WaqtMotion.ease,
        constraints: const BoxConstraints(minHeight: 64),
        decoration: BoxDecoration(
          color: open ? t.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(WaqtRadii.row),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Time already used: a lighter wash from the start edge.
            if (open)
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: used,
                  child: ColoredBox(color: t.accent.withValues(alpha: 0.28)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: WaqtSpace.x2, horizontal: 2),
              child: Opacity(
                opacity: past ? 0.45 : 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l.waqt(waqt),
                      style: WaqtText.caption.copyWith(color: open ? fg.withValues(alpha: 0.75) : t.inkMuted),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    const SizedBox(height: WaqtSpace.x1),
                    Text(time, style: WaqtText.bodyStrong.copyWith(color: fg)),
                    if (open) ...[
                      const SizedBox(height: 2),
                      Text(
                        '→ ${_hm(context, end)}',
                        style: WaqtText.caption.copyWith(color: fg.withValues(alpha: 0.8)),
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Compact time for a cell: no day period, which the column order implies.
  static String _hm(BuildContext context, DateTime d) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return (MediaQuery.alwaysUse24HourFormatOf(context) ? DateFormat.Hm(locale) : DateFormat('h:mm', locale)).format(d);
  }
}
