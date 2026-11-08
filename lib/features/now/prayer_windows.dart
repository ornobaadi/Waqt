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
    final hint = ref.watch(beadHintProvider);
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
      // The meter: what is left of this waqt. Gone once over, full before it starts.
      var left = ended ? 0.0 : 1.0;
      if (current) {
        final start = status.today[w], end = _endOf(w);
        final total = end.difference(start).inSeconds;
        left = total <= 0 ? 0 : (end.difference(now).inSeconds / total).clamp(0.0, 1.0);
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
          if (m != null) ref.read(beadHintProvider.notifier).marked();
        },
      );
    }

    final twoRows = MediaQuery.textScalerOf(context).scale(10) > 13;
    final per = twoRows ? 3 : 5;
    return Container(
      padding: const EdgeInsets.all(_inset),
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
          if (hint) const _Legend(),
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
            // What is left of this waqt, draining toward its end.
            PositionedDirectional(
              start: 6,
              end: 6,
              bottom: 5,
              child: Container(
                height: 3,
                alignment: AlignmentDirectional.centerEnd,
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
            if (m != null)
              PositionedDirectional(
                top: 4,
                end: 4,
                child: Icon(markIcon(m), size: 13, color: ink.withValues(alpha: 0.9)),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, WaqtSpace.x4 + 2, 2, WaqtSpace.x4),
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
                        color: ink.withValues(alpha: m == null ? 0.65 : 0.85),
                        fontWeight: current ? FontWeight.w700 : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(time, maxLines: 1, style: WaqtText.bodyStrong.copyWith(color: ink)),
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
            const SizedBox(height: WaqtSpace.x1),
            Text(
              note,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: WaqtText.caption.copyWith(
                fontSize: 11,
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

/// Shown until someone has marked a few prayers: what the colours and signs
/// mean, and how to change them. Dismissable.
class _Legend extends ConsumerWidget {
  const _Legend();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    Widget key(SalahMark m, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SalahSwatch(mark: m, size: 18),
        const SizedBox(width: 6),
        Text(label, style: WaqtText.caption.copyWith(color: t.ink)),
      ],
    );
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, WaqtSpace.x3, 2, WaqtSpace.x1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: WaqtSpace.x4,
                  runSpacing: WaqtSpace.x2,
                  children: [
                    key(SalahMark.onTime, l.beadAlone),
                    key(SalahMark.jamaah, l.beadJamaah),
                    key(SalahMark.qada, l.beadLate),
                  ],
                ),
                const SizedBox(height: WaqtSpace.x2),
                Text(l.beadHint, style: WaqtText.caption.copyWith(color: t.inkMuted)),
              ],
            ),
          ),
          IconButton(
            tooltip: l.beadHintDismiss,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close_rounded, size: 18, color: t.inkMuted),
            onPressed: ref.read(beadHintProvider.notifier).dismiss,
          ),
        ],
      ),
    );
  }
}
