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
import '../duas/library_views.dart';
import 'dhikr.dart';
import '../../platform/haptics/haptics.dart';

class CounterState {
  CounterState({
    this.routineId = 'after_salah',
    this.step = 0,
    this.count = 0,
    this.freeTarget = 33,
    this.day = '',
    this.today = const {},
    this.saved = const {},
    this.custom = const [],
  });
  final String routineId;
  final int step;
  final int count;
  final int freeTarget;

  /// Today's totals per dhikr id, for the civil date [day]. Reset never
  /// touches these; a new day starts them at zero.
  final String day;
  final Map<String, int> today;

  /// Where each other routine was left: routine id → (step, count).
  final Map<String, (int, int)> saved;

  /// Phrases the user added, as many as they like.
  final List<Dhikr> custom;

  late final List<DhikrRoutine> routines = routinesWith(custom);
  late final DhikrRoutine r = routines.firstWhere((x) => x.id == routineId, orElse: () => routines.first);
  Dhikr get dhikr => r.steps[step.clamp(0, r.steps.length - 1)];
  bool get free => dhikr.id == 'free';
  int get target => free ? freeTarget : dhikr.target;

  /// A set runs once through its steps; a single dhikr counts rounds.
  int get inRound => r.isSet ? count : count % target;
  int get round => r.isSet ? 1 : count ~/ target + 1;
  bool get finished => r.isSet && step == r.steps.length - 1 && count >= target;

  int get todayTotal => today.values.fold(0, (a, b) => a + b);

  /// What a dhikr id is called, for today's list.
  String? nameOf(String id, String lang) =>
      [for (final r in routines) ...r.steps].where((d) => d.id == id).firstOrNull?.name(lang);

  CounterState copy({
    String? routineId,
    int? step,
    int? count,
    int? freeTarget,
    String? day,
    Map<String, int>? today,
    Map<String, (int, int)>? saved,
    List<Dhikr>? custom,
  }) => CounterState(
    routineId: routineId ?? this.routineId,
    step: step ?? this.step,
    count: count ?? this.count,
    freeTarget: freeTarget ?? this.freeTarget,
    day: day ?? this.day,
    today: today ?? this.today,
    saved: saved ?? this.saved,
    custom: custom ?? this.custom,
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
    'custom': [for (final d in custom) d.toJson()],
  };

  static CounterState fromJson(Object? j) {
    if (j is! Map) return CounterState();
    final custom = [if (j['custom'] case final List<Object?> l) ...l.map(Dhikr.fromJson).nonNulls];
    final s = CounterState(routineId: '${j['routine']}', custom: custom);
    return s.copy(
      routineId: s.r.id,
      step: ((j['step'] as int?) ?? 0).clamp(0, s.r.steps.length - 1),
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
      s = raw == null ? CounterState() : CounterState.fromJson(jsonDecode(raw));
    } on Object {
      s = CounterState();
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
  void choose(String id) {
    final s = state;
    if (id == s.r.id) return;
    final saved = {...s.saved, s.r.id: (s.step, s.count)};
    final (step, count) = saved[id] ?? (0, 0);
    _save(s.copy(routineId: id, step: step, count: count, saved: saved));
  }

  /// Add the user's own phrase and start counting it.
  void add(String name, String? arabic, int target) {
    final id = 'own_${DateTime.now().microsecondsSinceEpoch}';
    final d = Dhikr(id, arabic, name, target, custom: true);
    _save(state.copy(custom: [...state.custom, d]));
    choose(id);
  }

  void remove(String id) {
    final s = state;
    _save(
      s.copy(
        custom: [
          for (final d in s.custom)
            if (d.id != id) d,
        ],
        routineId: s.r.id == id ? 'after_salah' : null,
        step: s.r.id == id ? 0 : null,
        count: s.r.id == id ? 0 : null,
        saved: {...s.saved}..remove(id),
      ),
    );
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
      // Milestone: three strong pulses, unmistakable from a single count.
      Haptics.success();
    } else if (ref.read(counterHapticsProvider)) {
      Haptics.click();
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label: '${d.latin.isEmpty ? l.counterTap : d.latin}, ${n(s.inRound)} / ${n(s.target)}',
                onTap: _count,
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _count,
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
                            style: WaqtText.title.copyWith(
                              color: t.ink,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
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
                          const SizedBox(height: WaqtSpace.x2),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            // Why this dhikr, and how much of it today: outside the tap area.
            _Footer(state: s, numbers: n),
            const SizedBox(height: WaqtSpace.x4),
          ],
        ),
      ),
    );
  }

  static String _routineName(AppLocalizations l, DhikrRoutine r) =>
      r.id == 'free' ? l.counterFree : (r.isSet ? l.counterAfterSalahName : r.steps.single.name(l.localeName));

  Future<void> _pick(BuildContext context, CounterState s, LocaleDigits n) async {
    final id = await showModalBottomSheet<String>(
      useRootNavigator: true,
      context: context,
      showDragHandle: true,
      backgroundColor: WaqtTokens.of(context).ground,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (ctx, scroll) => Consumer(
          builder: (ctx, ref, _) {
            final l = AppLocalizations.of(ctx);
            final t = WaqtTokens.of(ctx);
            final s = ref.watch(counterProvider);
            Widget tile(DhikrRoutine r) => ListTile(
              selected: r.id == s.r.id,
              selectedTileColor: t.ink.withValues(alpha: 0.06),
              contentPadding: const EdgeInsetsDirectional.only(start: WaqtSpace.screen, end: WaqtSpace.x3),
              title: Text(_routineName(l, r), style: WaqtText.bodyStrong.copyWith(color: t.ink)),
              subtitle: switch (r.id == 'free' ? l.counterFreeHint : r.virtueIn(l.localeName)) {
                final v? => Text(
                  v,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: WaqtText.label.copyWith(color: t.inkMuted),
                ),
                null => null,
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (r.id != 'free')
                    Text(
                      r.steps.map((d) => n(d.target)).join(' · '),
                      style: WaqtText.label.copyWith(color: t.inkMuted),
                    ),
                  if (r.custom)
                    IconButton(
                      tooltip: l.counterRemove,
                      onPressed: () => ref.read(counterProvider.notifier).remove(r.id),
                      icon: Icon(Icons.close_rounded, size: 20, color: t.inkMuted),
                    )
                  else
                    const SizedBox(width: WaqtSpace.x3),
                ],
              ),
              onTap: () => Navigator.pop(ctx, r.id),
            );
            const everyday = {'after_salah', 'subhanallah', 'alhamdulillah', 'allahuakbar'};
            final rs = s.routines;
            return ListView(
              controller: scroll,
              padding: const EdgeInsets.only(bottom: WaqtSpace.x6),
              children: [
                for (final r in rs.where((r) => everyday.contains(r.id))) tile(r),
                _SheetLabel(l.counterSectionReward),
                for (final r in rs.where((r) => !everyday.contains(r.id) && !r.custom && r.id != 'free')) tile(r),
                _SheetLabel(l.counterSectionYours),
                for (final r in rs.where((r) => r.id == 'free' || r.custom)) tile(r),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: WaqtSpace.screen),
                  leading: Icon(Icons.add_rounded, color: t.ink),
                  title: Text(l.counterAddOwn, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                  onTap: () async {
                    final added = await _addOwn(ctx);
                    if (added && ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
    if (id != null) ref.read(counterProvider.notifier).choose(id);
  }

  /// A name, the Arabic if they want it, and how many times.
  Future<bool> _addOwn(BuildContext context) async {
    final name = TextEditingController(), arabic = TextEditingController(), target = TextEditingController(text: '33');
    final ok = await showModalBottomSheet<bool>(
      useRootNavigator: true,
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: WaqtTokens.of(context).ground,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx);
        final t = WaqtTokens.of(ctx);
        return Padding(
          padding: EdgeInsets.fromLTRB(
            WaqtSpace.screen,
            0,
            WaqtSpace.screen,
            WaqtSpace.x5 + MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.counterAddOwn, style: WaqtText.titleSmall.copyWith(color: t.ink)),
              const SizedBox(height: WaqtSpace.x4),
              TextField(
                controller: name,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l.counterOwnName),
              ),
              const SizedBox(height: WaqtSpace.x3),
              TextField(
                controller: arabic,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(labelText: l.counterOwnArabic),
              ),
              const SizedBox(height: WaqtSpace.x3),
              TextField(
                controller: target,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
                decoration: InputDecoration(labelText: l.counterOwnTarget),
              ),
              const SizedBox(height: WaqtSpace.x5),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: t.ink,
                  foregroundColor: t.ground,
                  minimumSize: const Size.fromHeight(WaqtSpace.minTouch),
                  shape: const StadiumBorder(),
                ),
                child: Text(l.counterSave),
              ),
            ],
          ),
        );
      },
    );
    final label = name.text.trim(), ar = arabic.text.trim();
    final count = (int.tryParse(target.text) ?? 33).clamp(1, 99999);
    name.dispose();
    arabic.dispose();
    target.dispose();
    if (ok != true || (label.isEmpty && ar.isEmpty)) return false;
    ref.read(counterProvider.notifier).add(label.isEmpty ? ar : label, ar.isEmpty ? null : ar, count);
    return true;
  }
}

/// The phrase itself, large, with how it is said beneath.
class _Words extends StatelessWidget {
  const _Words({super.key, required this.dhikr});
  final Dhikr dhikr;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    final ar = dhikr.arabic;
    if (ar == null || ar.isEmpty) {
      if (dhikr.latin.isEmpty) return const SizedBox.shrink();
      return Text(
        dhikr.latin,
        textAlign: TextAlign.center,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: WaqtText.title.copyWith(color: t.ink),
      );
    }
    final size = ar.length > 60
        ? 24.0
        : ar.length > 30
        ? 30.0
        : ar.length > 18
        ? 36.0
        : 44.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            ar,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: WaqtText.arabic.copyWith(color: t.ink, fontSize: size, height: 1.6),
          ),
        ),
        if (Localizations.localeOf(context).languageCode case final lang when lang != 'ar' && lang != 'ur') ...[
          const SizedBox(height: WaqtSpace.x2),
          Text(
            dhikr.name(lang),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: (ar.length > 30 ? WaqtText.label : WaqtText.body).copyWith(
              color: t.inkMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, WaqtSpace.x5, WaqtSpace.screen, WaqtSpace.x1),
    child: Text(text.toUpperCase(), style: WaqtText.overline.copyWith(color: WaqtTokens.of(context).inkMuted)),
  );
}

/// Under the counter: why this dhikr (opening its hadith) and how many
/// times it was said today (opening every dhikr said today).
class _Footer extends ConsumerWidget {
  const _Footer({required this.state, required this.numbers});
  final CounterState state;
  final LocaleDigits numbers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final r = state.r;
    final he = r.he;
    final virtue = r.virtueIn(l.localeName);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.screen),
      child: Column(
        children: [
          if (virtue != null && he != null)
            InkWell(
              borderRadius: BorderRadius.circular(WaqtRadii.strip),
              onTap: () => openHadith(context, ref, he),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x3, vertical: WaqtSpace.x2),
                child: Column(
                  children: [
                    Text(
                      virtue,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: WaqtText.label.copyWith(color: t.ink),
                    ),
                    const SizedBox(height: 2),
                    HeSourceText(
                      id: he,
                      style: WaqtText.caption.copyWith(color: t.inkMuted),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: WaqtSpace.x2),
          SizedBox(
            height: WaqtSpace.minTouch,
            child: state.todayTotal == 0
                ? null
                : OutlinedButton.icon(
                    onPressed: () => _showToday(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.ink,
                      side: BorderSide(color: t.hairline),
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(Icons.today_rounded, size: 18),
                    label: Text(
                      l.counterToday(numbers(state.today[state.dhikr.id] ?? 0)),
                      style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showToday(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final rows = state.today.entries.where((e) => e.value > 0).toList()..sort((a, b) => b.value - a.value);
    final top = rows.isEmpty ? 1 : rows.first.value;
    showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: t.ground,
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.75),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x8),
          children: [
            Text(l.counterTodayTitle.toUpperCase(), style: WaqtText.overline.copyWith(color: t.inkMuted)),
            const SizedBox(height: WaqtSpace.x1),
            Text(
              numbers(state.todayTotal),
              style: WaqtText.clock.copyWith(color: t.ink, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
            Text(l.counterTodayAll, style: WaqtText.label.copyWith(color: t.inkMuted)),
            const SizedBox(height: WaqtSpace.x5),
            for (final MapEntry(:key, :value) in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: WaqtSpace.x4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            switch (state.nameOf(key, l.localeName)) {
                              null || '' => l.counterFree,
                              final n => n,
                            },
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: WaqtText.body.copyWith(color: t.ink),
                          ),
                        ),
                        const SizedBox(width: WaqtSpace.x3),
                        Text(
                          numbers(value),
                          style: WaqtText.bodyStrong.copyWith(
                            color: t.ink,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: WaqtSpace.x2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: value / top,
                        minHeight: 4,
                        backgroundColor: t.hairline,
                        color: t.accent,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
