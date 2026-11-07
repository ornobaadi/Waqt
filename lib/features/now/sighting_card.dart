import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_state.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../data/hijri/calendar_sync.dart';
import '../../data/user/user_prefs.dart';
import '../../domain/hijri/hijri_service.dart';
import '../../domain/prayer/prayer_times_service.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';

/// Months whose start decides a fast or a festival: Ramadan, Shawwal (Eid
/// al-Fitr) and Dhul Hijjah (Arafah, Eid al-Adha). Asked on the 29th of the
/// month before.
const _askBefore = {8, 9, 11};

/// The question asked on the evening of the 29th, if it applies now.
/// Returns the month that may begin tomorrow.
({int year, int month})? sightingQuestion(WidgetRef ref) {
  final status = ref.watch(prayerStatusProvider);
  if (status == null) return null;
  final now = ref.watch(placeNowProvider);
  final maghrib = status.today[Waqt.maghrib];
  // From Maghrib until midnight, on the 29th by today's daytime date.
  if (now.isBefore(maghrib) || status.current == Waqt.fajr || status.current == Waqt.sunrise) return null;
  if (ref.watch(calendarSyncProvider.select((s) => s.authority)) != HijriAuthority.local) return null;
  final h = ref.watch(occasionsProvider).date;
  if (h.day != 29 || !_askBefore.contains(h.month)) return null;
  final next = h.month == 12 ? (year: h.year + 1, month: 1) : (year: h.year, month: h.month + 1);
  return ref.watch(sightingAnswersProvider).contains(_key(next)) ? null : next;
}

String _key(({int year, int month}) m) => sightingKey(m.year, m.month);

/// The offset (within the allowed ±2) that makes tomorrow's daytime date the
/// 1st of [month] if the moon was seen, or the 30th of the month before if
/// it was not. Null if no allowed offset does.
int? offsetFor(DateTime now, ({int year, int month}) next, {required bool seen}) {
  final tomorrow = DateTime(now.year, now.month, now.day + 1, 12);
  final prev = next.month == 1 ? 12 : next.month - 1;
  const order = [0, 1, -1, 2, -2];
  bool ok(int o, int day) {
    final d = const HijriService().dateFor(tomorrow, offset: o);
    return seen ? (d.month == next.month && d.day == 1) : (d.month == prev && d.day == day);
  }

  // Not seen: tomorrow completes thirty. Where the tabular month has only
  // 29 days there is no 30th to show, so the 29th repeats and the new month
  // still starts a day later, which is what matters.
  for (final day in seen ? const [1] : const [30, 29]) {
    for (final o in order) {
      if (ok(o, day)) return o;
    }
  }
  return null;
}

/// "Was the new moon seen where you are?" The answer sets the Hijri
/// adjustment, so Ramadan, Eid and Arafah fall on the days your community
/// keeps. Shown once per month, on the evening it matters.
class SightingCard extends ConsumerWidget {
  const SightingCard({super.key, required this.next});
  final ({int year, int month}) next;

  void _answer(WidgetRef ref, bool? seen) {
    final now = ref.read(placeNowProvider);
    if (seen != null) {
      final o = offsetFor(now, next, seen: seen);
      if (o != null) ref.read(userPrefsProvider.notifier).setHijriOffset(o);
    }
    ref.read(sightingAnswersProvider.notifier).add(_key(next));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final month = l.hijriMonth(next.month);
    return Container(
      padding: const EdgeInsets.all(WaqtSpace.x5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(WaqtRadii.card),
        border: Border.all(color: t.ink.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.brightness_3_outlined, size: 20, color: t.ink),
              const SizedBox(width: WaqtSpace.x2),
              Expanded(
                child: Text(l.sightingTitle(month), style: WaqtText.bodyStrong.copyWith(color: t.ink)),
              ),
            ],
          ),
          const SizedBox(height: WaqtSpace.x2),
          Text(l.sightingBody, style: WaqtText.body.copyWith(color: t.inkMuted)),
          const SizedBox(height: WaqtSpace.x4),
          Wrap(
            spacing: WaqtSpace.x2,
            runSpacing: WaqtSpace.x2,
            children: [
              FilledButton(
                onPressed: () => _answer(ref, true),
                style: FilledButton.styleFrom(backgroundColor: t.ink, foregroundColor: t.ground),
                child: Text(l.sightingSeen(month)),
              ),
              OutlinedButton(
                onPressed: () => _answer(ref, false),
                style: OutlinedButton.styleFrom(foregroundColor: t.ink),
                child: Text(l.sightingNotSeen),
              ),
              TextButton(
                onPressed: () => _answer(ref, null),
                style: TextButton.styleFrom(foregroundColor: t.inkMuted),
                child: Text(l.sightingUnsure),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// On the evening of the 29th, with an authority's calendar: what tomorrow is
/// by the latest download, and that the app keeps checking tonight.
({int month, HijriDate tomorrow, bool known})? announcementQuestion(WidgetRef ref) {
  final sync = ref.watch(calendarSyncProvider);
  if (sync.authority == HijriAuthority.local) return null;
  final status = ref.watch(prayerStatusProvider);
  if (status == null) return null;
  final now = ref.watch(placeNowProvider);
  if (now.isBefore(status.today[Waqt.maghrib]) || status.current == Waqt.fajr || status.current == Waqt.sunrise) {
    return null;
  }
  final h = ref.watch(occasionsProvider).date;
  if (h.day != 29 || !_askBefore.contains(h.month)) return null;
  final day = DateTime(now.year, now.month, now.day + 1, 12);
  final tomorrow = ref.watch(hijriServiceProvider).dateFor(day, offset: ref.watch(hijriOffsetProvider));
  // Known only if the downloaded months cover tomorrow; otherwise the date
  // is Umm al-Qura's estimate and must not be presented as announced.
  return (month: h.month == 12 ? 1 : h.month + 1, tomorrow: tomorrow, known: sync.table.lookup(day) != null);
}

class AnnouncementCard extends ConsumerWidget {
  const AnnouncementCard({super.key, required this.month, required this.tomorrow, required this.known});
  final int month;
  final HijriDate tomorrow;
  final bool known;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final sync = ref.watch(calendarSyncProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final checked = sync.checkedAt == null ? null : DateFormat.jm(locale).format(sync.checkedAt!);
    final begins = tomorrow.month == month && tomorrow.day == 1;
    return Container(
      padding: const EdgeInsets.all(WaqtSpace.x5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(WaqtRadii.card),
        border: Border.all(color: t.ink.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.brightness_3_outlined, size: 20, color: t.ink),
              const SizedBox(width: WaqtSpace.x2),
              Expanded(
                child: Text(l.announceTitle(l.hijriMonth(month)), style: WaqtText.bodyStrong.copyWith(color: t.ink)),
              ),
            ],
          ),
          const SizedBox(height: WaqtSpace.x2),
          Text(
            !known
                ? l.announceUnknown(l.hijriMonth(month))
                : begins
                ? l.announceBegins(l.hijriMonth(month), l.authorityName(sync.authority))
                : l.announceThirty(l.hijriMonth(tomorrow.month), l.authorityName(sync.authority)),
            style: WaqtText.body.copyWith(color: t.ink),
          ),
          const SizedBox(height: WaqtSpace.x2),
          Text(
            sync.failed || checked == null ? l.announceOffline : l.announceChecking(checked),
            style: WaqtText.caption.copyWith(color: t.inkMuted),
          ),
        ],
      ),
    );
  }
}
