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

    // Two halves built the same way so label, time and status line up,
    // on one soft surface: no outline, no boxes inside.
    Widget half(String label, DateTime? at, DateTime fallback) {
      final lit = at != null && at == next;
      final parts = fmt.format(at ?? fallback).split(RegExp(r'\s+'));
      return Opacity(
        opacity: at == null ? 0.45 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: WaqtText.label.copyWith(color: t.inkMuted)),
            const SizedBox(height: WaqtSpace.x1),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: parts.first,
                      style: WaqtText.title.copyWith(color: t.ink),
                    ),
                    if (parts.length > 1)
                      TextSpan(
                        text: ' ${parts.sublist(1).join(' ')}',
                        style: WaqtText.label.copyWith(color: t.ink, fontWeight: FontWeight.w700),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              lit ? l.ramadanIn(left(at)) : (at == null ? l.ramadanDone : ' '),
              style: WaqtText.label.copyWith(
                color: lit ? Color.lerp(t.ink, t.accent, 0.65) : t.inkMuted,
                fontWeight: lit ? FontWeight.w700 : null,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(WaqtSpace.x5, WaqtSpace.x4, WaqtSpace.x5, WaqtSpace.x4),
      decoration: BoxDecoration(
        color: t.ink.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(WaqtRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: half(l.ramadanSuhoor, suhoor, fajr)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x4, vertical: WaqtSpace.x1),
                  child: VerticalDivider(width: 1, thickness: 1, color: t.ink.withValues(alpha: 0.12)),
                ),
                Expanded(child: half(l.ramadanIftar, iftar, maghrib)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
