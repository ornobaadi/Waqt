import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock/clock.dart';
import '../../data/user/user_prefs.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../l10n/app_localizations.dart';
import 'dhikr.dart';

class CounterState {
  const CounterState({
    this.routine = 0,
    this.step = 0,
    this.count = 0,
    this.freeTarget = 33,
    this.day = '',
    this.today = const {},
    this.saved = const {},
  });
  final int routine;
  final int step;
  final int count;
  final int freeTarget;

  /// Today's totals per dhikr id, for the civil date [day]. Reset never
  /// touches these; a new day starts them at zero.
  final String day;
  final Map<String, int> today;

  /// Where each other routine was left: routine id → (step, count).
  final Map<String, (int, int)> saved;

  DhikrRoutine get r => dhikrRoutines[routine];
  Dhikr get dhikr => r.steps[step];
  bool get free => dhikr.arabic == null;
  int get target => free ? freeTarget : dhikr.target;

  /// A set runs once through its steps; a single dhikr counts rounds.
  int get inRound => r.isSet ? count : count % target;
  int get round => r.isSet ? 1 : count ~/ target + 1;
  bool get finished => r.isSet && step == r.steps.length - 1 && count >= target;

  int get todayTotal => today.values.fold(0, (a, b) => a + b);

  CounterState copy({
    int? routine,
    int? step,
    int? count,
    int? freeTarget,
    String? day,
    Map<String, int>? today,
    Map<String, (int, int)>? saved,
  }) => CounterState(
    routine: routine ?? this.routine,
    step: step ?? this.step,
    count: count ?? this.count,
    freeTarget: freeTarget ?? this.freeTarget,
    day: day ?? this.day,
    today: today ?? this.today,
    saved: saved ?? this.saved,
  );

  Map<String, Object?> toJson() => {
    'routine': r.id,
    'step': step,
    'count': count,
    'free': freeTarget,
    'day': day,
    'today': today,
    'saved': {
      for (final MapEntry(:key, :value) in saved.entries) key: [value.$1, value.$2],
    },
  };

  static CounterState fromJson(Object? j) {
    if (j is! Map) return const CounterState();
    final ids = [for (final r in dhikrRoutines) r.id];
    final routine = ids.indexOf('${j['routine']}').clamp(0, ids.length - 1);
    final steps = dhikrRoutines[routine].steps.length;
    return CounterState(
      routine: routine,
      step: ((j['step'] as int?) ?? 0).clamp(0, steps - 1),
      count: ((j['count'] as int?) ?? 0).clamp(0, 1 << 20),
      freeTarget: (j['free'] as int?) ?? 33,
      day: '${j['day'] ?? ''}',
      today: {
        if (j['today'] case final Map<Object?, Object?> m)
          for (final MapEntry(:key, :value) in m.entries)
            if (value is int) '$key': value,
      },
      saved: {
        if (j['saved'] case final Map<Object?, Object?> m)
          for (final MapEntry(:key, :value) in m.entries)
            if (value case [final int st, final int c]) '$key': (st, c),
      },
    );
  }
}

/// The counter, kept on the phone: leaving the app or switching dhikr never
/// loses a count.
class CounterNotifier extends Notifier<CounterState> {
  static const _key = 'counter.v2';

  @override
  CounterState build() {
    final raw = ref.read(sharedPrefsProvider).getString(_key);
    CounterState s;
    try {
      s = raw == null ? const CounterState() : CounterState.fromJson(jsonDecode(raw));
    } on Object {
      s = const CounterState();
    }
    return _rollDay(s);
  }

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  /// Totals belong to one day; the current round carries on.
  CounterState _rollDay(CounterState s) {
    final today = _dayKey(readNow(ref.read(fakeClockProvider)));
    return s.day == today ? s : s.copy(day: today, today: const {});
  }

  void _save(CounterState s) {
    state = s;
    unawaited(ref.read(sharedPrefsProvider).setString(_key, jsonEncode(s.toJson())));
  }

  /// Returns true when this tap completed a round or a step.
  bool tap() {
    var s = _rollDay(state);
    // A finished set starts again from its first phrase.
    if (s.finished) s = s.copy(step: 0, count: 0);
    final id = s.dhikr.id;
    final today = {...s.today, id: (s.today[id] ?? 0) + 1};
    final c = s.count + 1;
    if (s.r.isSet && c >= s.target && s.step < s.r.steps.length - 1) {
      _save(s.copy(step: s.step + 1, count: 0, today: today));
      return true;
    }
    final next = s.copy(count: c, today: today);
    _save(next);
    return next.r.isSet ? next.finished : next.inRound == 0;
  }

  /// Back to the start of this round. Today's totals stay.
  void reset() => _save(state.copy(step: 0, count: 0));

  void setTarget(int t) => _save(state.copy(freeTarget: t, count: 0));

  /// Switch dhikr, keeping where the previous one was left.
  void choose(int routine) {
    final s = state;
    if (routine == s.routine) return;
    final saved = {...s.saved, s.r.id: (s.step, s.count)};
    final (step, count) = saved[dhikrRoutines[routine].id] ?? (0, 0);
    _save(s.copy(routine: routine, step: step, count: count, saved: saved));
  }
}

final counterProvider = NotifierProvider<CounterNotifier, CounterState>(CounterNotifier.new);

/// Vibrate on each count, so the counter can be used without looking. On by
/// default; the end of a round is always felt, as a stronger double pulse.
class CounterHaptics extends Notifier<bool> {
  static const _key = 'counter.haptics.v2';

  @override
  bool build() => ref.read(sharedPrefsProvider).getBool(_key) ?? true;

  void toggle() {
    state = !state;
    ref.read(sharedPrefsProvider).setBool(_key, state);
  }
}

final counterHapticsProvider = NotifierProvider<CounterHaptics, bool>(CounterHaptics.new);

/// A misbaha built around the words, not a number. The phrase sits in a
/// slowly brightening light; each count sends one soft ring outward; the
/// round closes as a thin circle. The whole screen is the button.
class CounterScreen extends ConsumerStatefulWidget {
  const CounterScreen({super.key});

  static const targets = [33, 99, 100];

  @override
  ConsumerState<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends ConsumerState<CounterScreen> with TickerProviderStateMixin {
  final _ripples = <AnimationController>[];

  @override
  void dispose() {
    for (final c in _ripples) {
      c.dispose();
    }
    super.dispose();
  }

  void _count() {
    final done = ref.read(counterProvider.notifier).tap();
    if (done) {
      // Milestone: two heavy pulses, unmistakable from a single count.
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 140), HapticFeedback.heavyImpact);
    } else if (ref.read(counterHapticsProvider)) {
      HapticFeedback.lightImpact();
    }
    if (MediaQuery.disableAnimationsOf(context)) return;
    final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _ripples.remove(c));
        c.dispose();
      }
    });
    setState(() => _ripples.add(c));
    c.forward();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final s = ref.watch(counterProvider);
    final haptics = ref.watch(counterHapticsProvider);
    final n = LocaleDigits(Localizations.localeOf(context).toLanguageTag());
    final reduce = MediaQuery.disableAnimationsOf(context);
    final d = s.dhikr;
    final progress = s.finished ? 1.0 : s.inRound / s.target;

    return Scaffold(
      backgroundColor: t.ground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        title: TextButton.icon(
          onPressed: () => _pick(context, s, n),
          style: TextButton.styleFrom(foregroundColor: t.ink),
          icon: const Icon(Icons.expand_more_rounded),
          iconAlignment: IconAlignment.end,
          label: Text(
            _routineName(l, s.r),
            style: WaqtText.bodyStrong.copyWith(color: t.ink),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          if (s.free)
            PopupMenuButton<int>(
              tooltip: l.counterTarget,
              initialValue: s.target,
              onSelected: ref.read(counterProvider.notifier).setTarget,
              itemBuilder: (_) => [for (final x in CounterScreen.targets) PopupMenuItem(value: x, child: Text(n(x)))],
              icon: Text('×${n(s.target)}', style: WaqtText.label.copyWith(color: t.ink)),
            ),
          IconButton(
            tooltip: l.counterHaptics,
            onPressed: ref.read(counterHapticsProvider.notifier).toggle,
            icon: Icon(haptics ? Icons.vibration_rounded : Icons.mobile_off_rounded, color: t.inkMuted),
          ),
          IconButton(
            tooltip: l.counterResetRound,
            onPressed: s.count == 0 && s.step == 0 ? null : ref.read(counterProvider.notifier).reset,
            icon: Icon(Icons.restart_alt_rounded, color: t.inkMuted),
          ),
        ],
      ),
      body: Semantics(
        button: true,
        label: '${d.latin.isEmpty ? l.counterTap : d.latin}, ${n(s.inRound)} / ${n(s.target)}',
        onTap: _count,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _count,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, box) {
                final size = math.min(box.maxWidth - 2 * WaqtSpace.screen, box.maxHeight * 0.62);
                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SizedBox.square(
                          dimension: size,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(end: progress),
                            duration: reduce ? Duration.zero : const Duration(milliseconds: 420),
                            curve: Curves.easeOutCubic,
                            builder: (context, p, child) => CustomPaint(
                              painter: _LightPainter(
                                progress: p,
                                ripples: List.of(_ripples),
                                ink: t.ink,
                                accent: t.accent,
                                repaint: Listenable.merge(_ripples),
                              ),
                              child: child,
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(size * 0.16),
                                child: AnimatedSwitcher(
                                  duration: reduce ? Duration.zero : const Duration(milliseconds: 600),
                                  child: _Words(key: ValueKey(d.id), dhikr: d),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '${n(s.finished ? s.target : s.inRound)} / ${n(s.target)}',
                      style: WaqtText.title.copyWith(color: t.ink, fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                    const SizedBox(height: WaqtSpace.x1),
                    Text(
                      s.r.isSet
                          ? l.counterStep(n(s.step + 1), n(s.r.steps.length))
                          : s.round > 1
                          ? l.counterRound(n(s.round))
                          : l.counterTap,
                      style: WaqtText.label.copyWith(color: t.inkMuted),
                    ),
                    const SizedBox(height: WaqtSpace.x4),
                    // Today's totals: every phrase said today, kept across
                    // resets and visits. Tap for the breakdown.
                    _TodayTotals(state: s, numbers: n),
                    const SizedBox(height: WaqtSpace.x6),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static String _routineName(AppLocalizations l, DhikrRoutine r) =>
      r.id == 'free' ? l.counterFree : (r.isSet ? l.counterAfterSalahName : r.steps.single.latin);

  Future<void> _pick(BuildContext context, CounterState s, LocaleDigits n) async {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final i = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      backgroundColor: t.ground,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: WaqtSpace.x4),
          children: [
            for (final (i, r) in dhikrRoutines.indexed)
              ListTile(
                selected: i == s.routine,
                selectedTileColor: t.ink.withValues(alpha: 0.06),
                title: Text(_routineName(l, r), style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                subtitle: r.id == 'free'
                    ? Text(l.counterFreeHint, style: WaqtText.label.copyWith(color: t.inkMuted))
                    : null,
                trailing: Text(
                  [
                    if (r.id != 'free') r.steps.map((d) => n(d.target)).join(' · '),
                    if (r.steps.fold<int>(0, (a, d) => a + (s.today[d.id] ?? 0)) case final c when c > 0)
                      l.counterToday(n(c)),
                  ].join(String.fromCharCode(10)),
                  textAlign: TextAlign.end,
                  style: WaqtText.label.copyWith(color: t.inkMuted),
                ),
                onTap: () => Navigator.pop(ctx, i),
              ),
          ],
        ),
      ),
    );
    if (i != null) ref.read(counterProvider.notifier).choose(i);
  }
}

/// The phrase itself, large, with how it is said beneath.
class _Words extends StatelessWidget {
  const _Words({super.key, required this.dhikr});
  final Dhikr dhikr;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    if (dhikr.arabic == null) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            dhikr.arabic!,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: WaqtText.arabic.copyWith(color: t.ink, fontSize: 44, height: 1.5),
          ),
        ),
        const SizedBox(height: WaqtSpace.x2),
        Text(
          dhikr.latin,
          textAlign: TextAlign.center,
          style: WaqtText.body.copyWith(color: t.inkMuted, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

/// A light that grows as the round fills, the round as a fine circle, and a
/// soft ring for each count.
class _LightPainter extends CustomPainter {
  _LightPainter({
    required this.progress,
    required this.ripples,
    required this.ink,
    required this.accent,
    super.repaint,
  });
  final double progress;
  final List<Animation<double>> ripples;
  final Color ink, accent;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;

    // The light: faint at the start of a round, warm by its end.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(alpha: 0.10 + 0.32 * progress),
            accent.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    // The round: a hairline track and the part already said.
    final ring = r * 0.86;
    canvas.drawCircle(
      c,
      ring,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = ink.withValues(alpha: 0.12),
    );
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: ring),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = ink,
      );
    }

    // One ring per count, rising from the words and fading.
    for (final a in ripples) {
      final e = Curves.easeOut.transform(a.value);
      canvas.drawCircle(
        c,
        ring * (0.45 + 0.55 * e),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = accent.withValues(alpha: (1 - e) * 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(_LightPainter o) =>
      o.progress != progress || o.ripples.length != ripples.length || o.ink != ink || o.accent != accent;
}

/// "Today 165" with the per-phrase breakdown a tap away.
class _TodayTotals extends StatelessWidget {
  const _TodayTotals({required this.state, required this.numbers});
  final CounterState state;
  final LocaleDigits numbers;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    if (state.todayTotal == 0) return const SizedBox(height: WaqtSpace.minTouch);
    final names = {
      for (final r in dhikrRoutines)
        for (final d in r.steps) d.id: d.latin.isEmpty ? l.counterFree : d.latin,
    };
    return TextButton.icon(
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        backgroundColor: t.ground,
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.counterTodayTitle, style: WaqtText.titleSmall.copyWith(color: t.ink)),
                const SizedBox(height: WaqtSpace.x3),
                for (final MapEntry(:key, :value) in (state.today.entries.toList()..sort((a, b) => b.value - a.value)))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: WaqtSpace.x2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(names[key] ?? key, style: WaqtText.body.copyWith(color: t.ink)),
                        ),
                        Text(numbers(value), style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                      ],
                    ),
                  ),
                Divider(color: t.hairline),
                Row(
                  children: [
                    Expanded(
                      child: Text(l.counterTodayAll, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                    ),
                    Text(numbers(state.todayTotal), style: WaqtText.titleSmall.copyWith(color: t.ink)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      style: TextButton.styleFrom(foregroundColor: t.inkMuted),
      icon: const Icon(Icons.insights_rounded, size: 18),
      label: Text(l.counterToday(numbers(state.todayTotal))),
    );
  }
}
