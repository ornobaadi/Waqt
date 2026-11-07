import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../domain/prayer/prayer_times_service.dart';
import '../../l10n/app_localizations.dart';
import 'moment_cards.dart';

/// Ramadan's two times: when suhoor ends (Fajr) and when to break the fast
/// (Maghrib). The one coming next is lit and counts down.
class RamadanCard extends StatelessWidget {
  const RamadanCard({
    super.key,
    required this.status,
    required this.now,
    required this.day,
    required this.fastingTomorrow,
  });
  final PrayerStatus status;
  final DateTime now;
  final int day;

  /// False on the last evening of Ramadan: no suhoor before Eid.
  final bool fastingTomorrow;

  /// Whether there is a suhoor or an iftar still ahead. On the last evening
  /// of Ramadan there is neither, and the card would say only "done".
  static bool hasTimes(PrayerStatus status, DateTime now, bool fastingTomorrow) =>
      now.isBefore(status.today[Waqt.maghrib]) || fastingTomorrow;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final n = LocaleDigits(Localizations.localeOf(context).toLanguageTag());
    final fmt = clockFormat(context);
    final fajr = status.today[Waqt.fajr];
    final maghrib = status.today[Waqt.maghrib];

    // Before Fajr: today's suhoor. After Maghrib: tomorrow's (if fasting).
    final DateTime? suhoor = now.isBefore(fajr)
        ? fajr
        : !now.isBefore(maghrib) && fastingTomorrow
        ? (status.next == Waqt.fajr ? status.nextAt : fajr.add(const Duration(days: 1)))
        : null;
    final DateTime? iftar = !now.isBefore(fajr) && now.isBefore(maghrib) ? maghrib : null;
    final next = iftar ?? suhoor;

    String left(DateTime at) {
      final d = at.difference(now);
      final h = d.inHours, m = d.inMinutes % 60;
      return h > 0 ? l.durHm(n(h), n(m)) : l.durM(n(m < 1 ? 1 : m));
    }

    Widget tile(String label, DateTime? at, DateTime fallback) {
      final lit = at != null && at == next;
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(WaqtSpace.x4),
          decoration: BoxDecoration(
            color: lit ? t.heroInk.withValues(alpha: 0.1) : Colors.transparent,
            // Concentric with the card: its radius minus the 8 px inset.
            borderRadius: BorderRadius.circular(WaqtRadii.card - WaqtSpace.x2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: WaqtText.caption.copyWith(color: t.heroInk.withValues(alpha: 0.7))),
              const SizedBox(height: WaqtSpace.x1),
              Text(
                fmt.format(at ?? fallback),
                style: WaqtText.titleSmall.copyWith(color: at == null ? t.heroInk.withValues(alpha: 0.4) : t.heroInk),
              ),
              const SizedBox(height: WaqtSpace.x1),
              Text(
                lit ? l.ramadanIn(left(at)) : (at == null ? l.ramadanDone : ''),
                style: WaqtText.caption.copyWith(color: lit ? t.accent : t.heroInk.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(WaqtSpace.x2),
      decoration: BoxDecoration(
        color: t.heroSurface,
        borderRadius: BorderRadius.circular(WaqtRadii.card),
        boxShadow: t.hero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(WaqtSpace.x4, WaqtSpace.x3, WaqtSpace.x4, 0),
            child: Row(
              children: [Text(l.occRamadan(n(day)).toUpperCase(), style: WaqtText.overline.copyWith(color: t.accent))],
            ),
          ),
          const SizedBox(height: WaqtSpace.x2),
          Row(
            children: [
              tile(l.ramadanSuhoor, suhoor, fajr),
              const SizedBox(width: WaqtSpace.x2),
              tile(l.ramadanIftar, iftar, maghrib),
            ],
          ),
        ],
      ),
    );
  }
}
