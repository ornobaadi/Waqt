import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/clock/clock.dart';
import '../../core/config/flavor.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../l10n/app_localizations.dart';

/// Home v0 skeleton. Prayer times, Hijri date and the sun arc arrive in
/// Phase 1; nothing here invents data we don't have yet.
class NowScreen extends ConsumerWidget {
  const NowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final now = ref.watch(nowProvider).value ?? readNow(ref.read(fakeClockProvider));
    final faked = ref.watch(fakeClockProvider) != null;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, WaqtSpace.x3, WaqtSpace.screen, WaqtSpace.x8),
        children: [
          Row(
            children: [
              Text(l.appName, style: WaqtText.titleSmall.copyWith(color: t.ink)),
              const Spacer(),
              if (faked) _Pill(text: l.debugClockFaked, color: t.accent, ink: t.ink),
              if (AppConfig.flavor == Flavor.dev) ...[
                const SizedBox(width: WaqtSpace.x2),
                _Pill(text: 'DEV', color: t.ink.withValues(alpha: 0.08), ink: t.inkMuted),
              ],
            ],
          ),
          const SizedBox(height: WaqtSpace.x1),
          Text(DateFormat.yMMMMEEEEd(locale).format(now), style: WaqtText.label.copyWith(color: t.inkMuted)),
          const SizedBox(height: WaqtSpace.x12),
          _Clock(now: now, locale: locale),
          const SizedBox(height: WaqtSpace.x8),
          _PrayerStrip(
            labels: [l.prayerFajr, l.prayerSunrise, l.prayerDhuhr, l.prayerAsr, l.prayerMaghrib, l.prayerIsha],
            pending: l.timePending,
          ),
          const SizedBox(height: WaqtSpace.x4),
          _LocationCard(title: l.nowLocationTitle, body: l.nowLocationBody),
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
      liveRegion: false,
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

class _PrayerStrip extends StatelessWidget {
  const _PrayerStrip({required this.labels, required this.pending});
  final List<String> labels;
  final String pending;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(WaqtSpace.x1),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.strip)),
      child: Row(
        children: [
          for (final label in labels)
            Expanded(
              child: SizedBox(
                height: 64,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: WaqtText.caption.copyWith(color: t.inkMuted),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    const SizedBox(height: WaqtSpace.x1),
                    Text(pending, style: WaqtText.bodyStrong.copyWith(color: t.ink.withValues(alpha: 0.35))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(WaqtSpace.x5),
      decoration: BoxDecoration(
        color: t.heroSurface,
        borderRadius: BorderRadius.circular(WaqtRadii.card),
        boxShadow: t.hero,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: t.accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: WaqtSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: WaqtText.titleSmall.copyWith(color: t.heroInk)),
                const SizedBox(height: WaqtSpace.x2),
                Text(body, style: WaqtText.body.copyWith(color: t.heroInk.withValues(alpha: 0.72))),
              ],
            ),
          ),
        ],
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
