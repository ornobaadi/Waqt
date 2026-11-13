import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/deeds/deeds.dart';
import 'day_ring.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../../domain/moments/moment.dart';
import '../../core/clock/clock.dart';
import '../../core/utils/digits.dart';
import '../../data/quran/quran.dart';
import '../../data/quran/quran_prefs.dart';
import '../counter/counter_screen.dart' show counterProvider;
import '../../l10n/app_localizations.dart';
import '../quran/quran_screen.dart' show openReader;
import '../common/labels.dart';
import '../now/moment_cards.dart' show clockFormat;

/// Every window of the prayer day (Fajr → Fajr) on one rail.
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  final _nowKey = GlobalKey();
  bool _scrolled = false;

  void _scrollToNow() {
    if (_scrolled) return;
    _scrolled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _nowKey.currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, alignment: 0.3, duration: Duration.zero);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final snap = ref.watch(momentSnapshotProvider);
    if (snap == null) {
      return SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTitle(l.navToday),
            Expanded(
              child: EmptyState(title: l.todayEmptyTitle, body: l.todayEmptyBody),
            ),
          ],
        ),
      );
    }
    _scrollToNow();

    final now = snap.now;
    final rows = <Widget>[];
    var nowPlaced = false;
    for (final m in snap.timeline) {
      if (!nowPlaced && m.window.start.isAfter(now)) {
        rows.add(_NowMarker(key: _nowKey, now: now));
        nowPlaced = true;
      }
      rows.add(_Row(moment: m, active: snap.active.contains(m), past: !m.window.end.isAfter(now)));
    }
    if (!nowPlaced) rows.add(_NowMarker(key: _nowKey, now: now));

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title and today's ring stay put; the timeline scrolls beneath.
          Padding(
            padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, WaqtSpace.x1, WaqtSpace.screen, WaqtSpace.x3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScreenTitleBare(l.navToday),
                DayRingCard(
                  dayKey: DeedStats.dayKey(snap.timeline.first.window.start),
                  onTap: () => context.push('/today/progress'),
                  onQuran: () {
                    final last = ref.read(quranProgressProvider).last;
                    last == null ? context.go('/quran') : openReader(context, last);
                  },
                  quranPlace: _quranPlace(context),
                  onDhikr: () => context.push('/counter'),
                  dhikrToday: _dhikrToday(),
                ),
              ],
            ),
          ),
          Expanded(
            // A day has ~30 rows: build them all so "now" can be scrolled to.
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                WaqtSpace.screen - 4,
                0,
                WaqtSpace.screen - 4,
                WaqtSpace.x12 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
            ),
          ),
        ],
      ),
    );
  }
}

extension on _TodayScreenState {
  /// "Al-Kahf, ayah 45", in the Arabic name for an Arabic reader.
  String? _quranPlace(BuildContext context) {
    final last = ref.watch(quranProgressProvider).last;
    final q = ref.watch(quranProvider).value;
    if (last == null || q == null) return null;
    final s = q.surah(last.surah);
    final tag = Localizations.localeOf(context).toLanguageTag();
    final name = s.nameIn(Localizations.localeOf(context).languageCode);
    return AppLocalizations.of(context).todayQuranAt(name, LocaleDigits(tag)(last.ayah));
  }

  /// Everything counted on the misbaha today.
  int _dhikrToday() {
    final c = ref.watch(counterProvider);
    final now = readNow(ref.watch(fakeClockProvider));
    if (c.day != '${now.year}-${now.month}-${now.day}') return 0;
    return c.today.values.fold(0, (a, b) => a + b);
  }
}

/// ScreenTitle without its own horizontal padding.
class ScreenTitleBare extends StatelessWidget {
  const ScreenTitleBare(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: WaqtSpace.x4),
    child: Semantics(
      header: true,
      child: Text(text, style: WaqtText.title.copyWith(color: WaqtTokens.of(context).ink)),
    ),
  );
}

const _timeCol = 72.0;
const _railCol = 24.0;

class _Rail extends StatelessWidget {
  const _Rail({required this.dot, this.dotSize = 8});
  final Color? dot;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return SizedBox(
      width: _railCol,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: Center(child: Container(width: 1.5, color: t.ink.withValues(alpha: 0.12))),
          ),
          if (dot != null)
            Padding(
              padding: EdgeInsets.only(top: 20 - dotSize / 2),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: dot,
                  shape: BoxShape.circle,
                  border: Border.all(color: t.ground, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.moment, required this.active, required this.past});
  final Moment moment;
  final bool active;
  final bool past;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final fmt = clockFormat(context);
    final w = moment.window;
    final prayer = moment.kind == MomentKind.prayer;
    final restricted = moment.kind == MomentKind.restricted;

    final title = Text(
      l.moment(moment),
      style: (prayer ? WaqtText.titleSmall : WaqtText.bodyStrong).copyWith(color: restricted ? t.inkMuted : t.ink),
    );

    return Semantics(
      selected: active,
      label: '${l.moment(moment)}, ${fmt.format(w.start)} – ${fmt.format(w.end)}',
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: WaqtMotion.ui,
        opacity: past ? 0.42 : 1,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: _timeCol,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: 4, top: prayer ? 11 : 12),
                  child: Text(
                    fmt.format(w.start),
                    style: (prayer ? WaqtText.label : WaqtText.caption).copyWith(
                      color: prayer ? t.ink : t.inkMuted,
                      fontWeight: prayer ? FontWeight.w600 : null,
                    ),
                  ),
                ),
              ),
              _Rail(
                dot: active ? t.accent : (prayer ? t.ink : (restricted ? null : t.ink.withValues(alpha: 0.35))),
                dotSize: prayer || active ? 10 : 6,
              ),
              Expanded(
                child: AnimatedContainer(
                  duration: WaqtMotion.ui,
                  margin: const EdgeInsetsDirectional.only(start: 4, top: 2, bottom: 2),
                  padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x3, vertical: WaqtSpace.x2 + 1),
                  decoration: BoxDecoration(
                    color: active ? t.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(WaqtRadii.row),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      const SizedBox(height: 2),
                      Text(
                        restricted
                            ? '${fmt.format(w.start)} – ${fmt.format(w.end)}  ·  ${l.kindRestricted}'
                            : '${fmt.format(w.start)} – ${fmt.format(w.end)}',
                        style: WaqtText.caption.copyWith(color: t.inkMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NowMarker extends StatelessWidget {
  const _NowMarker({super.key, required this.now});
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          SizedBox(
            width: _timeCol,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 4),
              child: Text(
                clockFormat(context).format(now),
                style: WaqtText.caption.copyWith(color: t.ink, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(
            width: _railCol,
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: t.ink,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: t.accent.withValues(alpha: 0.55), blurRadius: 0, spreadRadius: 4)],
                ),
              ),
            ),
          ),
          const SizedBox(width: WaqtSpace.x2),
          Expanded(child: Container(height: 1.5, color: t.ink)),
          const SizedBox(width: WaqtSpace.x2),
          Text(l.timelineNow.toUpperCase(), style: WaqtText.overline.copyWith(color: t.ink)),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
