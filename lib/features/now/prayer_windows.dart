import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../data/user/deeds_store.dart';
import '../../domain/deeds/deeds.dart';
import '../../domain/prayer/prayer_times_service.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/haptics/haptics.dart';
import '../common/labels.dart';
import 'prayer_tick.dart';

/// The five prayers as five beads in one row. Each bead is also the way to
/// tick it: tap when prayed (made up late once its time has gone), tap
/// again to clear, hold for the detail. Colour alone tells how it was kept.
/// The running prayer's bead holds what is left of its time as a fill that
/// drains toward its end.
class PrayerWindows extends ConsumerWidget {
  const PrayerWindows({super.key, required this.status, required this.now});
  final PrayerStatus status;
  final DateTime now;

  static const prayers = fivePrayers;

  /// Bead corners: the strip's radius minus its inset, kept small on purpose.
  static const double _outer = 12, _inset = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final n = LocaleDigits(locale);
    final fmt = MediaQuery.alwaysUse24HourFormatOf(context) ? DateFormat.Hm(locale) : DateFormat('h:mm', locale);

    // Before Fajr the night still belongs to yesterday's prayer day.
    final prevDay = now.isBefore(status.today[Waqt.fajr]);
    final dayKey = DeedStats.dayKey(prevDay ? status.today[Waqt.fajr].subtract(const Duration(days: 1)) : now);
    final log = ref.watch(deedsProvider.select((d) => d[dayKey] ?? DayLog.empty));
    final running = status.current != Waqt.sunrise;

    Widget bead(Waqt w) {
      final started = prevDay || !status.today[w].isAfter(now);
      final ended = prevDay ? w != Waqt.isha : !_endOf(w).isAfter(now);
      final current = running && w == status.current && started && !ended;
      // The meter fills as the waqt passes: empty before it starts, full once over.
      var left = ended ? 1.0 : 0.0;
      if (current) {
        final start = status.today[w], end = _endOf(w);
        final total = end.difference(start).inSeconds;
        left = total <= 0 ? 1 : (now.difference(start).inSeconds / total).clamp(0.0, 1.0);
      }
      final note = ended
          ? l.beadEnded
          : current
          ? l.beadLeft(_short(l, n, _endOf(w).difference(now)))
          : !started
          ? l.beadIn(_short(l, n, status.today[w].difference(now)))
          : '';
      return _Bead(
        prayer: w,
        time: fmt.format(status.today[w]),
        mark: log.salah[w],
        started: started,
        ended: ended,
        current: current,
        left: left,
        note: note,
        radius: _outer - _inset,
        onMark: (m) {
          if (m == null) {
            Haptics.tick();
          } else {
            Haptics.click();
          }
          ref.read(deedsProvider.notifier).markSalah(dayKey, w, m);
        },
      );
    }

    final twoRows = MediaQuery.textScalerOf(context).scale(10) > 13;
    final per = twoRows ? 3 : 5;
    return Container(
      padding: const EdgeInsets.fromLTRB(_inset + 2, _inset + 2, _inset + 2, WaqtSpace.x2),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(_outer)),
      child: Column(
        children: [
          for (var r = 0; r * per < prayers.length; r++)
            Padding(
              padding: EdgeInsets.only(top: r == 0 ? 0 : _inset),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = r * per; i < r * per + per; i++) ...[
                      if (i > r * per) const SizedBox(width: _inset),
                      Expanded(child: i < prayers.length ? bead(prayers[i]) : const SizedBox()),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _short(AppLocalizations l, LocaleDigits n, Duration d) {
    final h = d.inHours, m = d.inMinutes % 60;
    return h > 0 ? l.durShortHm(n(h), n(m)) : l.durShortM(n(m < 1 ? 1 : m));
  }

  /// When a prayer's own time runs out: Fajr at sunrise, the rest at the next.
  DateTime _endOf(Waqt w) => switch (w) {
    Waqt.fajr => status.today[Waqt.sunrise],
    Waqt.isha => status.today[Waqt.fajr].add(const Duration(days: 1)), // about tomorrow's Fajr
    _ => status.today[Waqt.values[w.index + 1]],
  };
}

class _Bead extends StatelessWidget {
  const _Bead({
    required this.prayer,
    required this.time,
    required this.mark,
    required this.started,
    required this.ended,
    required this.current,
    required this.left,
    required this.note,
    required this.radius,
    required this.onMark,
  });

  final Waqt prayer;
  final String time;
  final SalahMark? mark;
  final bool started, ended, current;
  final double left;
  final String note;
  final double radius;
  final ValueChanged<SalahMark?> onMark;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final m = mark;
    final fill = m == null ? (current ? t.ink.withValues(alpha: 0.05) : Colors.transparent) : MarkColors.of(t, m);
    final ink = m == null ? t.ink : MarkColors.on(t, m);
    final r = BorderRadius.circular(radius);
    final fast = MediaQuery.disableAnimationsOf(context) ? Duration.zero : WaqtMotion.ui;

    final body = AnimatedContainer(
      duration: fast,
      curve: WaqtMotion.ease,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: r,
        border: m != null
            ? null
            : current
            ? Border.all(color: t.ink.withValues(alpha: 0.7), width: 1.5)
            : started
            ? Border.all(color: t.ink.withValues(alpha: 0.14))
            : null,
      ),
      child: ClipRRect(
        borderRadius: r,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // How much of this waqt has passed.
            PositionedDirectional(
              start: 8,
              end: 8,
              bottom: 6,
              child: Container(
                height: 3,
                alignment: AlignmentDirectional.centerStart,
                decoration: BoxDecoration(
                  color: ink.withValues(alpha: m == null ? 0.1 : 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  widthFactor: left,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: m != null ? ink : (current ? t.ink : t.ink.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            // How it was kept: a small, quiet sign in the corner.
            if (m != null)
              PositionedDirectional(
                end: 5,
                top: 4,
                child: MarkSign(mark: m, size: 11, color: ink.withValues(alpha: 0.65)),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 15, 2, 14),
              child: Opacity(
                opacity: started ? 1 : 0.45,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.waqt(prayer),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: WaqtText.caption.copyWith(
                        fontSize: 11,
                        color: ink.withValues(alpha: m == null ? 0.6 : 0.85),
                        fontWeight: current ? FontWeight.w600 : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      maxLines: 1,
                      style: WaqtText.bodyStrong.copyWith(color: ink, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: started,
      checked: started ? m != null : null,
      label: '${l.waqt(prayer)} $time, $note${started ? ', ${markLabel(l, m)}' : ''}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Tap cycles: prayed (alone, or late once its time is over), then congregation, then clear.
        onTap: started
            ? () => onMark(switch (m) {
                null => ended ? SalahMark.qada : SalahMark.onTime,
                SalahMark.jamaah => null,
                _ => SalahMark.jamaah,
              })
            : null,
        onLongPress: started
            ? () async {
                Haptics.tick();
                final picked = await showSalahSheet(context, prayer, m);
                if (picked != null) onMark(picked.$1);
              }
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _Press(child: body)),
            const SizedBox(height: 6),
            Text(
              note,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: WaqtText.caption.copyWith(
                fontSize: 10.5,
                color: current ? t.ink : t.inkMuted,
                fontWeight: current ? FontWeight.w700 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A short squash on touch, springing back.
class _Press extends StatefulWidget {
  const _Press({required this.child});
  final Widget child;

  @override
  State<_Press> createState() => _PressState();
}

class _PressState extends State<_Press> {
  bool _down = false;

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => setState(() => _down = true),
    onPointerUp: (_) => setState(() => _down = false),
    onPointerCancel: (_) => setState(() => _down = false),
    child: AnimatedScale(
      scale: _down ? 0.94 : 1,
      duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 220),
      curve: _down ? Curves.easeOut : Curves.easeOutBack,
      child: widget.child,
    ),
  );
}
