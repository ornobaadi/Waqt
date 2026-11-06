import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/app_state.dart';
import '../../core/clock/clock.dart';
import '../../core/config/flavor.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../data/content/content_repository.dart';
import '../../data/user/checklist.dart';
import '../../data/user/notification_prefs.dart';
import '../../data/user/user_prefs.dart';
import '../../domain/moments/moment.dart';
import '../../domain/prayer/prayer_times_service.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/location/gps.dart';
import '../common/labels.dart';
import 'checklist_card.dart';
import 'moment_cards.dart';
import 'sky_arc.dart';

/// Home v0: where you are, what time it is in the prayer day, what's next.
class NowScreen extends ConsumerWidget {
  const NowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = ref.watch(nowProvider).value ?? readNow(ref.read(fakeClockProvider));
    final faked = ref.watch(fakeClockProvider) != null;
    final place = ref.watch(userPrefsProvider.select((p) => p.place));
    final status = ref.watch(prayerStatusProvider);
    final moments = ref.watch(momentSnapshotProvider);
    // The contextual module: a checklist when an active moment has one.
    final checklist = moments?.active
        .map((m) => m.id)
        .where((id) => checklistMoments.contains(id) && ref.watch(momentContentProvider(id)).isNotEmpty)
        .firstOrNull;
    final hijri = ref.watch(hijriDateProvider);
    final settings = ref.watch(prayerSettingsProvider);
    final n = LocaleDigits(locale);

    final dateLine = '${DateFormat.MMMEd(locale).format(now)}  ·  ${l.hijri(hijri, n.call)}';

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, WaqtSpace.x3, WaqtSpace.screen, WaqtSpace.x8),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place?.name ?? l.appName,
                      style: WaqtText.titleSmall.copyWith(color: t.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: WaqtSpace.x1),
                    Text(dateLine, style: WaqtText.label.copyWith(color: t.inkMuted)),
                  ],
                ),
              ),
              if (faked) _Pill(text: l.debugClockFaked, color: t.accent, ink: const Color(0xFF14110C)),
              if (AppConfig.flavor == Flavor.dev) ...[
                const SizedBox(width: WaqtSpace.x2),
                _Pill(text: 'DEV', color: t.ink.withValues(alpha: 0.08), ink: t.inkMuted),
              ],
            ],
          ),
          const SizedBox(height: WaqtSpace.x8),
          _Clock(now: now, locale: locale),
          if (status != null) ...[
            const SizedBox(height: WaqtSpace.x2),
            _StatusLine(status: status, now: now, numbers: n),
          ],
          if (moments != null) ...[const SizedBox(height: WaqtSpace.x8), SkyArc(snapshot: moments)],
          const SizedBox(height: WaqtSpace.x6),
          _PrayerStrip(status: status, now: now, locale: locale),
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
              onSetup: () {
                ref.read(notificationPrefsProvider.notifier).dismissSetup();
                context.push('/settings/notifications');
              },
              onDismiss: () => ref.read(notificationPrefsProvider.notifier).dismissSetup(),
            ),
          ],
          if (moments != null && moments.hero.kind != MomentKind.prayer) ...[
            const SizedBox(height: WaqtSpace.x4),
            RightNowCard(
              moment: moments.hero,
              now: now,
              // Checklist moments show their items in the checklist instead.
              items: checklistMoments.contains(moments.hero.id)
                  ? const []
                  : ref.watch(momentContentProvider(moments.hero.id)),
            ),
          ],
          if (checklist != null) ...[
            const SizedBox(height: WaqtSpace.x4),
            ChecklistCard(
              moment: checklist,
              items: ref.watch(momentContentProvider(checklist)),
              day: prayerDayKey(moments!.timeline.first.window.start),
            ),
          ],
          if (moments != null && moments.upcoming.isNotEmpty) ...[
            const SizedBox(height: WaqtSpace.x6),
            ComingUp(moments: moments.upcoming),
          ],
          if (place != null) ...[
            const SizedBox(height: WaqtSpace.x4),
            Semantics(
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(WaqtRadii.row),
                onTap: () => context.go('/settings'),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: WaqtSpace.minTouch),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x1),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${l.method(settings.method)}  ·  ${l.settingsAsr}: ${l.asr(settings.asr)}',
                            style: WaqtText.caption.copyWith(color: t.inkMuted),
                          ),
                        ),
                        const SizedBox(width: WaqtSpace.x2),
                        Icon(Icons.tune_rounded, size: 16, color: t.inkMuted),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: WaqtSpace.x4),
            const _LocationCard(),
          ],
        ],
      ),
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

    return Semantics(
      label: DateFormat.jm(locale).format(now),
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(hm, style: WaqtText.clock.copyWith(color: t.ink)),
          const SizedBox(width: WaqtSpace.x2),
          Text(suffix, style: WaqtText.titleSmall.copyWith(color: t.inkMuted)),
        ],
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

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.status, required this.now, required this.numbers});
  final PrayerStatus status;
  final DateTime now;
  final LocaleDigits numbers;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final countdown = formatCountdown(status.remaining(now), numbers);
    return Semantics(
      label: '${l.currentWaqt(status.current)}. ${l.nextIn(l.waqt(status.next), countdown)}',
      excludeSemantics: true,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: t.accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: WaqtSpace.x2),
          Text(l.currentWaqt(status.current), style: WaqtText.bodyStrong.copyWith(color: t.ink)),
          Text('  ·  ', style: WaqtText.body.copyWith(color: t.inkMuted)),
          Flexible(
            child: Text(
              l.nextIn(l.waqt(status.next), countdown),
              style: WaqtText.body.copyWith(color: t.inkMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerStrip extends StatelessWidget {
  const _PrayerStrip({required this.status, required this.now, required this.locale});
  final PrayerStatus? status;
  final DateTime now;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final h24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final fmt = h24 ? DateFormat.Hm(locale) : DateFormat('h:mm', locale);
    final s = status;

    return Container(
      padding: const EdgeInsets.all(WaqtSpace.x1),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.strip)),
      child: Row(
        children: [
          for (final w in Waqt.values)
            Expanded(
              child: _StripCell(
                label: l.waqt(w),
                time: s == null ? l.timePending : fmt.format(s.today[w]),
                pending: s == null,
                // Before Fajr the running Isha belongs to yesterday, so no
                // cell of today's strip is current.
                current: s != null && s.current == w && !s.today[w].isAfter(now),
                past: s != null && s.isPast(w, now),
              ),
            ),
        ],
      ),
    );
  }
}

class _StripCell extends StatelessWidget {
  const _StripCell({
    required this.label,
    required this.time,
    required this.pending,
    required this.current,
    required this.past,
  });
  final String label;
  final String time;
  final bool pending;
  final bool current;
  final bool past;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    final fg = current ? t.ground : t.ink;
    return AnimatedContainer(
      duration: WaqtMotion.ui,
      curve: WaqtMotion.ease,
      height: 64,
      decoration: BoxDecoration(
        color: current ? t.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(WaqtRadii.row),
      ),
      child: Semantics(
        selected: current,
        label: '$label $time',
        excludeSemantics: true,
        child: Opacity(
          opacity: past ? 0.45 : 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: WaqtText.caption.copyWith(color: current ? fg.withValues(alpha: 0.75) : t.inkMuted),
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              const SizedBox(height: WaqtSpace.x1),
              Text(time, style: WaqtText.bodyStrong.copyWith(color: pending ? t.ink.withValues(alpha: 0.35) : fg)),
            ],
          ),
        ),
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

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color, required this.ink});
  final String text;
  final Color color;
  final Color ink;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99)),
    child: Text(text, style: WaqtText.overline.copyWith(color: ink)),
  );
}

/// Asked once, after a location exists, so the value is obvious.
class _SetupCard extends StatelessWidget {
  const _SetupCard({required this.onSetup, required this.onDismiss});
  final VoidCallback onSetup;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(WaqtSpace.x5, WaqtSpace.x5, WaqtSpace.x4, WaqtSpace.x3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(WaqtRadii.card),
        border: Border.all(color: t.ink.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_none_rounded, size: 20, color: t.ink),
              const SizedBox(width: WaqtSpace.x2),
              Text(l.setupCardTitle, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
            ],
          ),
          const SizedBox(height: WaqtSpace.x2),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: WaqtSpace.x1),
            child: Text(l.setupCardBody, style: WaqtText.body.copyWith(color: t.inkMuted)),
          ),
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
