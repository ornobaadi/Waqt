import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/app_state.dart';
import '../../app/sync.dart';
import '../../core/config/runtime.dart';
import '../../domain/notifications/reminder_planner.dart';
import '../settings/reminder_preview.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../data/user/checklist.dart';
import '../../data/user/notification_prefs.dart';
import '../../data/user/user_prefs.dart';
import '../../domain/moments/moment.dart';
import '../../domain/occasions/occasions.dart';
import '../../domain/prayer/prayer_times_service.dart';
import '../../domain/time/place_zone.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/location/gps.dart';
import '../common/labels.dart';
import 'moment_cards.dart';
import '../../data/sources/days.dart';
import 'celestial.dart';
import '../duas/library_views.dart';
import 'day_guide_card.dart';
import 'ramadan_card.dart';
import 'sighting_card.dart';
import 'prayer_windows.dart';
import 'sky_background.dart';

/// Home v0: where you are, what time it is in the prayer day, what's next.
class NowScreen extends ConsumerWidget {
  const NowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = ref.watch(placeNowProvider);
    final place = ref.watch(userPrefsProvider.select((p) => p.place));
    final status = ref.watch(prayerStatusProvider);
    final moments = ref.watch(momentSnapshotProvider);
    final guides = ref.watch(dayGuidesProvider).value;
    final hijri = ref.watch(hijriDateProvider);
    final occ = ref.watch(occasionsProvider);
    final occasions = occ.list;
    final n = LocaleDigits(locale);

    final dateLine = '${DateFormat.MMMEd(locale).format(now)}  ·  ${l.hijri(hijri, n.call)}';

    final palette = ref.watch(activePaletteProvider);
    // Ramadan's count follows the date on screen, which turns at Maghrib.
    final ramadanDay = hijri.month == 9 ? hijri.day : occ.date.day;
    final guideOcc = guides?.featured(occasions);
    final sighting = sightingQuestion(ref);
    final announcement = announcementQuestion(ref);
    // Undecided 29th of Ramadan: tomorrow may be the 30th fast, so suhoor
    // stays on screen until the sighting is known.
    final undecidedEid =
        (announcement != null && !announcement.known && announcement.month == 10) || sighting?.month == 10;
    final ramadanTomorrow = undecidedEid || ref.watch(tomorrowOccasionsProvider).contains(OccasionId.ramadan);
    // Before Maghrib: today's Sunnah fast. After it: tomorrow's, so there is
    // time to intend it and eat suhoor.
    final afterMaghrib = status != null && !now.isBefore(status.today[Waqt.maghrib]) && status.current != Waqt.fajr;
    final fastOcc = guides == null
        ? null
        : (afterMaghrib ? ref.watch(tomorrowOccasionsProvider) : occasions).where(guides.fasts.contains).firstOrNull;
    final fastText = fastOcc == null
        ? null
        : (afterMaghrib ? l.fastTomorrow : l.fastToday)(l.occasion(fastOcc, ramadanDay: n(ramadanDay)));
    return Stack(
      children: [
        Positioned(top: 0, left: 0, right: 0, height: 520, child: SkyBackground(palette: palette)),
        SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              WaqtSpace.screen,
              WaqtSpace.x3,
              WaqtSpace.screen,
              WaqtSpace.x8 + MediaQuery.paddingOf(context).bottom, // clear the floating dock
            ),
            children: [
              Row(
                children: [
                  // The city is the one thing on Home you may want to change.
                  // Expanded, not Flexible + Spacer: those split the free
                  // space and left the pill in the middle.
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(WaqtRadii.row),
                        onTap: () => context.push('/settings/city'),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: WaqtSpace.minTouch),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  place?.name ?? l.appName,
                                  style: WaqtText.bodyStrong.copyWith(color: t.ink),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (place != null) Icon(Icons.expand_more_rounded, size: 20, color: t.inkMuted),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // A quiet ringed button, like the dock's: the Qibla finder.
                  Tooltip(
                    message: l.qiblaTitle,
                    child: Material(
                      type: MaterialType.transparency,
                      shape: CircleBorder(side: BorderSide(color: t.ink.withValues(alpha: 0.22))),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => context.push('/qibla'),
                        child: SizedBox.square(
                          dimension: WaqtSpace.minTouch,
                          child: Icon(Icons.explore_outlined, size: 22, color: t.ink, semanticLabel: l.qiblaTitle),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Another city's clock: say so, so the big time isn't mistaken
              // for the phone's.
              if (place != null && differsFromDevice(ref.watch(placeZoneProvider), now))
                Row(
                  children: [
                    Icon(Icons.public_rounded, size: 14, color: t.inkMuted),
                    const SizedBox(width: WaqtSpace.x1),
                    Text(l.placeTime(place.name), style: WaqtText.caption.copyWith(color: t.inkMuted)),
                  ],
                ),
              const SizedBox(height: WaqtSpace.x4),
              // The moon or sun sits behind the hero at the end edge, partly
              // past the screen, so it is large without pushing text down.
              Stack(
                clipBehavior: Clip.none,
                children: [
                  PositionedDirectional(
                    end: -64,
                    top: -36,
                    child: Celestial(at: now, night: palette.isDark, southern: (place?.latitude ?? 0) < 0, size: 140),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Room for the moon: long times scale down instead of
                      // running into it.
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 124),
                        child: _Clock(now: now, locale: locale),
                      ),
                      if (status != null) ...[
                        const SizedBox(height: WaqtSpace.x1),
                        _HeroLines(title: l.waqt(status.current), status: status, now: now, numbers: n),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: WaqtSpace.x3),
              // The date opens the month: what is coming, and what each day holds.
              InkWell(
                borderRadius: BorderRadius.circular(WaqtRadii.row),
                onTap: () => context.push('/calendar'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: WaqtSpace.x1),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(dateLine, style: WaqtText.label.copyWith(color: t.inkMuted)),
                      ),
                      const SizedBox(width: WaqtSpace.x1),
                      Icon(Icons.calendar_month_outlined, size: 16, color: t.inkMuted),
                    ],
                  ),
                ),
              ),
              // One pill under the date: today's Sunnah fast, else the day itself.
              if ((fastText ?? (occasions.isEmpty ? null : l.occasion(occasions.first, ramadanDay: n(ramadanDay))))
                  case final pill?) ...[
                const SizedBox(height: WaqtSpace.x3),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FastingPill(text: pill),
                ),
              ],
              const SizedBox(height: WaqtSpace.x6),
              if (status != null) PrayerWindows(status: status, now: now),
              if (status?.today.estimated ?? false) ...[
                const SizedBox(height: WaqtSpace.x3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x1),
                  child: Text(l.timesEstimated, style: WaqtText.caption.copyWith(color: t.ink)),
                ),
              ],
              if (place != null && !ref.watch(notificationPrefsProvider.select((p) => p.setupDismissed))) ...[
                const SizedBox(height: WaqtSpace.x4),
                _SetupCard(
                  next: ref.watch(upcomingRemindersProvider).firstOrNull,
                  onSetup: () async {
                    ref.read(notificationPrefsProvider.notifier)
                      ..enableRecommended()
                      ..dismissSetup();
                    if (Runtime.hasPlatformPlugins) await ref.read(notificationServiceProvider).requestNotifications();
                    await syncNow(ref);
                    if (context.mounted) unawaited(context.push('/settings/notifications'));
                  },
                  onDismiss: () => ref.read(notificationPrefsProvider.notifier).dismissSetup(),
                ),
              ],
              if (status != null &&
                  occasions.contains(OccasionId.ramadan) &&
                  RamadanCard.hasTimes(status, now, ramadanTomorrow)) ...[
                const SizedBox(height: WaqtSpace.x4),
                RamadanCard(
                  status: status,
                  now: now,
                  // After Maghrib, the fast ahead is tomorrow's, as the date shows.
                  day: undecidedEid ? 30 : hijri.day,
                  fastingTomorrow: ramadanTomorrow,
                ),
              ],
              if (announcement != null) ...[
                const SizedBox(height: WaqtSpace.x4),
                AnnouncementCard(month: announcement.month, tomorrow: announcement.tomorrow, known: announcement.known),
              ],
              if (sighting != null) ...[const SizedBox(height: WaqtSpace.x4), SightingCard(next: sighting)],
              // Everything happening now, newest on top: when Bedtime begins
              // at 9 pm, it sits above "After Isha", which runs until Fajr.
              if (moments != null)
                for (final m in nowStack(moments.active, guides)) ...[
                  const SizedBox(height: WaqtSpace.x4),
                  if (checklistMoments.contains(m.id))
                    DayGuideCard(
                      // Bedtime and Friday: sourced practices, ticked per prayer day.
                      label: l.rightNow,
                      title: m.id == MomentId.bedtime ? l.checklistTitleBedtime : l.checklistTitleJumuah,
                      items: guides!.forMoment(m.id),
                      day: '${m.id.name}-${prayerDayKey(moments.timeline.first.window.start)}',
                    )
                  else
                    RightNowCard(
                      moment: m,
                      now: now,
                      // Only sourced, checked items: nothing unreviewed on Home.
                      items: const [],
                      sourced: guides?.forMoment(m.id) ?? const [],
                      onSourced: (i) => openItem(context, ref, i),
                    ),
                ],
              if (guideOcc != null && guides != null) ...[
                const SizedBox(height: WaqtSpace.x4),
                DayGuideCard(
                  title: l.occasion(guideOcc, ramadanDay: n(ramadanDay)),
                  items: guides.itemsFor(guideOcc, occasions),
                  day: '${now.year}-${now.month}-${now.day}',
                  morningOver: status != null && !now.isBefore(status.today[Waqt.dhuhr]),
                  phase: status == null
                      ? null
                      : now.isBefore(status.today[Waqt.fajr])
                      ? 'suhoor'
                      : now.isBefore(status.today[Waqt.asr])
                      ? 'day'
                      : now.isBefore(status.today[Waqt.isha])
                      ? 'iftar'
                      : 'night',
                ),
              ],
              if (moments != null && moments.upcoming.isNotEmpty) ...[
                const SizedBox(height: WaqtSpace.x6),
                ComingUp(moments: moments.upcoming, now: now),
              ],
              if (place == null) ...[const SizedBox(height: WaqtSpace.x4), const _LocationCard()],
            ],
          ),
        ),
      ],
    );
  }
}

class _Clock extends StatelessWidget {
  const _Clock({required this.now, required this.locale});
  final DateTime now;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    final h24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final hm = (h24 ? DateFormat.Hm(locale) : DateFormat('h:mm', locale)).format(now);
    final suffix = h24 ? DateFormat('ss', locale).format(now) : DateFormat('a', locale).format(now);
    // Some locales' day-period is a single letter ("a"/"p"): drop it, the
    // prayer context already says morning or evening.
    final showSuffix = suffix.trim().length > 1 || h24;

    return Semantics(
      label: DateFormat.jm(locale).format(now),
      excludeSemantics: true,
      // Large text: the clock scales down to fit rather than overflow.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(hm, style: WaqtText.clock.copyWith(color: t.ink, fontSize: 76)),
            if (showSuffix) ...[
              const SizedBox(width: WaqtSpace.x2),
              Text(suffix, style: WaqtText.titleSmall.copyWith(color: t.inkMuted)),
            ],
          ],
        ),
      ),
    );
  }
}

/// `1:05:09` above an hour, `05:09` below. Digits follow the locale.
String formatCountdown(Duration d, LocaleDigits n) {
  final s = d.inSeconds < 0 ? 0 : d.inSeconds;
  final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
  return h > 0 ? '${n(h)}:${n(m, pad: 2)}:${n(sec, pad: 2)}' : '${n(m, pad: 2)}:${n(sec, pad: 2)}';
}

class _HeroLines extends StatelessWidget {
  const _HeroLines({required this.title, required this.status, required this.now, required this.numbers});
  final String title;
  final PrayerStatus status;
  final DateTime now;
  final LocaleDigits numbers;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final countdown = formatCountdown(status.remaining(now), numbers);
    return Semantics(
      label: '$title. ${l.nextIn(l.waqt(status.next), countdown)}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: WaqtMotion.ui,
            child: Text(
              title,
              key: ValueKey(title),
              style: WaqtText.title.copyWith(color: t.ink),
            ),
          ),
          const SizedBox(height: WaqtSpace.x1),
          Text(l.nextIn(l.waqt(status.next), countdown), style: WaqtText.body.copyWith(color: t.inkMuted)),
        ],
      ),
    );
  }
}

/// First run: ask where the user prays from. GPS or a city, both offline.
class _LocationCard extends ConsumerStatefulWidget {
  const _LocationCard();

  @override
  ConsumerState<_LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends ConsumerState<_LocationCard> {
  bool _busy = false;
  GpsError? _error;

  Future<void> _locate() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await locateWithGps(ref);
    if (mounted) {
      setState(() {
        _busy = false;
        _error = err;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(WaqtSpace.x5),
      decoration: BoxDecoration(
        color: t.heroSurface,
        borderRadius: BorderRadius.circular(WaqtRadii.card),
        boxShadow: t.hero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.nowLocationTitle, style: WaqtText.titleSmall.copyWith(color: t.heroInk)),
          const SizedBox(height: WaqtSpace.x2),
          Text(l.nowLocationBody, style: WaqtText.body.copyWith(color: t.heroInk.withValues(alpha: 0.72))),
          const SizedBox(height: WaqtSpace.x5),
          Row(
            children: [
              Expanded(
                child: _CardButton(
                  label: _busy ? l.locationLocating : l.locationUseGps,
                  filled: true,
                  busy: _busy,
                  onTap: _busy ? null : _locate,
                ),
              ),
              const SizedBox(width: WaqtSpace.x2),
              Expanded(
                child: _CardButton(label: l.locationChooseCity, onTap: () => context.push('/settings/city')),
              ),
            ],
          ),
          AnimatedSize(
            duration: WaqtMotion.ui,
            curve: WaqtMotion.ease,
            child: _error == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: WaqtSpace.x4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.gps(_error!),
                            style: WaqtText.label.copyWith(color: t.heroInk.withValues(alpha: 0.8)),
                          ),
                        ),
                        if (_error == GpsError.deniedForever || _error == GpsError.serviceOff)
                          TextButton(
                            onPressed: openLocationSettings,
                            style: TextButton.styleFrom(foregroundColor: t.accent),
                            child: Text(l.openSettings),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({required this.label, required this.onTap, this.filled = false, this.busy = false});
  final String label;
  final VoidCallback? onTap;
  final bool filled;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    // Accents are all light, so dark text on a filled button always passes.
    final fg = filled ? const Color(0xFF14110C) : t.heroInk;
    return Material(
      color: filled ? t.accent : Colors.transparent,
      shape: StadiumBorder(side: filled ? BorderSide.none : BorderSide(color: t.heroInk.withValues(alpha: 0.28))),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          height: WaqtSpace.minTouch,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy) ...[
                SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: fg)),
                const SizedBox(width: WaqtSpace.x2),
              ],
              Flexible(
                child: Text(
                  label,
                  style: WaqtText.label.copyWith(color: fg, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asked once, after a location exists. It shows the very reminder this
/// person would get next, so the value is concrete; one tap turns on the
/// recommended set.
class _SetupCard extends StatelessWidget {
  const _SetupCard({required this.next, required this.onSetup, required this.onDismiss});
  final PlannedReminder? next;
  final VoidCallback onSetup;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(WaqtSpace.x5, WaqtSpace.x5, WaqtSpace.x5, WaqtSpace.x3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(WaqtRadii.card),
        border: Border.all(color: t.ink.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active_outlined, size: 20, color: t.ink),
              const SizedBox(width: WaqtSpace.x2),
              Expanded(
                child: Text(l.setupCardTitle, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
              ),
            ],
          ),
          const SizedBox(height: WaqtSpace.x2),
          Text(l.setupCardBody, style: WaqtText.body.copyWith(color: t.inkMuted)),
          const SizedBox(height: WaqtSpace.x4),
          ReminderPreview(topic: next?.topic ?? ReminderTopic.arafah, at: next?.at, compact: true),
          const SizedBox(height: WaqtSpace.x2),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onDismiss,
                style: TextButton.styleFrom(foregroundColor: t.inkMuted, minimumSize: const Size(48, 48)),
                child: Text(l.setupCardDismiss),
              ),
              const SizedBox(width: WaqtSpace.x1),
              FilledButton(
                onPressed: onSetup,
                style: FilledButton.styleFrom(
                  backgroundColor: t.ink,
                  foregroundColor: t.ground,
                  minimumSize: const Size(48, 44),
                  shape: const StadiumBorder(),
                ),
                child: Text(l.setupCardAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The moments to show now, newest first, one card each: only those with
/// something to say (a sourced item or a restriction), at most three, and
/// never the prayer's own waqt, which the strip above already shows.
List<Moment> nowStack(List<Moment> active, DayGuides? guides) {
  final seen = <MomentId>{};
  return [
    for (final m in active)
      if (m.kind != MomentKind.prayer &&
          (m.kind == MomentKind.restricted || (guides?.forMoment(m.id).isNotEmpty ?? false)) &&
          seen.add(m.id))
        m,
  ].take(3).toList();
}
